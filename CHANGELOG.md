# Changelog

所有规则/规范变更记录于此。版本语义见 `rules/evolution.md`（MAJOR=破坏性，MINOR=新增，PATCH=澄清/修正）。

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
