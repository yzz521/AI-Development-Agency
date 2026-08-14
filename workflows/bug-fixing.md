# Bug Fixing Workflow v1.1

## Input
- Bug 描述
- 复现信息
- 日志 / 错误信息
- 当前版本

## Stages
1. `codebase-onboarding`：定位调用链
2. 对应领域 Agent：根因分析与修复
3. `qa-engineer`：回归
4. `code-reviewer`：Review
5. `ai-tech-lead`：确认最小修复

## Rules
- 先复现 / 证据定位，再修改。
- 禁止以“顺手重构”为主线。
- 根因不明确时状态应为 BLOCKED，而不是猜测修复。

## Output
- 根因
- 修改
- 回归
- 风险
