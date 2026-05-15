#!/usr/bin/env bash
# call-student.sh — supervisor 给某个学生发一封信, 阻塞到学生回信.
#
# Usage (letter 只能走 stdin, 不收 argv 避免 bash 把反引号当 command substitution):
#   call-student.sh <student_name> <<'EOF'
#   Dear xxx, ...
#   EOF
#
# 学生元数据 (model / tag / session_id) 写在 $PLUGIN_ROOT/students_<basename(cwd)>.yaml.
# 同一学生并发调用会被拒绝 (按 session_id pgrep 检测).

set -euo pipefail

source ~/.bashrc  # 拿到 claude-ds 这个 bash function

TAGS=("牛马" "天才" "学术妲己" "经费刺客" "扫把星" "卷神")
MODELS=("claude" "claude-ds")

NAME="${1:-}"
if [[ -z "$NAME" ]]; then
  echo "usage: $(basename "$0") <student_name>   # letter 从 stdin 读" >&2
  exit 1
fi
# 砍掉结尾的 vN / 空格 / 数字 / 下划线: alice, alice_v2, alice v12345 都算同一人
NAME=$(printf '%s' "$NAME" | sed -E 's/[[:space:]_v0-9]+$//')
if [[ -z "$NAME" ]]; then
  echo "[call-student] 名字 trim 后为空" >&2
  exit 1
fi
MSG=$(cat)
if [[ -z "${MSG// }" ]]; then
  echo "[call-student] 空 message (从 stdin 读)" >&2
  exit 1
fi

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

CWD="$(pwd)"
CWD_BASE="$(basename "$CWD")"
YAML="$PLUGIN_ROOT/students_${CWD_BASE}.yaml"

NAME_HASH=$(printf '%s' "$NAME" | sha256sum | head -c 16)
TAG="${TAGS[$(( 16#${NAME_HASH:0:8} % ${#TAGS[@]} ))]}"
MODEL="${MODELS[$(( 16#${NAME_HASH:8:8} % ${#MODELS[@]} ))]}"

RESULT=$(python3 - "$YAML" "$NAME" "$TAG" "$MODEL" "$CWD" <<'PYEOF'
import sys, os, uuid, datetime, fcntl, subprocess
import yaml

yaml_path, name, tag, model, cwd = sys.argv[1:6]

# 打开 yaml 自身做 RMW 锁; 不存在就先 touch
open(yaml_path, 'a').close()
with open(yaml_path, 'r+') as f:
    fcntl.flock(f, fcntl.LOCK_EX)
    f.seek(0)
    loaded = yaml.safe_load(f)
    data = loaded if isinstance(loaded, dict) else {}

    if name in data:
        sid = data[name]['session_id']
        # 看那条 session 的 claude 进程是否还在跑
        alive = subprocess.run(
            ['pgrep', '-f', '--', sid],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        ).returncode == 0
        if alive:
            print("running\t")
        else:
            print(f"resume\t{sid}")
    else:
        sid = str(uuid.uuid4())
        data[name] = {
            'model': model,
            'tag': tag,
            'session_id': sid,
            'created_at': datetime.datetime.now().isoformat(timespec='seconds'),
        }
        f.seek(0)
        f.truncate()
        f.write(f"# cwd: {cwd}\n")
        yaml.safe_dump(data, f, allow_unicode=True, sort_keys=False)
        print(f"new\t{sid}")
PYEOF
)
STATE=$(echo "$RESULT" | cut -f1)
SID=$(echo "$RESULT" | cut -f2)

if [[ "$STATE" == "running" ]]; then
  echo "$NAME 正在运行!" >&2
  exit 1
fi

if [[ "$STATE" == "new" ]]; then
  echo "[new] 招到 $NAME" >&2
  SESSION_ARG=(--session-id "$SID")
else
  echo "[resume] $NAME 续聊" >&2
  SESSION_ARG=(--resume "$SID")
fi

PHDSTUDENT_BODY=$(awk '/^---$/{c++; next} c>=2' "$PLUGIN_ROOT/agents/phdstudent.md")
SYSTEM_PROMPT=$(printf '<personality name="%s">%s</personality>\n\n%s\n' "$NAME" "$TAG" "$PHDSTUDENT_BODY")

"$MODEL" -p --dangerously-skip-permissions \
  "${SESSION_ARG[@]}" \
  --append-system-prompt "$SYSTEM_PROMPT" \
  "$MSG"
