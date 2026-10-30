# Cursor 接入指南

## 定位

Cursor 负责执行；Agency 负责规范。用户直接下任务，**不必先跑 `agency` 命令**。

## 自动生效的三层（均可提交进业务仓库）

| 层 | 文件 | 作用 |
| --- | --- | --- |
| 常驻 | 根目录 `AGENTS.md` 规范路由段 | Cursor 自动读 |
| 常驻 | `.cursor/rules/agency-router.mdc`（`alwaysApply: true`） | 每轮注入压缩摘要 |
| 按任务 | `.agents/skills/agency-route/` | description 匹配写代码任务 |
| 会话内拦截 | `.cursor/hooks.json` + `.cursor/hooks/agency-stop.sh` | Agent 想结束时跑增量门禁，有 FAIL 就拽回来 |

写入方式（每个项目一次，或 `agency init` 已做）：

```bash
agency route --install /path/to/project   # 常驻摘要 + 路由技能
agency check --install /path/to/project   # git hook + CI + Cursor stop hook
```

按该项目技术栈裁剪摘要。之后 clone 仓库的同事无需再装 CLI 也能自动路由。

## Agent 会话内拦截（stop hook）

git hook 拦的是"提交"，拦不住"AI 说做完了其实没过门禁"——这是两件不同的事。

`agency check --install` 会写入 `.cursor/hooks.json`：

```json
{
  "version": 1,
  "hooks": {
    "stop": [{ "command": ".cursor/hooks/agency-stop.sh", "timeout": 120, "loop_limit": 2 }]
  }
}
```

Agent 想结束一轮时，hook 跑 `agency check`；若有 FAIL，通过 `followup_message`
把结果作为下一条消息回给 Agent，它会继续修。三重防打扰：

- 只在 `git status` 有未提交改动时触发（纯问答不跑）；
- 只在 `result=FAIL` 时介入，环境错误静默放行；
- `loop_limit: 2` 防止修不好时反复循环。

已有 `.cursor/hooks.json` 时 `--install` 不会覆盖，需手工把 `stop` 段合并进去。

排查：Cursor 的 `Customize → Hooks` 面板可看加载状态与执行日志；project hooks 需在
trusted workspace 中生效，路径相对项目根（`.cursor/hooks/xxx.sh`，不是 `./hooks/xxx.sh`）。

## 不要做的

- 不要把 31 个 Agent Prompt 复制进 `.cursor/agents/`。
- 不要把 `rules/` 全文 alwaysApply。
- 语言细则按路由命中加载摘要；原文仍在 `.ai/agency/rules/`。

## 与 CLI 的关系

`agency route` 只是同一张 `routes/table.tsv` 的检查器。智能体读 `AGENTS.md` / mdc / 技能即可工作。

强制层与工具无关：`agency check --install` 写入 hook + CI，只卡增量。见 `contracts/check-contract.md`。
