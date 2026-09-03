# Changelog

所有规则/规范变更记录于此。版本语义见 `rules/evolution.md`（MAJOR=破坏性，MINOR=新增，PATCH=澄清/修正）。

## v1.7.0（2026-09-03）

**弹性汇报 + 总控置顶 + 打开原文可核验（MINOR）**

- 汇报按风险：L1 三行、L2 短汇报、L3 完整表。业务仓无规则缺口不写 `rule_applied` 走流程。
- `AGENTS.md` 文首钉死最短总控（`<!-- agency-pin:begin -->`），`--install` / `--refresh-docs` 写入；防长文被截断后路由整段消失。
- 写代码回执增加 `opened=`：必须是本会话打开过的语言/领域原文；探测 `opened=none`。CLI 打印 `opened=suggest:`。
- 存量：保持增量门禁；手册 §2.3 规定用 `agency check --all` 按月出台账，不按库龄自动 FAIL，不把 `--all` 接进 hook/CI。
- 不预先堆框架写代码技能。DeepSeek Harness 自动入口本版不做。

## v1.6.0（2026-09-03）

**增量规范门禁：只卡 diff，不卡存量（MINOR）**

- 新增 `agency check`：按 `checks/catalog.tsv` 扫描 **git diff 新增行**。默认只开 `java-map-object` / `sql-select-star` / `secret-hardcoded`。
- `--staged` 给 pre-commit，`--base` 给 CI，`--all` 只做存量台账。
- `--install` 写入可提交的 `.agency-check/`、`.githooks/pre-commit`、`.github/workflows/agency-check.yml`、`agency-check.conf`；**不绑进** `agency init`。
- **破坏性别名**：`agency check` 不再等于 `agency status`/`doctor`。接入体检请用 `agency status` 或 `agency doctor`。
- 不做机检：魔法值、DTO 语义、医疗口径；Javert 专有规则不进中央默认 on。
- 技能 `agency-check`；契约 `contracts/check-contract.md`。

## v1.5.2（2026-09-03）

**路由回执：让「有没有触发」看得见（PATCH）**

- 写代码回复第一行必须是 `agency-route: matched=... risk=... rules=... source=...`。
- `agency route` CLI 输出同样一行；任务单增加「规范路由回执」；`agency audit` 缺回执则 WARN。
- 手册新增「怎么知道规范有没有被用到」：区分进上下文 / 模型声称匹配 / 代码是否守规。探测口令：`只做路由探测，不要改代码`。

## v1.5.1（2026-09-03）

**按规则清单落地红线 / 条件加载 / 下沉（PATCH）**

- 用户确认 `docs/规则清单.md` 建议列可直接用。
- 常驻红线收束到 global / minimalism / security 摘要 + 总控 §8 条；Map、魔法值、Java 版本、Pinia、Ant Design、医疗口径改为条件加载或下沉项目。
- 删除 Vue「蓝紫渐变」；Java 23 改为以项目为准；Spring Boot 示例前缀 `javert` → `app`。
- 性能优化拆到 `rules/performance.md` 条件加载；安全分级不再塞进写代码常驻摘要。
- 全部开发角色必读改为项目 `AGENTS.md`，不再指向中央 `context/`。
- B8 与最终汇报并存：未要求讲解时简短，规范汇报仍须完整。

## v1.5.0（2026-09-03）

**规范自动路由：提示词触发，注入规则摘要（MINOR）**

- 新增 `routes/table.tsv`：任务/文件 → Agent / Rule / Workflow 的单一真相。
- 各业务规则增加 `## 摘要（注入用）`；默认往上下文塞摘要而不是全文。
- 新增 `agency route`：可选检查器；`--install` 把路由段写入业务仓库（`AGENTS.md` / `.cursor/rules/agency-router.mdc` / `.agents/skills/agency-route`，可提交）；`--refresh-docs` 刷新本仓库文档。
- 新增技能 `agency-route`：写代码任务按 description 自动匹配，不要求用户先跑 CLI。
- `agency init` 接入项目时自动 `--install` 路由。
- 新增 `docs/规则清单.md`：摊开现行条文供圈选留/删。
- 新增 `adapters/cursor.md`。`rules/java.md` 去掉写死的 `JavertConstants`，改为以项目 `AGENTS.md` 为准。
- 总控升级 v1.5.0。

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
