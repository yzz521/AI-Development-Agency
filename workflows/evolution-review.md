# Evolution Review Workflow v2.0

## Purpose
把任务中自动采集的真实反馈转化为经过证据核验的规范改进，不让用户承担手工录入和定期催办。

## Trigger
- Agent 在每个任务收尾时自动完成反馈自检；发现问题立即落盘。
- GitHub Actions 每周生成一次最近 30 天反馈报告。
- 最近 30 天出现任意 `rule_stale`，或可改进反馈达到 3 条时，自动创建评审 Issue。
- 用户主动要求审查，或发生高风险规则缺陷时立即执行。

## Stage 1 — 自动采集
Agent: 当前执行任务的 Agent
1. 读取 `skills/agency-feedback/SKILL.md` 的收尾检查。
2. 只记录真实观察；没有问题不写 feedback。
3. Agent 自行运行 `agency feedback`，不要求用户复制命令。
4. 若环境不能写中央仓库，明确说明未落盘。

## Stage 2 — 自动汇总
Automation: `scripts/evolve.sh` + `.github/workflows/evolution-review.yml`
1. 统计最近 30 天反馈。
2. 输出各 kind 数量、原始反馈摘要和触发原因。
3. 达到阈值时创建 GitHub Issue；若已有未关闭的 Evolution review Issue，则不重复创建。
4. 此阶段不调用模型 API、不判断语义重复、不修改规则。

## Stage 3 — Curator 分析
Agent: `agency-curator`
1. 读取报告引用的原始反馈，核验任务、项目、规则和观察事实。
2. 将问题分类为：规则缺失、规则过时、规则冲突、规则表述不清、路由未触发、执行未遵守。
3. 同类问题按根因归并，不只按关键词去重。
4. 判断是否属于中央 Agency；项目专属问题退回项目仓库。
5. 证据充分时创建聚焦提案；证据不足时列出补证据要求。

## Stage 4 — 提案评审与实现
对每个提案核对：
- 证据是否真实、可追溯；
- 是否已有规则或提案覆盖；
- 影响范围与兼容性是否明确；
- 是否引入冲突、过度约束或平台专属假设；
- 是否给出可验证的验收标准。

结论：`accepted` / `rejected`（说明理由）/ `needs-evidence`。

接受的非破坏性提案可以由 Curator 在独立分支实现并创建 PR。删除规则、改变安全/权限/数据保护边界、改变强制行为或 MAJOR 变更，必须先获得人工批准。

## Stage 5 — 验证与交付
1. 修改对应规则、Workflow、Agent 或文档。
2. 运行 `bash scripts/validate.sh`，FAIL=0 才可提交。
3. 补充必要的自测，更新 README / CHANGELOG / 版本号。
4. 创建 PR，不直接推送 main。
5. PR 合并后归档提案并更新指标。

## Done
- 反馈已落盘或明确报告无法落盘；
- 报告可追溯到原始反馈；
- 每条候选有明确处理状态；
- 所有 PR 通过 validate；
- 没有未经批准的破坏性变更。

## Hard constraints
- 不编造反馈、证据、测试结果或模型分析。
- 自动汇总不等于自动语义评审。
- 不自动合并 PR；MAJOR 和安全边界变更必须人工批准。
