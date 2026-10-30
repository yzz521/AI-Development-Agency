# Code Review

> 由 `code-reviewer` 在 `agency check` 之后填写。
> **机器段（第 2 节）原样引用 `agency check` 的输出，不得手写编造。**
> 语义段（第 5 节）只写机器查不出来的问题。

## 1. 基本信息

- 任务 ID：
- 评审范围：`工作区` / `--staged` / `--base <ref>`
- Commit：
- 任务级别：L1 / L2 / L3
- 评审人：
- 日期：
- 涉及规则：

## 2. 机器门禁结果

> 来源：`agency check`（或 `bash .agency-check/check.sh`）。原样粘贴汇总行与 FAIL 行。

- 命令：
- 时间：
- 汇总行：`agency-check: mode=... result=... hits=... checks=...`
- 启用检查项：`agency check --list` 的 on 项（定义见 `checks/catalog.tsv`）

| 检查项 id | 文件:行 | 处理 |
| --- | --- | --- |
|  |  | 已修 / 申诉误报 / 遗留 |

## 3. 严重度约定

| 级别 | 含义 | 判定标准 |
| --- | --- | --- |
| 阻塞 | 必须修复，否则不可交付 | `agency check` 的 FAIL；或语义审查发现会出错、丢数据、越权的问题 |
| 建议 | 应修，或书面说明理由 | 明确偏离规则但存在合法例外 |
| 可选 | 可延后 | 风格偏差、可选优化 |

## 4. 检查清单

> 勾选表示**已核对**，不是"无问题"。机器覆盖项以 `checks/catalog.tsv` 为准，
> 用 `agency check --list` 查看当前项目启用的项，不要凭记忆列。

### 机器覆盖

- [ ] 已跑 `agency check`，`result=PASS`（有 FAIL 则不进入语义审查）
- [ ] 已确认 `agency-check.conf` 没有被临时关掉检查项来过关

### 语义覆盖（机器查不了，必须人工判断）

- [ ] 正确性与边界（空值、越界、并发、幂等）
- [ ] 事务边界与数据一致性
- [ ] 分层职责（Controller 不堆业务逻辑）
- [ ] 异步四态（loading / empty / error / retry）
- [ ] 过度设计（联动 `skills/diff-review`）
- [ ] 医疗业务区分「正式规则 / 业务事实 / 模型推断」（`rules/healthcare.md`）
- [ ] 规则 gap（发现无规则覆盖的新情况 → 记 `rule_gap` 反馈）

## 5. 语义审查

> 只写机器查不出来的问题。每条必须带 `文件:行` 证据，否则不成立。
> 不要重复罗列第 2 节机器已报的项。

### 5.1 正确性

-

### 5.2 事务与一致性

-

### 5.3 分层与职责

-

### 5.4 前端交互（涉及 UI 时）

-

### 5.5 过度设计与可删性

-

## 6. 误报申诉

> 机器报错但确认是误报时填这里，并建议把豁免条件写进 catalog 的 engine 或项目的
> `agency-check.conf`。不要靠长期堆注释掩盖检查项本身的缺陷。

- `FP: <检查项 id> <文件:行> <理由>`

## 7. 结论

**Decision**（四选一）：

- `APPROVE` — 门禁 PASS，语义审查无问题
- `APPROVE_WITH_NITS` — 门禁 PASS，仅有建议性改进
- `REQUEST_CHANGES` — 门禁 FAIL，或语义审查发现阻塞性缺陷
- `BLOCKED` — 缺关键信息，无法判断

判定依据：

- 门禁结果：
- 阻塞项数：
- 建议项数：
- 未解决风险：
- 后续动作（交回哪个 Agent / 补什么证据）：
