---
id: 20260903-elastic-report-pin-opened-stock-ledger
title: elastic report pin opened stock ledger
type: other
author: yzz521
status: review
created: 2026-09-03
evidence:
  - 用户确认按 4→2+1→存量台账 的顺序落地，Harness 先不做。Javert 教训：摘要不等于执行；全量门禁会关 hook。
impact:
  - AGENTS.md / agency-route / route.sh / evolution.md / check-contract / 日常使用手册
---

# 提案：弹性汇报、总控置顶、打开原文可核验、存量台账

## 背景与证据

评审六条意见后，用户确认按「先降噪音，再置顶+打开原文，存量另开台账」落地；DeepSeek Harness 自动入口本版不做。

## 现状问题

1. L1 也要付 L3 汇报和每次 feedback 的税。
2. 摘要触发后模型常不打开原文，约束丢失。
3. `AGENTS.md` 路由段靠后，截断后整段消失。
4. 只卡增量导致存量永不收敛；但不能把存量塞进同一道闸。

## 建议变更

1. 汇报按 L1/L2/L3 弹性；无缺口不写 `rule_applied`。
2. 文首 `agency-pin` 最短总控；`--install` 写入。
3. 回执增加 `opened=`（探测 `none`；CLI `suggest:`）。
4. `agency check --all` 按月出台账，不进 hook/CI，不按库龄自动 FAIL。

## 影响面

- 影响的 Agent：写代码角色的收工方式（更短）
- 影响的 Rule / Workflow：`rules/evolution.md`、`rules/minimalism.md` B8；路由契约
- 兼容性：向后兼容。旧回执缺 `opened=` 时 audit 改 WARN。MINOR v1.7.0。

## 评审记录

| 日期 | 评审人 | 结论 | 备注 |
| --- | --- | --- | --- |
| 2026-09-03 | ai-tech-lead | review | 与实现同 PR |
