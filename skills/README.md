# Skills — 场景技能层

**Skill = 场景 → 过程 + 命令 的薄包装**：即调即走、单一产出的轻量场景单位。

## 与其它层的关系

- **Agent（身份）**：全时段角色 Prompt，回答"你是谁、怎么完整干活"。
- **Skill（场景工具）**：一次会话里的轻量场景，回答"当前这个具体场景，按什么步骤做、停在哪"。
  - 不定义身份、不编排多角色——**调用一个技能不改变当前角色**。
  - 区别于 Workflow（多步骤流程编排）；Skill 是单场景薄包装，可引用 `scripts/` 命令。

## 结构

每个技能一个目录，含 `SKILL.md`。

### 1. frontmatter（必须，否则任何工具都发现不了）

```markdown
---
name: debt
description: 一句话说明「做什么 + 什么时候用」，把触发词嵌进去。
---
```

- `name` **必须**小写字母/数字/连字符，且与父目录名一致。
- `description` 是工具做**自动匹配**的唯一依据：必须同时写清「干什么」和「何时用」，把用户可能说的触发词写进去。
- 缺 frontmatter 的 `SKILL.md` 只是一篇文档，Cursor / Claude Code / Codex 都不会自动加载。

### 2. 正文三段式（必须）

1. **触发描述**：什么时候调用（显式场景词）。
2. **边界**：只做什么、不做什么（防越界，如审计时顺手改代码）。
3. **退出方式**：做完如何停止、产出什么。

### 3. 跨工具落点

`SKILL.md` 是目前可移植性最好的载体，Cursor / Claude Code / Codex 均可加载。
分发到项目时优先用厂商中立目录 `.agents/skills/`，避免为每个工具复制一份。

## 示例技能

| 技能 | 场景 | 过程 |
| --- | --- | --- |
| `skills/agency-route/SKILL.md` | 写代码 / 改接口 / 改页面 | 读路由表，注入命中规则的摘要；**不要求用户跑 CLI** |
| `skills/debt/SKILL.md` | 收割债务 / 清单简化的债 | 跑 `agency debt` 输出台账 |
| `skills/task-audit/SKILL.md` | 查 AI 是否真实执行 / 审计任务单 | 跑 `agency audit` + 解读 |
| `skills/diff-review/SKILL.md` | review 改动 / 查过度设计 | 只审 diff 的过度设计 |
| `skills/agency-task/SKILL.md` | 留证据 / 生成任务单 | 跑 `agency task` + 如实填写 |
| `skills/agency-feedback/SKILL.md` | 记规则反馈 / 提规则改进 | 跑 `agency feedback` / `propose` |

## 新增技能

- 遵循"一个提案一件事"：新增技能走 `agency propose`（type `other`）。
- 技能必须自包含 frontmatter + 触发 / 边界 / 退出，否则不合并。
- 技能可以包装已有命令；**跨工具自动触发的技能必须在没有 CLI 时仍能靠读文件完成**（见 `agency-route`）。
- 技能必须自包含 frontmatter + 触发 / 边界 / 退出，否则不合并。

## 不该做成技能的东西

- **常驻红线规范**：技能是按需触发，漏一次即失效；红线该进 `AGENTS.md` 常驻注入。
- **角色身份**：角色是全时段 Prompt（`agents/**/*.md`），调用技能不改变当前角色。
- **强制门禁**：技能不具备强制力，真正的拦截靠 git hooks + CI。
