---
name: git-commit
description: >
  Apply Agency Git conventions: Conventional Commits, branch naming
  (feature/fix/hotfix/...), no direct push to main, annotated SemVer tags.
  Use when creating a branch, writing a commit message, tagging a release,
  opening a pull request, or when the user mentions git, 分支, 提交信息,
  commit, Conventional Commits, 约定式提交, hotfix, git tag, 直推 main,
  分支命名, commitlint. Also use immediately before you git commit or
  git push at the end of a coding task. Do NOT invent a new branching
  model if the project AGENTS.md already declares one. Do NOT install
  Husky or Commitlint unless the user asks.
---

# Skill: git-commit — 提交 / 分支 / PR 按 Git 规范

## 触发

- 即将 `git commit` / `git push` / 开 PR / 打 tag
- 用户说「Git 规范 / 分支命名 / 提交信息 / 约定式提交 / 不要直推 main」
- 写代码任务收尾、需要留下可检索的提交历史时

## 过程

1. 读当前项目 `AGENTS.md`：若已声明分支模型、前缀或 tag 规则，以项目为准。
2. 读 `rules/git.md` 的 `## 摘要（注入用）`；摘要不够再打开原文。
3. 动手前核对：
   - 当前不在 `main`/`master` 上提交功能或修复（hotfix 从主干拉独立分支）
   - 分支名符合 `feature|fix|hotfix|release|chore|docs/<语义化描述>`
   - 提交信息是 `type(scope): 摘要`，一类改动一次提交
   - 不把密钥、完整 `.env`、私钥加进暂存区
4. 合入走 PR；不要 `git push` 到受保护主干。规范库自身还要遵守 `rules/evolution.md`。

## 边界

- 只约束 Git 操作与文案，不改业务代码、不替代 `agency check`。
- 不强制 Git Flow、Husky、Commitlint、工单号进分支名。
- 不把覆盖率或审批人数写成中央门槛。
- 调用本技能不改变当前角色。

## 退出

完成分支命名、提交信息或说明「按项目 AGENTS.md 已有 Git 约定执行」后停止。
不要在退出后再设计一套新的分支模型。
