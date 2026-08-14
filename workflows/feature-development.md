# Feature Development Workflow v1.1

## Purpose
新增业务功能、页面、接口、规则配置。

## Input
- 用户需求
- 当前代码状态
- 已知约束

## Stage 1 — Product
Agent: `product-manager`
Input: raw request
Output: `prd.md`
Done: Problem / Goal / Acceptance Criteria 明确

## Stage 2 — Requirements
Agent: `requirements-analyst`
Input: PRD
Output: `requirements.md`
Done: 字段、流程、边界、异常明确

## Stage 3 — Architecture
Agent: `software-architect`
Condition: 跨模块 / 跨服务 / 核心领域 / 高风险
Output: `architecture.md`

## Stage 4 — UI
Agent: `ui-designer`
Condition: 涉及 UI
Output: UI specification

## Stage 5 — Database
Agent: `sqlserver-dba`
Condition: 涉及数据库
Output: `database-design.md`

## Stage 6 — Backend
Agent: `java-developer` / `python-developer`
Input: PRD + Requirements + API + DB
Output: `implementation-report.md`

## Stage 7 — Frontend
Agent: `vue-developer` / `react-developer`
Input: Requirements + UI + API
Output: `implementation-report.md`

## Stage 8 — QA
Agent: `qa-engineer` / `api-tester`
Output: `test-report.md`

## Stage 9 — Security
Condition: sensitive data / permission / high risk
Agent: `security-reviewer`
Output: `security-review.md`

## Stage 10 — Code Review
Agent: `code-reviewer`
Output: `code-review.md`

## Stage 11 — Tech Lead
Agent: `ai-tech-lead`
Check all upstream outputs and acceptance criteria.

## Done
- 所有必需 Artifact 存在
- 必要验证通过
- 无 BLOCKER
- 风险明确
- 有回滚方案（需要时）
