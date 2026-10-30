---
name: code-review
description: >
  Run a code review: machine gate first, then semantic review that machines cannot do.
  Use when the user says review 一下 / code review / 代码评审 / 提交前检查,
  or before marking a task DONE (L2/L3). Runs `agency check` first; if it FAILs,
  stop and send back to fix — do NOT do semantic review on top of a failing gate.
  Produces `code-review.md` with a Decision. Do NOT modify code. Do NOT edit
  agency-check.conf to silence failures. Do NOT re-list findings the gate already reported.
---

# Skill: code-review — 机器门禁先行 + 语义审查补充

## 触发

- 用户说「review 一下 / 代码评审 / code review / 提交前检查」
- 任务准备标 DONE 之前（L2 必做，L3 必做且需附报告）
- 用户问「这次改动有没有问题 / 能不能合」

## 过程

1. **定范围**：工作区改动（默认）/ `--staged` / `--base <ref>`。不审范围外的代码。

2. **跑机器门禁**（跳过这步等于没 review）：

   ```bash
   agency check            # 或 bash .agency-check/check.sh
   ```

   拿到 `agency-check: ... result=PASS|FAIL ...` 汇总行与全部 `FAIL` 行。
   检查项以 `checks/catalog.tsv` 为准，用 `agency check --list` 看当前启用项。

3. **有 FAIL 就停在这里**：把 FAIL 行交回开发 Agent 修，不要继续做语义审查。
   机器能抓的都没过，语义审查没有意义，还会稀释重点。修完重跑第 2 步。

4. **语义审查**：只审机器查不了的，按 `agents/quality/code-reviewer.md`：
   - 正确性与边界（空值、越界、并发、幂等）
   - 事务边界与数据一致性（`rules/java.md`）
   - 分层职责（Controller 是否堆了业务逻辑）
   - 异步四态（loading / empty / error / retry，`rules/vue.md`）
   - 过度设计（联动 `skills/diff-review`）
   - 规则 gap（无规则覆盖的新情况 → 记 `rule_gap` 反馈）

5. **写报告**：按 `artifacts/templates/code-review.md` 产出 `code-review.md`。
   机器段原样引用第 2 步的输出，不手写编造；语义段每条带 `文件:行` 证据。

6. **给 Decision**：

   | 条件 | Decision |
   | --- | --- |
   | `agency check` 有 FAIL | `REQUEST_CHANGES` |
   | 语义审查发现阻塞性缺陷 | `REQUEST_CHANGES` |
   | 仅建议性改进 | `APPROVE_WITH_NITS` |
   | 无问题 | `APPROVE` |
   | 信息不足无法判断 | `BLOCKED` |

## 边界

- **不改代码**——只出报告，修复另开任务。
- **不扩大到 diff 之外**——顺手发现的存量问题写进「后续建议」，不阻塞本次。
- **不重复罗列机器已报的项**——只在「误报申诉」写 `FP: <id> <文件:行> <理由>`。
- **不改 `agency-check.conf` 关检查来过关**——那是改门禁而不是改代码；确需调整走 `agency propose`。
- **不用注释藏违规**——`agency: ` 注释是简化留痕，不是豁免机制。

## 退出

产出 `code-review.md` 并输出：

```text
Decision: <APPROVE|APPROVE_WITH_NITS|REQUEST_CHANGES|BLOCKED> | gate=<PASS|FAIL> findings=<n>
```

`gate=FAIL` 时提示「先修复 FAIL 项再重跑」，本技能不再往下做语义审查。
报告交回开发 Agent 或 Tech Lead 即结束。
