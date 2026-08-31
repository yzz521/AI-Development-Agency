# Changelog

所有规则/规范变更记录于此。版本语义见 `rules/evolution.md`（MAJOR=破坏性，MINOR=新增，PATCH=澄清/修正）。

## v1.4.1（2026-08-31）

**修复项目接入软链接指向错误（PATCH）**

- 修复 `scripts/init-project.sh`：软链接建在项目 `.ai/` 目录内，相对路径需从 `.ai/` 起算，原 `REL="../$(basename ...)"` 少一层，导致所有已接入项目的 `.ai/agency` 都是死链（`doctor` 报 `FAIL=5`，但 `agency list` / `agency use` 走 CLI 自身 `AGENCY_ROOT` 仍正常，问题被长期掩盖）。
- 路径改为按项目实际深度计算，`RECURSIVE=1` 下嵌套项目同样正确；纯参数展开实现，不依赖 here-string 临时文件，兼容 bash 3.2。
- 同步修正 `README.md`、`docs/批量初始化说明.md`、`docs/日常使用手册.md` 中 6 处错误路径示例。
- 升级方式：`./scripts/init-all.sh ~/workspace` 重跑一次即可自愈全部项目（脚本已有链接比对与重建逻辑）。

## v1.4.0（2026-08-28）

**最小化决策阶梯与场景技能层（MINOR）**

- 新增 `rules/minimalism.md`：7 级最小化决策阶梯 + "先理解再最小" + bug 修根因 + 绝不偷懒清单 + 非平凡逻辑留可运行检查 + 简化留痕（提案 `20260828-ponytail-minimalism`）。
- `rules/global.md` 新增第 9 条：有意的简化必须 `agency: <上限>, <升级路径>` 注释标注。
- 新增 `scripts/debt.sh` + `agency debt`：收割 `agency:` 注释为债务台账，无升级路径标记 `no-trigger`。
- 新增 `skills/` 场景技能层：定义文档 + 3 个示例技能（debt / task-audit / diff-review）（提案 `20260828-skills`）。
- 总控 `AGENTS.md` 补"角色与技能纪律"；升级 v1.4.0。

## v1.3.1（2026-08-28）

**工具链增强（PATCH）**

- 新增 `templates/requirement.md` + `agency require`：需求单，提需求标准化（5 要素）。
- 新增 `templates/task-report.md` + `agency task`：任务单，记录 AI 实际读取/修改文件、验证命令、规则反馈。
- 新增 `agency audit`：交叉核对任务单——引用存在性、git/修改时间痕迹、规则可解析、反馈合法性；让"是否真实按规范执行"可机器核查。
- 手册新增"步骤 0 提需求"与"步骤 10 留证据/审计"。

## v1.3.0（2026-08-28）

**自进化机制上线（Evolution Layer）**

- 新增 `rules/evolution.md`：规范自进化治理规则（反馈/提案/评审/合并/版本语义/守门）。
- 新增 `agents/leadership/agency-curator.md`：规范评审官角色。
- 新增 `workflows/evolution-review.md`：评审流程。
- 新增 `evolution/`：feedback / proposals / archive / metrics 四目录。
- 新增 CLI `scripts/agency.sh`（`agency` 命令）与 `feedback.sh` / `propose.sh` / `review.sh` / `validate.sh`。
- 新增 `docs/日常使用手册.md`、`templates/proposal.md`、`CHANGELOG.md`、CI `validate.yml`。
- 总控 `AGENTS.md` 升级 v1.3：四层模型 → 五层（Agent / Rule / Workflow / Context / Evolution），新增硬规则"任务完成后必须记录规则反馈"，新增 agency-curator 路由。
- 修复：全部 Agent"开始工作前必须读取"清单编号跳号（5→8）与文件项/非文件项混排，共修正 17 个文件（提案 `20260828-修正-agent-必读清单编号与解析规则`，已归档）。
- 首条反馈与首个提案闭环完成（feedback/2026-08-28.md → archive/）。
