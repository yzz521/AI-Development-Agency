# Cursor 接入指南

## 定位

Cursor 负责执行；Agency 负责规范。用户直接下任务，**不必先跑 `agency` 命令**。

## 自动生效的三层（均可提交进业务仓库）

| 层 | 文件 | 作用 |
| --- | --- | --- |
| 常驻 | 根目录 `AGENTS.md` 文首钉死段 + 规范路由段 | 截断时仍能看到最短总控 |
| 常驻 | `.cursor/rules/agency-router.mdc`（`alwaysApply: true`） | 钉死段 + 压缩摘要 |
| 按任务 | `.agents/skills/agency-route/` | description 匹配写代码任务 |

写入方式（每个项目一次，或 `agency init` 已做）：

```bash
agency route --install /path/to/project
```

按该项目技术栈裁剪摘要。之后 clone 仓库的同事无需再装 CLI 也能自动路由。

## 不要做的

- 不要把 31 个 Agent Prompt 复制进 `.cursor/agents/`。
- 不要把 `rules/` 全文 alwaysApply。
- 语言细则：写代码时打开命中规则原文（`opened=`）；摘要只负责触发。强制层仍是 `agency check`。

## 与 CLI 的关系

`agency route` 只是同一张 `routes/table.tsv` 的检查器。智能体读 `AGENTS.md` / mdc / 技能即可工作。

强制层与工具无关：`agency check --install` 写入 hook + CI，只卡增量。见 `contracts/check-contract.md`。
