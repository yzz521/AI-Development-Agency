---
name: agency-check
description: >
  Run Agency incremental spec gate (agency check) on git diff added lines.
  Use when the user mentions 门禁, 规范检查, pre-commit, CI, hook,
  agency check, 增量检查, SELECT *, Map<String Object>, 密钥写死,
  提交拦不拦, 只卡增量. After writing Java/SQL/YAML, if CLI exists,
  run agency check before claiming done. Do NOT scan the whole repo
  unless asked for 存量台账. Do NOT use for non-code chat.
---

# Skill: agency-check — 增量规范门禁

## 触发

- 用户说「门禁怎么做 / 挂 hook / 加 CI / 规范检查 / agency check」
- 写完 Java / SQL / YAML 配置，本地有 `agency` 或 `.agency-check/check.sh`
- 用户问「这次提交会不会被拦」

## 过程

1. **解释三层（只在用户问「怎么做」时）**
   - 注入（AGENTS.md / 技能）无强制力
   - 本机 `.githooks/pre-commit`（`git config core.hooksPath .githooks`）
   - CI（`.github/workflows/agency-check.yml`）覆盖所有工具和不用 AI 的提交
2. **安装（用户明确要求落地时）**
   - `agency check --install <项目目录>`
   - **不要**把它绑进 `agency init`，除非用户要求
   - 禁止对规范库自己 `--install`
3. **检查**
   - 默认：`agency check [dir]`（相对 HEAD 的新增行 + 未跟踪文件）
   - 提交前：`--staged`
   - CI：`--base origin/main`（或 PR base）
   - 存量台账才用 `--all`，不当门禁
4. **读开关**：项目根 `agency-check.conf`，目录 `checks/catalog.tsv`（或 `.agency-check/catalog.tsv`）
5. **默认只开** `java-map-object` / `sql-select-star` / `secret-hardcoded`
6. 命中则按 FAIL 行改代码，**禁止**关检查或把违规藏进注释来过关

## 边界

- 技能本身没有强制力；强制只来自 hook + CI。
- 不扫魔法值、DTO 语义、医疗口径。
- 不把 Javert 专有规则（一律 POST、`ylzzjgdm`）当成中央默认 on。
- 不改 `agency-check.conf` 把失败项关掉，除非用户明确接受风险。
- 调用本技能不改变当前角色。

## 退出

输出 `agency-check:` 汇总行和全部 `FAIL` 行后停止。

- 用户只问怎么做：说明安装命令与「只卡增量」原则，**不要**改业务代码。
- 检查 PASS：一句通过即可。
- 检查 FAIL：列出文件:行号和对应规则，再改代码，然后重跑检查。
