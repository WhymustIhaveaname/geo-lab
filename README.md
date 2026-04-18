# geo-lab

岩土工程 Abaqus 仿真的 Claude Code plugin.

## 结构

```
geo-lab/
├── .claude-plugin/plugin.json
├── agents/supervisor.md         # 资深岩土教授, 审阅仿真报告 + 给建议
└── commands/geostart.md         # 入口 command, 驱动 student 跑 Abaqus
```

一个 student (由 `/geostart` 驱动) 负责跑 Abaqus, 每完成一次能产出可分析结果的 job 就调用 supervisor subagent 请示, 拿到意见再继续.

## 如何运行

```bash
cd ~/Abaqus2024/pile_consolidation
claude --plugin-dir ../geo-lab --dangerously-skip-permissions
```

进入 Claude Code 后执行:

```
/geostart
```

## 约定

- 问题定义写在 `Abaqus2024/README.md`, student 和 supervisor 都从这里读取.
- 每次 Abaqus 运行 hardlimit 600 秒.
- Student 自己 debug 语法错误, 不问 supervisor; 仅在产出可分析结果后请示.
