# Evolution Rules — 规范自进化治理规则 v1.0

本规则定义 AI Development Agency 自身如何进化：**谁可以提、怎么提、怎么评、怎么合、怎么版本化**。

## 1. 自进化闭环

```text
使用（执行任务）
   ↓ 发现缺口/过时/违反时记录反馈（不是每次都写）
反馈（evolution/feedback/）
   ↓ 反馈累积 / 直接提案
提案（evolution/proposals/）
   ↓ agency-curator 评审（workflows/evolution-review.md）
评审（合并 / 打回 / 拒绝）
   ↓ 合并后
更新（改规则 → CHANGELOG → bump 版本 → 提案入 archive/）
   ↓
回到使用，新规则生效
```

## 2. 反馈采集（采集层）

任何 Agent 完成任务后，必须对照所用 Rule 自检。**不是每次都要写 feedback。**

| 场景 | 要不要 `agency feedback` |
| --- | --- |
| 发现规则缺口 / 过时 / 存在但没被遵守 | **必须写**（`rule_gap` / `rule_stale` / `rule_violated`） |
| workflow / context 缺失或不适配 | **必须写** |
| 规范库自身任务且发现上述问题 | **必须写**，并在该升级时 `agency propose` |
| 业务仓一次顺利的 L1/L2 改动 | **不要写** `rule_applied` 走流程 |
| `rule_applied` | 可选，仅当需要留正面证据时 |

kind 取值：

| kind | 含义 | 价值 |
| --- | --- | --- |
| `rule_applied` | 规则被正确应用 | 规则有效性证据 |
| `rule_violated` | 规则存在但没被遵守 | 规则不清晰 / 执行遗漏 |
| `rule_gap` | 无规则覆盖该情况 | 新规则需求 |
| `rule_stale` | 规则过时 / 与现状冲突 | 规则修订需求 |
| `workflow_ok` / `workflow_gap` | workflow 有效 / 缺失不适配 | workflow 修订需求 |
| `context_gap` | context 缺失或过时 | context 修订需求 |

记录要求：

- 必须包含 `kind` 与 `detail`（客观描述，不写情绪）。
- 尽量带上 `project` / `task` / `rule` 作为证据链。
- 反馈只是证据，不直接改规则。

## 3. 提案（提案层）

反馈累积到"值得固化"或发现明确缺陷时，用 `agency propose` 创建提案：

提案类型：`rule-add` / `rule-change` / `rule-remove` / `workflow-add` / `workflow-change` / `context-add` / `agent-add` / `other`。

**合并门槛（缺一不可）：**

1. 有真实证据（哪个项目、哪个任务、观察到了什么）。
2. 明确影响面（影响的 Agent / Rule / Workflow）。
3. 一个提案只做一件连贯的事。
4. 默认向后兼容；破坏性变更必须在提案中声明并走 MAJOR 版本。
5. 删除规则必须先有替代方案或声明弃用期（至少一个版本周期）。

## 4. 评审（评审层）

- 评审者：`agents/leadership/agency-curator.md`，流程见 `workflows/evolution-review.md`。
- 评审节奏：建议每周一次，或每累计 3 条反馈 / 2 个提案触发一次；`agency review` 生成简报。
- 结论：`merged`（合并）/ `rejected`（拒绝，说明理由）/ 打回补证据。
- **破坏性变更（MAJOR）必须人工确认**；非破坏性变更可由 curator 直接合并。
- 合并动作 = 修改对应规范文件 + 更新 `CHANGELOG.md` + bump 版本 + 提案移入 `evolution/archive/`。

## 5. 版本语义

版本号 `vX.Y.Z`（记录于 `AGENTS.md` 标题、`CHANGELOG.md`，合并后 `git tag vX.Y.Z`）：

- **MAJOR**：破坏性变更（结构重组、删除规则、契约变更）。
- **MINOR**：新增规则 / Agent / Workflow / Context（向后兼容）。
- **PATCH**：澄清、修正笔误、格式修复。

合并必须至少 bump PATCH；新增内容 bump MINOR；破坏性变更 bump MAJOR。

## 6. 质量守门

- 每次合并前必须运行 `scripts/validate.sh`，FAIL=0 才允许合并。
- 合并必须提交到独立分支并走 PR（本仓库规则库的变更一律走 PR，禁止直接 push main）。
- 规则文件被大量 `rule_stale` / `rule_violated` 反馈命中时，应优先评审而不是继续堆新规则。

## 7. 不做什么

- 不为了"看起来在进化"而频繁改规则 —— 规则追求稳定，变更必须有证据。
- 不做无证据的删除 / 合并 / 重命名。
- 不把项目专属规则塞进中央 Agency（那属于项目 `AGENTS.md`）。
- 不自动合并破坏性变更。
