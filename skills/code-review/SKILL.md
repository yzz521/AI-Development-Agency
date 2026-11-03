---
name: code-review
description: >
  Run a code review: machine gate first, then line-by-line rule checking against the
  stack's full rule files, then semantic review that neither can cover.
  Use when the user says review 一下 / code review / 代码评审 / 提交前检查,
  or before marking a task DONE (L2/L3). Runs `agency check` first; if it FAILs,
  stop and send back to fix — do NOT review on top of a failing gate.
  Produces `code-review.md` with a Decision. Do NOT modify code. Do NOT edit
  agency-check.conf to silence failures. Do NOT re-list findings the gate already reported.
---

# Skill: code-review — 机器门禁 + 规范逐条核对 + 语义审查

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

4. **定技术栈 + 读规范全文**（跳过这步等于只做了机器门禁）：按 diff 涉及的文件扩展名
   确定技术栈，**读对应规则文件全文**——摘要只是注入用，会省略判定标准和例外条件，
   只看摘要审不出细节违规。

   | diff 文件 | 规则文件 | 条数 |
   | --- | --- | --- |
   | `*.java` / `*.kt` | `rules/java.md` | 20 |
   | `*.sql` / `*Mapper.xml` / `*mapper.xml` | `rules/sqlserver.md` | 13 |
   | `*.vue` | `rules/vue.md` | 14 |
   | `*.py` | `rules/python.md` | 15 |
   | `application*.yml` / `*ConfigurationProperties.java` | `rules/backend/java/spring-boot-configuration.md` | — |
   | 任何 diff（常驻） | `rules/global.md`（10）+ `rules/security.md`（12） | 22 |

   同时读项目 `AGENTS.md`：技术栈以项目为准，项目已声明的例外优先于中央规则。

5. **逐条核对规范**（review 的主体，不可跳过）：对每条规则给出三选一结论。

   | 结论 | 要求 |
   | --- | --- |
   | **违反** | 必须带 `文件:行` 证据 + 代码片段，进报告 5.2 违反项表 |
   | **符合** | 机器已覆盖且 `agency check` PASS 的，记「符合（机器）」不重复报；机器没覆盖的人工确认 |
   | **不适用** | 说明原因（如「本次 diff 无 SQL 变更」），进报告 5.3 不适用项表 |

   **不允许因为「规则太多」就只看机器检查结果。** 规范核对是 review 的定义性动作，
   机器检查只是把其中可自动判定的部分先跑掉，剩下的必须逐条人工判断。

   核对顺序按风险从高到低：`rules/security.md`（安全红线）→ 技术栈硬约束
   （`rules/java.md` 第 11-20 条 / `rules/vue.md` 第 9-14 条 / `rules/sqlserver.md` 全文）
   → `rules/global.md`（通用工程红线）。

6. **通用语义审查**：规范没覆盖但会出错的，按 `agents/quality/code-reviewer.md`：
   - 正确性与边界（空值、越界、并发、幂等）
   - 事务边界与数据一致性（`rules/java.md`）
   - 分层职责（Controller 是否堆了业务逻辑）
   - 代码结构与文件位置（目录/包/层级；文件大小参考阈值；职责是否单一）
   - 异步四态（loading / empty / error / retry，`rules/vue.md`）
   - 编码合理性（命名是否达意、重复代码块、嵌套层级过深、异常处理策略是否一致）
   - 过度设计（联动 `skills/diff-review`）
   - 安全与越权（数据归属校验、敏感信息泄露、SSRF/CORS 配置）
   - 规则 gap（无规则覆盖的新情况 → 记 `rule_gap` 反馈）

7. **写报告**：按 `artifacts/templates/code-review.md` 产出 `code-review.md`。
   机器段原样引用第 2 步的输出，不手写编造；规范核对段填核对范围与违反/不适用项；
   语义段每条带 `文件:行` 证据。

8. **给 Decision**：

   | 条件 | Decision |
   | --- | --- |
   | `agency check` 有 FAIL | `REQUEST_CHANGES` |
   | 规范核对发现阻塞级违反 | `REQUEST_CHANGES` |
   | 语义审查发现阻塞性缺陷 | `REQUEST_CHANGES` |
   | 仅建议性改进 | `APPROVE_WITH_NITS` |
   | 无问题 | `APPROVE` |
   | 信息不足无法判断 | `BLOCKED` |

## 边界

- **不改代码**——只出报告，修复另开任务。
- **不扩大到 diff 之外**——顺手发现的存量问题写进「后续建议」，不阻塞本次。
- **不跳过规范核对**——只跑 `agency check` 就出报告不算 review；必须读规则全文逐条核对。
- **不重复罗列机器已报的项**——只在「误报申诉」写 `FP: <id> <文件:行> <理由>`。
- **不改 `agency-check.conf` 关检查来过关**——那是改门禁而不是改代码；确需调整走 `agency propose`。
- **不用注释藏违规**——`agency: ` 注释是简化留痕，不是豁免机制。

## 退出

产出 `code-review.md` 并输出：

```text
Decision: <APPROVE|APPROVE_WITH_NITS|REQUEST_CHANGES|BLOCKED> | gate=<PASS|FAIL> findings=<n>
```

`gate=FAIL` 时提示「先修复 FAIL 项再重跑」，本技能不再往下做规范核对。
报告交回开发 Agent 或 Tech Lead 即结束。
