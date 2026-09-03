# Route Contract — 规范路由约定

## 目的

把「下达任务 → 读哪些规范再写代码」变成可执行匹配，而不是靠用户先记 `agency use`。

## 单一真相

```text
routes/table.tsv
```

工具侧适配（生成物，禁止手改后当真相）：

- 项目 `AGENTS.md` 中 `<!-- agency-router:begin -->` … `<!-- agency-router:end -->`
- `.cursor/rules/agency-router.mdc`
- `templates/project-AGENTS.md` 同名段
- `templates/cursor-rules/agency-router.mdc`

刷新生成物：

```bash
agency route --refresh-docs          # 本规范库
agency route --install <项目目录>    # 业务仓库，按技术栈裁剪摘要
```

## 匹配优先级

1. `always` 行：每次注入。
2. `file` 行：路径 / basename 命中 glob。
3. `keyword` 行：任务文本包含子串；若已探测到技术栈，则 `stack` 不匹配的 keyword 丢弃。
4. 若 2 和 3 都没有语言向命中：按项目技术栈套对应 `file` 行。
5. 多条 workflow 冲突 → `workflows/feature-development.md`。
6. 风险取最高（L3 > L2 > L1）。

## 注入形态（定义 B）

上下文里放规则文件的 `## 摘要（注入用）`，并保留原文路径。
禁止默认整篇注入 `rules/backend/java/spring-boot-configuration.md` 这类长文。

## 触发形态

用户提示词自动触发，不把 CLI 当入口：

| 载体 | 谁自动读 |
| --- | --- |
| 项目 `AGENTS.md` 路由段 | Cursor / Codex / 多数读 AGENTS.md 的工具 |
| `.cursor/rules/agency-router.mdc` | Cursor（alwaysApply） |
| `skills/agency-route/SKILL.md` | Cursor / Claude Code / Codex 技能匹配 |
| `agency route` | 可选检查器；无 CLI 时忽略 |

## 禁止

- 要求用户先记忆并执行 `agency use` / `agency route` 才能开始任务。
- 为每个宿主手抄一份互不一致的路由表。
- 把 31 个 Agent 全文当 always-on。
