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

## 分层：哪些平台通用，哪些平台专属

接入不是“每个平台维护一套配置”，而是**一层通用 + 若干薄适配**。
判断标准只有一条：**只要能执行 shell 命令，就能用完整门禁**。

| 能力 | 载体 | 平台相关性 |
| --- | --- | --- |
| 规范注入（常驻） | 项目根 `AGENTS.md` + `.ai/agency/` 软链 | **通用**。`AGENTS.md` 已是跨工具事实标准 |
| 规范注入（按任务） | `.agents/skills/agency-route/` | **中立目录**。Cursor / Claude Code / Codex 原生识别；其他 harness 直接读 `SKILL.md` |
| 代码审查 | `.agents/skills/code-review/` | 同上 |
| 增量门禁 | `agency check`（纯 bash，零依赖） | **完全通用**。任何能跑命令的 Agent 都能调 |
| 提交拦截 | `.githooks/pre-commit` | **完全通用**。不依赖 Agent 平台 |
| 合入拦截 | `.github/workflows/agency-check.yml` | **完全通用** |
| 会话内拦截 | `.cursor/hooks.json` + `agency-stop.sh` | **仅 Cursor**（1.7+ Hooks）。其他平台忽略即可 |

**关键结论：强制力来自 `agency check` + git hook + CI，与平台无关。**
Cursor 的 stop hook 只是“少一次提交往返”的增益，不是必需项——没有它，门禁照样在提交和合入时生效。

## 各平台怎么用

| 平台 | 规范注入 | 门禁怎么触发 | 详见 |
| --- | --- | --- | --- |
| Cursor | `AGENTS.md` + `.cursor/rules/agency-router.mdc`（`alwaysApply`） | stop hook / pre-commit / CI | [cursor.md](cursor.md) |
| Codex | `AGENTS.md` + `.agents/skills/` | pre-commit / CI，或显式 `agency check` | [codex.md](codex.md) |
| DeepSeek Harness | `AGENTS.md` → `.ai/agency/` 角色文件 | pre-commit / CI，或显式 `agency check` | [deepseek-harness.md](deepseek-harness.md) |
| Reasonix | 同 DeepSeek Harness | 同上 | [reasonix.md](reasonix.md) |
| 其他 harness（Kimi 等） | `AGENTS.md` + 读 `.ai/agency/skills/<name>/SKILL.md` | pre-commit / CI | [统一接入流程.md](统一接入流程.md) |

不支持 skill 机制的平台不需要任何转换：`skills/<name>/SKILL.md` 就是一份 Markdown，
让 Agent 读它即可，语义与 Cursor 里 `/code-review` 完全一致。

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
