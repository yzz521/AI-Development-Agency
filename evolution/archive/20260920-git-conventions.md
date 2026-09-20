---
id: 20260920-git-conventions
title: 新增 Git 规范（约定式提交 + 默认 GitHub Flow）
type: rule-add
author: yzz521
status: merged
created: 2026-09-20
evidence:
  - 用户提供 https://zhuanlan.zhihu.com/p/2069090815364818246 （苏三《一线大厂的Git规范》）。中央库已有 evolution 禁直推 main、agency check 增量门禁、code-reviewer，但无提交信息/分支命名/默认分支模型，AI 收尾提交缺少可执行约定。
impact:
  - 新增 rules/git.md、skills/git-commit、templates/githooks/commit-msg
  - routes/table.tsv、AGENTS.md §6、workflows/feature-development.md / bug-fixing.md / release.md
  - agency route --install 与 agency check --install
---

# 提案：新增 Git 规范（约定式提交 + 默认 GitHub Flow）

## 背景与证据

用户要求评估并将该文可复用部分融入本规范库。原文覆盖：Git Flow / GitHub Flow / Trunk-Based、分支命名、Conventional Commits、Code Review、Husky+Commitlint、Tag。

对照本仓库：

- 已有：`rules/evolution.md` 禁直推 main、`agency check` 拦增量代码、`code-reviewer`、发布 tag 语义。
- 缺失：给业务仓和 AI 用的提交文案、分支前缀、默认分支模型。`evolution/proposals/20260831-pre-push-main.md` 仍为 draft，且只覆盖本规范库的 push 路径，不覆盖业务仓提交规范。

## 现状问题

1. AI 完成编码任务后缺少可执行的 commit/branch 约定，历史不可检索。
2. 若整篇搬入 Git Flow + Husky + 覆盖率 80%，会违反「项目专属不下沉中央」和「不要过度设计」。
3. 强制层已明确是 hook + CI；提交文案不能塞进 `agency check` 的 diff 扫描。

## 建议变更

1. 新增 `rules/git.md`：约定式提交、分支命名、禁直推主干、注释 SemVer。默认 GitHub Flow；Git Flow / 工单号 / Husky 下沉项目。
2. 总控 §6 增加一条最低红线，全文按关键词注入（`stack=any`）。
3. 技能 `git-commit`：提交/分支/PR 场景即调即走。
4. `templates/githooks/commit-msg` 随 `agency check --install` 写入，不绑进 `agency init`。
5. 不合并 20260831-pre-push-main（本仓库直推 main 的钩子仍是另一件事）。

## 影响面

- 影响的 Agent：无新角色；所有会 `git commit` 的执行角色
- 影响的 Rule / Workflow：新增 `rules/git.md`；feature / bug-fix / release 各补一句
- 兼容性：向后兼容（纯新增）。已有 clone 需重新 `agency route --install` / `agency check --install` 才会拿到技能和 commit-msg 钩子

## 评审记录

| 日期 | 评审人 | 结论 | 备注 |
| --- | --- | --- | --- |
| 2026-09-20 | agency-curator | merged | 非破坏性 MINOR；裁掉 Git Flow/Husky/覆盖率强制 |
