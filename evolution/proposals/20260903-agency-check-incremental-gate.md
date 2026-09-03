---
id: 20260903-agency-check-incremental-gate
title: agency-check incremental gate
type: other
author: ai-tech-lead
status: review
created: 2026-09-03
evidence:
  - 用户问门禁怎么做。Javert 存量约 106 处违规，全量启用会关掉 hook。全限定类名未排除 import 曾误报 18 倍。agency check 曾是 doctor 别名，已让给门禁。
impact:
  - scripts/check.sh / checks/catalog.tsv / skills/agency-check / contracts/check-contract.md / agency CLI 别名
---

# 提案：增量规范门禁 agency check

## 背景与证据

用户问「门禁的话怎么做」。`docs/团队推广方案.md` 已证明：规范写进上下文仍会被违反；只有 git hook + CI 有强制力。Javert 存量约 106 处文件级命中，全量启用第一天就会有人关掉 hook。全限定类名规则未排除 `import` 时误报约 18 倍。

## 现状问题

1. 注入 / 路由回执只能降低违规概率，不能拦提交。
2. `.ai/` 在部分业务仓 gitignore，钩子不能放那里。
3. `agency check` 曾是 `doctor` 别名，名字被占用。

## 建议变更

1. `checks/catalog.tsv` 为机检单一真相；默认只开 `java-map-object` / `sql-select-star` / `secret-hardcoded`。
2. `agency check` 只扫 diff 新增行；`--all` 仅存量台账。
3. `--install` 写入 `.agency-check/` + `.githooks/` + CI + `agency-check.conf`，不绑进 `agency init`。
4. `agency check` 让给门禁；接入体检用 `agency status` / `agency doctor`。

## 影响面

- 影响的 Agent：写代码角色（收工前可跑检查）；`agency-check` 技能不改变角色
- 影响的 Rule / Workflow：不改规则正文；机检覆盖 D4 / I3 / A4
- 兼容性：`agency check` 别名行为变更（帮助里主入口一直是 `status`）。按 MINOR 发布并在 CHANGELOG 标明。

## 评审记录

| 日期 | 评审人 | 结论 | 备注 |
| --- | --- | --- | --- |
| 2026-09-03 | ai-tech-lead | review | 与实现同 PR |
