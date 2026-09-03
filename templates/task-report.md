# 任务单 <YYYYMMDD-NN>

> **给"AI 执行"用**：任务完成后由 AI 填写本单，作为"是否真实按规范执行"的机器可查证据。
> 生成：`agency task --title "xxx"`（产物在项目 `.ai/tasks/`）；核验：`agency audit`。
> 填写要求：**只写真实做过的事**——audit 会交叉核对读取/修改文件与验证记录，对不上就是未通过。

## 基本信息

- 任务 ID：
- 日期：
- 项目：
- 标题：
- 任务级别：L1 / L2 / L3（判据见总控 §5）
- 使用 Agent：
- 使用 Workflow：
- 涉及规则：
- 规范路由回执：`agency-route: matched=... risk=... rules=... source=...`

> 回执必须与本次会话第一行一致；没有回执 = 本次看不到自动路由是否触发。audit 会核对格式，不证明模型读过原文。

## 实际读取的文件

> 写你真实 read 过的文件，相对项目根路径。audit 会检查它们是否存在。

- [ ] `src/...`
- [ ] `.ai/agency/rules/java.md`

## 实际修改的文件

> 写你真实修改/新增的文件。audit 会与 git 变更集交叉核对。

- [ ] `src/...`

## 验证

> 写你真实跑过的验证命令与结果。audit 不代跑，供人工重跑核对。

- 命令：
- 结果：

## 规则反馈

> 按 rules/evolution.md 记录；kind：rule_applied / rule_violated / rule_gap / rule_stale / workflow_ok / workflow_gap / context_gap

- kind：
- 证据：

## 最终汇报

```text
任务：
修改：
验证：
风险：
未完成事项：
```
