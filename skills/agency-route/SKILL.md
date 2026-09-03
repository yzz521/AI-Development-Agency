---
name: agency-route
description: >
  Before writing, editing, reviewing, or designing code, match the task to
  Agency spec summaries (Java, Vue, React, Python, SQL Server, Spring config,
  healthcare, AI/RAG/OCR). Use on ANY coding task: add/fix/refactor API,
  page, component, SQL, YAML config, or bug. Also use when the user mentions
  规范, 按规范写, 路由, agency, 医保, DRG, Java, Vue, React, Python.
  Do NOT require the user to run agency CLI. Read the routing table and
  摘要（注入用）yourself. Do NOT use for non-coding chat, translation, or
  general knowledge.
---

# Skill: agency-route — 提示词自动路由到规范摘要

## 触发

写代码、改接口、改页面、改 SQL、改配置、修 bug 时**自动使用**。
用户不必说「路由」，也不必先跑 `agency` 命令。

## 过程

按顺序，停在第一条能完成匹配的路径：

1. **读路由表**（单一真相）
   - 项目内：`.ai/agency/routes/table.tsv`
   - 或本规范库：`routes/table.tsv`
   - 或项目 `AGENTS.md` / `.cursor/rules/agency-router.mdc` 里已生成的「规范路由」段
2. **匹配**
   - `file` 行：对照即将修改或已打开的文件路径
   - `keyword` 行：对照用户任务原文
   - `always` 行：每次都带上（global / minimalism / security）
   - 没有文件也没有关键词时：按项目技术栈回退（`pom.xml` → Java 等）
3. **注入摘要，不注入全文**
   - 打开命中规则文件的 `## 摘要（注入用）` 小节
   - 项目 `AGENTS.md` 路由段里若已内嵌摘要，直接用，不要再整篇读原文
   - 摘要不够再读原文；未命中的语言规范不要加载
4. **可选确认**（有 CLI 才用，没有就跳过）
   - `agency route --task "<用户原话>" --files <已知文件>`
   - 不得因为 CLI 不在 PATH 而中断任务，也不得让用户去记这条命令
5. 选最小必要 Agent 身份继续干活；调用本技能**不改变**当前角色。

## 边界

- 只负责选规范 + 注入摘要，不代替实现、不代替 CI。
- 不一次加载全部 `agents/` Prompt。
- 不把 `.ai/agency/` 整库读进上下文。
- 非编码问题（翻译、闲聊、纯解释）不要触发。
- 用户明确说「不要走规范 / 关掉路由」时停用本技能。

## 退出

已确定 matched rules / agents / risk，并把摘要放进当前上下文后，**立即开始做任务**。
不要停下来向用户汇报「我将使用某某 Agent」，除非用户问。
