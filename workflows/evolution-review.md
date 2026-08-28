# Evolution Review Workflow v1.0

## Purpose
对累积的反馈与提案进行评审，将"使用中发现的缺口"固化为规则更新。

## Trigger
- 每周一次（建议固定时间）；或
- 累计 3 条反馈 / 2 个提案；或
- 出现 `rule_stale` / 高危 `rule_gap` 反馈。

## Input
- `evolution/feedback/*.md`（近期反馈）
- `evolution/proposals/*.md`（待评审提案）
- `agency review` 简报

## Stage 1 — 简报生成
Agent: `agency-curator`
Action: 运行 `agency review`，读取待评审提案与近期反馈。
Output: 评审清单

## Stage 2 — 反馈分流
Agent: `agency-curator`
- `rule_applied` / `workflow_ok`：归档为证据，不动作。
- `rule_gap` / `workflow_gap` / `context_gap`：确认是否已有提案；没有则创建（`agency propose`）。
- `rule_stale` / `rule_violated`：优先于新提案处理。
Output: 分流结果

## Stage 3 — 逐条评审提案
Agent: `agency-curator`
对每个提案核对：
- 证据是否真实（项目 + 任务 + 观察）
- 影响面是否明确
- 是否破坏性变更（是 → 升级人工确认）
结论：`merged` / `rejected`（注明理由）/ 打回补证据（改状态为 draft 并注明缺口）

## Stage 4 — 合并执行
Agent: `agency-curator`（非破坏性可自行合并；破坏性必须人工确认后）
Actions:
1. 修改对应 `rules/` / `workflows/` / `agents/` / `context/` 文件
2. 运行 `scripts/validate.sh`（FAIL=0 才继续）
3. 更新 `CHANGELOG.md`
4. bump 版本（AGENTS.md 标题 + README + `git tag vX.Y.Z`）
5. 提案状态置 `merged`，移入 `evolution/archive/`

## Stage 5 — 指标更新
Agent: `agency-curator`
Action: 更新 `evolution/metrics.md`（提案数、合并率、反馈分布、老化规则）。

## Done
- 所有提案有结论
- 合并项通过 validate
- CHANGELOG / 版本 / metrics 已更新
- 拒绝项有理由，打回项有补证据指引

## 硬性约束
- 破坏性变更（MAJOR）必须人工确认
- 禁止直接 push main：合并走分支 + PR
- 不做无证据的规则变更
