---
id: 20260831-pre-push-main
title: 新增 pre-push 钩子拦截直推 main，让「变更走 PR」可执行
type: other
author: yzz
status: draft
created: 2026-08-31
evidence:
  - AI-Development-Agency v1.4.1 修复：rules/evolution.md:75 规定「禁止直接 push main」，实际仍直接 push 到 main（7d36be8）。规则清晰且 agency validate FAIL=0，但 validate 不校验提交路径，该规则技术上不可执行。
impact:
  - scripts/（新增钩子与安装步骤）、rules/evolution.md、docs/日常使用手册.md
---

# 提案：新增 pre-push 钩子拦截直推 main，让「变更走 PR」可执行

## 背景与证据

`rules/evolution.md:75` 规定：

> 合并必须提交到独立分支并走 PR（本仓库规则库的变更一律走 PR，禁止直接 push main）。

`docs/日常使用手册.md:162` 重复了同一约束。但 2026-08-31 修复 `init-project.sh` 软链接路径 bug 时（v1.4.1，6 个文件），变更被直接 commit 并 push 到 main（`7d36be8`），未走分支与 PR。

关键点是：**当时 `agency validate` 正常运行且 `FAIL=0`**。规则文本清晰、位置显眼、守门脚本在跑，规则依然被违反。

## 现状问题

`validate.sh` 校验的是**规范库内容的完整性**：

- 目录与必备文件存在
- Agent 必读引用、Workflow 引用、AGENTS.md 引用可解析
- Agent front matter 完整、名称唯一
- 提案状态合法、反馈 kind 合法

它**不校验变更是如何进入仓库的**。因此「禁止直接 push main」属于"写下来但没有任何执行点"的规则——只能依赖人（或 AI）自觉。

这与同期在 javert 观察到的现象同源：编码规范写在每次无条件注入 AI 上下文的 `CLAUDE.md` 里并标注「已强制」，仍存在 106 处文件级违反（见 `evolution/feedback/2026-08-31.md` 的 `rule_stale` 条）。

**共同结论：规范缺少机器门禁时，文本再清晰、注入再可靠，也会被绕过。**

## 建议变更

### 1. 新增 `scripts/hooks/pre-push`

拦截向 `main` 的直接 push，并给出明确的替代路径：

- 检测 push 目标 ref 为 `refs/heads/main` 时退出非零
- 错误信息包含：违反的规则位置（`rules/evolution.md:75`）、正确做法（建分支 + PR）、以及紧急绕过方式
- 提供绕过开关（如 `AGENCY_ALLOW_MAIN_PUSH=1`），避免钩子成为死锁；绕过属显式动作，可追溯

### 2. 新增安装步骤

- `scripts/install-cli.sh` 或独立 `agency init-hooks`，用 `git config core.hooksPath scripts/hooks` 挂载
- 需在 `agency status` / `doctor.sh` 增加一项检查：钩子是否已挂载（否则钩子存在但未生效，重演技能层的坑）

### 3. 规则文本补执行点

`rules/evolution.md` 在该条后补一句：本约束由 `scripts/hooks/pre-push` 执行，未挂载钩子的克隆需先跑安装命令。

### 4. 明确边界

- 钩子只拦**本仓库规则库**的 main 分支，不影响业务项目
- 钩子不做内容校验（那是 `validate` 的职责），只管提交路径
- 本地钩子可被 `--no-verify` 绕过，属已知局限；真正的强制需 GitHub 分支保护规则，建议同步开启（需仓库管理员操作）

## 影响面

- 影响的 Agent：无（流程约束，不改角色行为）
- 影响的 Rule / Workflow：`rules/evolution.md`（补执行点说明）、`docs/日常使用手册.md`（安装步骤）
- 新增：`scripts/hooks/pre-push`、`doctor.sh` 增加钩子挂载检查项
- 兼容性：向后兼容。已有克隆不挂钩子则行为不变；挂载后仅改变 push 到 main 的行为

## 待确认

1. 是否同步开启 GitHub 分支保护（本地钩子可被 `--no-verify` 绕过，分支保护才是硬约束）
2. 绕过开关的形式与是否需要记录到 `evolution/`

## 评审记录

| 日期 | 评审人 | 结论 | 备注 |
| --- | --- | --- | --- |
