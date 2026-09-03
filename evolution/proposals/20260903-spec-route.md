---
id: 20260903-spec-route
title: 规范自动路由（提示词触发 + 摘要注入）
type: other
author: agency-curator
status: review
created: 2026-09-03
evidence:
  - 用户明确要求下达任务后自动找到对应语言/领域规范，且不要把 agency CLI 当入口；工具混用 Cursor/Codex/Claude 等；注入形态选压缩摘要。
  - 现状 agency use 必须先知道角色名；.ai/agency 不是工具发现目录；团队推广方案已证明只靠自觉不够。
impact:
  - routes/table.tsv / agency route / skills/agency-route / 项目 AGENTS.md 模板 / Cursor adapter
---

# 提案：规范自动路由

## 背景与证据

ponytail 的触发是「规则进工具会自动读的位置 + 技能 description」，不是「用户先记一条命令」。Agency 已借鉴其最小化阶梯，但路由仍停留在总控文字和 `agency use <agent>`。混用多种 AI 工具时，记命令是负担，也会漏。

## 现状问题

1. `agency use` 假设人已经知道 Agent 名。
2. `.ai/agency` 不会被 Cursor / Codex 自动发现。
3. 规则全文 always-on 会爆 token（尤其 Spring Boot 配置长文）。

## 建议变更

1. `routes/table.tsv` 作为单一真相。
2. 规则文件增加摘要区；上下文默认摘要。
3. 技能 `agency-route` + 项目 `AGENTS.md` 路由段 + Cursor `alwaysApply` 规则作为自动触发；CLI 只做检查/安装。
4. `agency route --install` 按项目技术栈裁剪摘要并允许提交进业务仓库。

## 影响面

- 影响的 Agent：全部写代码角色（加载方式变，身份不变）
- 影响的 Rule / Workflow：各规则增加摘要区；新增路由契约
- 兼容性：向后兼容。`agency use` 保留。

## 评审记录

| 日期 | 评审人 | 结论 | 备注 |
| --- | --- | --- | --- |
| 2026-09-03 | ai-tech-lead | review | 与实现同 PR |
