# Evolution Rules — 规范自进化治理规则 v2.0

本规则定义 AI Development Agency 如何从真实使用中自动发现问题、记录证据、形成候选提案，并通过审核安全进化。

## 1. 自进化闭环

```text
任务执行
  ↓ Agent 在任务收尾时自动自检
自动反馈（仅发现真实问题时落盘）
  ↓ 达到阈值 / 高风险事件
自动汇总、去重、生成评审提醒
  ↓ Agency Curator 分析证据并起草提案
PR + validate
  ↓ 人工审核合并
版本化、归档、回到使用
```

自动化不等于无监督自我修改：采集和汇总自动执行；规则修改必须经过证据审查；破坏性变更和最终合并保留人工控制。

## 2. 反馈采集：Agent 自动执行

任何 Agent 在完成分析、设计、编码、Review、排障或文档任务后，必须进行一次简短的内部反馈检查。检查规则缺口、过时、违反、Workflow 不适配和 Context 缺失。

| 场景 | 行为 |
| --- | --- |
| 发现规则缺口 / 过时 / 违反 | Agent 自动运行 `agency feedback` 落盘 |
| Workflow 缺失或不适配 | 自动记录 `workflow_gap` |
| Context 缺失或过时 | 自动记录 `context_gap` |
| 没有发现问题 | 不写反馈，不写 `rule_applied` 凑数 |
| 无法访问中央仓库 / CLI 不可用 | 不声称已记录；在最终回复说明并提供反馈文本 |

合法 kind：`rule_applied`、`rule_violated`、`rule_gap`、`rule_stale`、`workflow_ok`、`workflow_gap`、`context_gap`。

反馈至少包含 kind、detail；尽可能包含真实 project、task、agent、rule。相同根因在同一任务中只记一次。反馈是证据，不直接改变规则。

具体自动触发与命令见 `skills/agency-feedback/SKILL.md`。

## 3. 自动汇总与触发阈值

`agency evolve` / `scripts/evolve.sh` 对最近 30 天反馈生成可审阅报告；可由 GitHub Actions 每周自动运行。

默认触发规则：
- 最近窗口内出现任意 `rule_stale`：立即进入优先评审队列。
- `rule_gap`、`workflow_gap`、`context_gap` 等可改进反馈累计达到 3 条：生成评审提醒。
- 未达到阈值：只生成统计，不创建提案、不修改规则。
- 报告只做可重复的统计和归集，不把关键词相似误判为语义重复；语义归并由 Curator 结合上下文判断。

自动任务只负责生成报告和 GitHub Issue 提醒，不调用未配置的模型 API，也不假装已完成 AI 评审。

## 4. 提案与评审

达到阈值或存在明确高风险缺陷时，Agency Curator：
1. 阅读原始反馈及其对应任务证据。
2. 判断问题是否属于中央 Agency，排除项目专属约束。
3. 识别根因：规则缺失、规则冲突、规则表述不清、路由未触发或执行未遵守。
4. 检查是否已有同类提案，合并重复问题。
5. 证据充分时创建一个聚焦单一问题的提案；证据不足时列为待补证据，不创建正式提案。
6. 提案必须写明建议修改的文件、原文、兼容性、验证方式和影响范围。

提案类型：`rule-add` / `rule-change` / `rule-remove` / `workflow-add` / `workflow-change` / `context-add` / `agent-add` / `other`。

## 5. 合并门槛

合并必须全部满足：
1. 有真实反馈和任务证据。
2. 明确影响面（Agent / Rule / Workflow / Context）。
3. 一个提案只做一件连贯的事。
4. 默认向后兼容；破坏性变更必须声明并升 MAJOR。
5. 删除规则必须有替代方案或至少一个版本周期的弃用期。
6. `scripts/validate.sh` FAIL=0。
7. 通过独立分支和 PR；禁止直接 push main。

**人工确认边界：**
- MAJOR、删除规则、改变安全/权限/数据保护边界、改变强制行为：必须人工批准。
- 其他变更可以由 Curator 自动准备代码和 PR，但默认不自动合并；由仓库维护者审核合并。
- 自动化工作流不得直接修改 main。

## 6. 版本语义

版本号 `vX.Y.Z`，记录于 `AGENTS.md`、`README.md` 和 `CHANGELOG.md`，发布后打 tag：
- MAJOR：破坏性变更、结构或契约不兼容。
- MINOR：新增规则 / Agent / Workflow / Context 或自动化能力。
- PATCH：澄清、修正笔误、格式修复。

每次合并至少 bump PATCH；新增能力 bump MINOR；破坏性变更 bump MAJOR。

## 7. 质量守门与指标

- 每次合并前运行 `scripts/validate.sh`，FAIL=0 才允许合并。
- 定期报告统计反馈数量、kind 分布、重复候选、待评审提案和老化项。
- 反馈量是发现问题的信号，不是 KPI；不得为了达到阈值制造反馈。
- 对同一规则反复出现的 `rule_violated`，优先判断规则是否难以执行、路由是否漏触发，不要简单叠加新规则。

## 8. 不做什么

- 不因一次主观不满就自动改常驻规则。
- 不以关键词相同直接认定语义重复。
- 不把项目专属规则塞进中央 Agency。
- 不伪造 CLI 执行、反馈落盘、测试通过或 PR 状态。
- 不自动合并 MAJOR 或安全边界变更。
