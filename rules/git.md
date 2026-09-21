# Git Rules

> 条件加载：任务涉及提交、分支、PR、tag、Git 规范时注入。提交信息的最低要求同时写在总控 §6。
> 分支模型以项目 `AGENTS.md` 为准；中央只给默认与禁区。

## 摘要（注入用）

- 提交信息用 Conventional Commits：`type(scope): 摘要`。常用 type：`feat` `fix` `docs` `style` `refactor` `perf` `test` `chore` `revert`。
- 功能与修复在独立短生命周期分支上做，经 PR 合入受保护主干；禁止直推 `main`/`master`。
- 分支名：`feature|fix|hotfix|release|chore|docs/<语义化描述>`，禁止 `aaa`/`test`/`111`。
- 发布 tag 用带注释的 SemVer：`vX.Y.Z`。密钥不进提交（见 `rules/security.md`）。
- 分支策略由项目 `AGENTS.md` 声明；未声明时默认 GitHub Flow（`main` + 短分支 + PR）。

## 默认模型

未在项目 `AGENTS.md` 声明时，采用 **GitHub Flow**：

1. 从 `main`（或项目指定的默认分支）拉短生命周期分支
2. 在分支上提交
3. 开 Pull Request / Merge Request
4. Review + CI 通过后合入
5. 合入后按项目节奏部署

不要把完整 Git Flow（长期 `develop` + `release` 分支）当成中央强制。有明确版本发布、需同时维护多版本时，在项目 `AGENTS.md` 声明轻量 Git Flow：`main` 生产、`develop` 集成、`hotfix/*` 从 `main` 拉；可用 tag 代替 `release` 分支。

Trunk-Based 仅在项目已有功能开关与极短分支习惯时采用，中央不默认。

## 分支命名

格式：`<类型>/<内容>`，全小写，单词用连字符。

| 前缀 | 用途 |
| --- | --- |
| `feature/` | 新功能 |
| `fix/` | 缺陷（非紧急） |
| `hotfix/` | 生产紧急修复 |
| `release/` | 发布准备（仅项目选用 Git Flow 时） |
| `chore/` | 工具、依赖、仓库杂务 |
| `docs/` | 仅文档 |

内容必须语义化：`feature/user-login` 可以；`feature/aaa`、`feature/test`、`feature/111` 不行。

工单号由项目决定是否强制，中央不要求。`release/` 与 `hotfix/` 若带版本号，用 `release/v2.1.0` 这种形式。

禁止对受保护主干和共享长期分支 `git push --force`（紧急恢复须人明确授权）。

## 提交信息

```text
<type>(<scope>): <subject>

[body]

[footer]
```

- `type` 必填；`scope` 可选（模块名，如 `user`、`api`、`agency-check`）
- `subject`：祈使句、不加句号、一行说清；中英文均可
- 一个提交一类改动；不要把无关文件塞进同一次提交
- 破坏性变更：`type(scope)!: 摘要` 或 footer `BREAKING CHANGE:`
- Merge / Revert 由 Git 生成的默认信息可保留

禁止：

- `update` / `fix stuff` / `改一下` / `临时提交` 这种无法检索的标题
- 提交密钥、密码、完整 `.env`、私钥（见全局红线）
- 仅为绕过规范门禁而 `--no-verify`（紧急绕过须在 PR 说明）

## 评审与合入

- 受保护主干禁止直推；合入必须经过 PR
- Review 用已有 `code-reviewer` 与项目分支保护，不要另起一套审查清单
- 覆盖率、审批人数、是否 squash 由项目仓库设置决定，中央不写死百分比或「至少两人」
- PR 说明写清：改了什么、怎么验证、风险；可复用 `templates/task-report.md` 的结构

## 版本与 Tag

- 对外发布使用注释 tag：`git tag -a vX.Y.Z -m "..."` 再推送该 tag
- 版本语义与规范库自身一致，见 `rules/evolution.md`：MAJOR 不兼容、MINOR 新增、PATCH 修复
- 业务仓库的版本方案以项目 `AGENTS.md` 为准；未声明时按 SemVer

## 强制手段（有工具才有执行力）

文本规范没有强制力。可选落地：

1. `templates/githooks/commit-msg`：校验 Conventional Commits。`agency check --install` 会写入 `.githooks/commit-msg`（与 pre-commit 一起挂 `core.hooksPath`）
2. 已有 `agency check` 的 pre-commit / CI：拦增量代码违规，不解析 commit 文案
3. 平台分支保护：禁直推 `main`、要求 PR + CI。本地钩子可被 `--no-verify` 绕过，分支保护才是硬约束

不要把 Husky / Commitlint 写成中央强制（多数 Java / SQL Server 仓库没有 Node）。项目已有 Husky 时，把 `.githooks/commit-msg` 的调用并进 `.husky/commit-msg`。

## 不做什么

- 不强制 Git Flow、不强制工单号进分支名、不强制 Node 工具链
- 不把「单次提交行数 / PR 行数」写成硬门禁；过大时拆 PR，由 reviewer 判断
- 不在中央规定 rebase 还是 merge；按项目已有习惯
