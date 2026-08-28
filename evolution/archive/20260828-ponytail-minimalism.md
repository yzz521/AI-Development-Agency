---
id: 20260828-ponytail-minimalism
title: 引入最小化决策阶梯与简化留痕纪律 ponytail-minimalism
type: rule-add
author: agency-curator
status: merged
created: 2026-08-28
evidence:
  - 分析 DietrichGebert/ponytail：7 级阶梯把'最小改动'变成可执行决策，ponytail: 债务注释让有意简化有上限与升级路径；Agency 现有'最小改动'不可执行、简化无留痕。
impact:
  - rules/global.md / 全部开发 Agent / scripts
---

# 提案：引入最小化决策阶梯与简化留痕纪律

## 背景与证据

分析 `DietrichGebert/ponytail`：其 7 级阶梯（YAGNI → 复用代码库 → 标准库 → 平台原生 → 已装依赖 → 一行 → 最小可行）把"最小改动"从口号变成 Agent 可逐级执行的决策过程；`ponytail:` 债务注释约定让有意的简化必须标注"上限 + 升级路径"。

Agency 现状：`rules/global.md` 第 2 条"保持最小变更面"是不可执行的原则；AGENTS.md 硬规则"默认最小改动"同样缺少操作步骤；简化没有留痕机制，妥协悄悄沉淀成技术债。

## 现状问题

1. "最小改动"无执行步骤，Agent 各按各的理解，无法审计。
2. 有意的简化（O(n²) 扫描、全局锁、临时方案）无标注、无升级路径，"以后再说"变成"永远不做"。
3. 无"绝不偷懒清单"，简化可能侵蚀信任边界（校验、防数据丢失、安全）。

## 建议变更

1. 新增 `rules/minimalism.md`：7 级阶梯 + "先理解再最小" + "bug 修根因（grep 所有调用方）" + "绝不偷懒清单" + "非平凡逻辑必须留一个可运行检查（无框架）"。
2. `rules/global.md` 新增第 9 条：有意的简化必须 `agency: <上限>, <升级路径>` 注释标注，并引用 `rules/minimalism.md`。
3. 新增 `scripts/debt.sh` + `agency debt` 命令：grep `agency:` 注释收割为债务台账，无升级路径的标记 `no-trigger`（防腐烂）。

## 影响面

- 影响的 Agent：全部开发 Agent（多一条必读规则引用）
- 影响的 Rule / Workflow：`rules/global.md` 修改；新增 `rules/minimalism.md`
- 兼容性：向后兼容（新增规则，无删除）

## 评审记录

| 日期 | 评审人 | 结论 | 备注 |
| --- | --- | --- | --- |
| 2026-08-28 | agency-curator | merged | 非破坏性新增规则，validate.sh 通过后合并 |
