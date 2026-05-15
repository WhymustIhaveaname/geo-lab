# geo-lab

English | [中文](README_zh.md)

![hero](hero.svg)

A Claude Code plugin that simulates a geotechnical engineering research group: one professor + a team of PhD students with varied personalities, running Abaqus simulations.

## Layout

```
geo-lab/
├── .claude-plugin/plugin.json
├── agents/phdstudent.md         # PhD student, runs Abaqus per professor's letters
├── agents/librarian.md          # Librarian, fetches open-access papers into literature/ + MANIFEST
├── commands/supervisor.md       # Entry command, plays the professor directing students
└── bin/call-student.sh          # Wrapper that delivers a letter to a student
```

## Workflow

Entry point is `/supervisor` — plays the professor, sends letters via `call-student.sh`, collects replies, maintains `group_homepage.md`. Each student is an independent `claude -p` session that reads the letter, runs Abaqus, writes a report, replies. Either side can invoke `librarian` to pull open-access PDFs into `literature/`.

## Personality system

Each new student's personality and underlying model are determined by `hash(name)`. The professor doesn't see them — they must be inferred from the student's letters:

- tag (1 of 6): 公式党 (formula-head) / 天才 (prodigy) / 学术妲己 (academic socialite) / 经费刺客 (grant assassin) / 试错派 (empiricist) / 卷神 (grind king)
- model (1 of 2): `claude` (Opus 4.7) / `claude-ds` (DeepSeek v4 pro)

Student records (name, tag, model, session_id) live in `geo-lab/students_<basename(cwd)>.yaml`. Calling the script with the same name auto-resumes that session.

## How to run

```bash
cd ~/Abaqus2024/<your_project>
claude --plugin-dir ../geo-lab --dangerously-skip-permissions
```

Inside Claude Code:

```
/supervisor
```

## Related projects

- arXiv tools for Claude Code: <https://github.com/WhymustIhaveaname/arxiv-tools>
- Telegram bridge for Claude Code: <https://github.com/WhymustIhaveaname/mcp-communicator-telegram>

## Collaboration

wang5240@purdue.edu
