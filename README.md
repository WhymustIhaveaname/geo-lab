# geo-lab

岩土工程 Abaqus 仿真的 Claude Code plugin.

## 结构

```
geo-lab/
├── .claude-plugin/plugin.json
├── agents/phdstudent.md         # 博士生, 按导师指示跑 Abaqus
├── agents/librarian.md          # 文献员, 抓公开文献到 literature/ + MANIFEST
└── commands/supervisor.md       # 入口 command, 扮演 supervisor 指挥学生
```

一个 student (由 `/geostart` 驱动) 负责跑 Abaqus, 每完成一次能产出可分析结果的 job 就调用 supervisor subagent 请示, 拿到意见再继续.

## 如何运行

```bash
cd ~/Abaqus2024/pile_consolidation
claude --plugin-dir ../geo-lab --dangerously-skip-permissions
