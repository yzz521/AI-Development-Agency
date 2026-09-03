# AI Development Agency — 工具接入适配层

本目录负责说明如何把 AI Development Agency 接入具体 AI Coding 工具。

当前支持：

- Cursor
- Codex
- Reasonix
- DeepSeek Harness

## 设计原则

核心 Agent 定义不依赖具体工具。

```text
AI Development Agency
        │
        ├── agents/
        ├── rules/
        ├── workflows/
        └── context/
                │
                ↓
        ┌───────┬────────┼────────┐
        ↓       ↓        ↓        ↓
     Cursor  Codex   Reasonix  DeepSeek Harness
```

工具只是“运行层 / 使用层”。

因此：

- 不把 Agent 内容复制到工具专属目录。
- 不在工具适配文件中重复完整技术规范。
- 工具适配文件只负责“怎么加载和使用 Agency”。
- 项目级 `AGENTS.md` 负责把具体项目与 Agency 连接起来。

## 推荐目录

个人机器：

```text
~/ai/AI-Development-Agency/
```

具体项目：

```text
~/projects/your-project/
├── AGENTS.md
├── src/
├── ...
└── .ai/
```
