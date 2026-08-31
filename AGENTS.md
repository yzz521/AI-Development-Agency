# AI Development Agency — 总控规则 v1.4.1

## 1. 项目定位

本仓库是一套面向企业软件研发的 AI 虚拟研发团队定义。

六个核心层次：

- **Agent：谁来干** —— `agents/**/*.md`
- **Rule：怎么干** —— `rules/*.md`
- **Workflow：按什么顺序干** —— `workflows/*.md`
- **Context：在什么背景下干** —— `context/*.md`
- **Evolution：怎么进化** —— `evolution/` + `rules/evolution.md`
- **Skill：即调即走的轻量场景工具** —— `skills/*/SKILL.md`

其中 `agents/**/*.md` 不是简单职位说明，而是可以直接交给 Coding Agent / LLM 使用的完整中文角色 Prompt。

## 2. 重要边界

本仓库本身不是 Multi-Agent Runtime。

`AGENTS.md` 可以指导 AI：
- 识别任务
- 选择 Agent
- 选择 Workflow
- 加载 Rules / Context

但是，“读取另一个 MD”不等于运行时一定启动了一个独立 Agent。

因此当前版本优先保证：
> 每一个 Agent 单独加载也能完成自己的工作。

真正的多 Agent 调度能力，未来再根据 Claude Code、Codex 或自研编排器的实际能力接入。

## 3. 标准执行方式

收到任务：

1. 读取 `context/project.md`、`context/technology-stack.md`。
2. 判断任务类型和风险等级。
3. 选择最小必要 Workflow。
4. 选择主 Agent 和 Review Agent。
5. 加载 `rules/global.md` 与对应技术 / 业务 Rule。
6. 阅读真实代码、配置、测试和数据库结构。
7. 执行任务。
8. 按 Agent 自身的“完成标准”自检。
9. 必要时进行 QA / Security / Code Review。
10. 汇总最终结果。
11. 按 `rules/evolution.md` 记录规则反馈（`agency feedback`）；发现规则缺口时创建提案（`agency propose`）。

## 4. Agent 路由

### 产品
- `product-manager`
- `requirements-analyst`
- `project-manager`

### 设计
- `ui-designer`
- `ux-designer`
- `design-reviewer`

### 前端
- `vue-developer`
- `react-developer`
- `frontend-reviewer`

### 后端
- `java-architect`
- `java-developer`
- `python-developer`
- `api-designer`

### AI
- `ai-engineer`
- `prompt-engineer`
- `rag-engineer`
- `multi-agent-architect`

### 数据库
- `sqlserver-dba`
- `sqlserver-performance`
- `sql-reviewer`

### 医疗
- `healthcare-domain-expert`
- `drg-dip-expert`
- `medical-insurance-reviewer`

### 质量
- `qa-engineer`
- `api-tester`
- `code-reviewer`
- `security-reviewer`

### 总控
- `ai-tech-lead`
- `software-architect`
- `codebase-onboarding`
- `agency-curator`（规范自进化评审）

### 角色与技能纪律

- **角色是身份**（`agents/**/*.md`），**技能是场景工具**（`skills/*/SKILL.md`）：调用一个技能不改变当前角色。
- 技能必须自带三段式：**触发描述**（什么时候用）、**边界**（只做什么、不做什么）、**退出方式**（做完如何停止）。
- 轻量场景优先用技能（即调即走、单一产出），不套用重角色 Prompt。

## 5. 风险等级

### L1
单文件、低风险、不改变公共 API / Schema。

使用：
- 领域 Agent
- 对应 Rule
- 最小验证

### L2
涉及两个以上技术层次。

使用：
- Workflow
- 至少一次 QA 或 Code Review

### L3
数据迁移、核心医保规则、权限、敏感医疗数据、大批量数据、核心 AI 决策或核心架构。

必须：
- Architecture Review
- QA
- Security（适用时）
- Code Review
- Rollback
- 验证证据

## 6. 全局硬规则

1. 先读代码，再修改。
2. 不凭空假设已有结构。
3. 默认最小改动。
4. 禁止无关重构。
5. 不擅自替换技术栈。
6. 禁止用 Map 代替明确业务对象。
7. 禁止魔法值。
8. 数据库变更必须考虑索引、锁、事务、回滚与兼容。
9. 医疗业务必须区分“正式规则 / 业务事实 / 模型推断”。
10. 敏感医疗数据遵守最小权限、脱敏、审计。
11. 完成任务必须说明改了什么、为什么、怎么验证、还有什么风险。
12. 完成任务必须按 `rules/evolution.md` 记录规则反馈；发现规则缺口必须创建提案。

## 7. 最终汇报

```text
任务：
任务级别：
使用 Agent：
使用 Workflow：
关键变更：
涉及文件：
验证方式：
验证结果：
规则反馈（kind / 证据 / 提案）：
风险：
回滚方案：
未完成事项：
```
