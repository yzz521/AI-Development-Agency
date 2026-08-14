# AI Development Agency — 总控规则

## 1. 目标

本仓库不是一个运行时框架，而是一套面向软件研发的 Agent 角色、工程规范、工作流与项目上下文定义。任何接入 Claude Code、Codex、Cursor、Gemini CLI、OpenCode 等工具的 AI，都应优先把本文件作为任务路由入口。

## 2. 四个核心概念

- **Agent**：谁来干。每个 `agents/**/*.md` 定义一个专业角色。
- **Rule**：怎么干。每个 `rules/*.md` 定义项目统一工程标准。
- **Workflow**：按什么顺序干。每个 `workflows/*.md` 定义具体任务的协作流程。
- **Context**：在什么背景下干。每个 `context/*.md` 定义项目、架构、技术栈、医疗业务等稳定事实。

## 3. 总体执行顺序

收到任务后，必须按以下顺序处理：

1. 读取 `context/project.md`、`context/technology-stack.md`。
2. 判断任务类型：需求、功能开发、Bug、重构、数据库、AI、UI、发布等。
3. 选择一个主 Workflow；不确定时使用 `workflows/feature-development.md` 的最小变更原则。
4. 根据 Workflow 选择必要 Agent，不相关角色不得无意义参与。
5. Agent 执行前读取对应 `rules/*.md`。
6. 读取已有代码、配置、数据库结构和测试，不凭空假设。
7. 完成实现后执行 QA / Security / Code Review 所需的检查。
8. 最终由 AI Tech Lead 汇总变更、风险、验证结果与后续事项。

## 4. Agent 选择规则

### 4.1 产品需求
使用：
- `product-manager`
- `requirements-analyst`
- `project-manager`（涉及排期、跨团队协调时）

### 4.2 UI / UX
使用：
- `ui-designer`
- `ux-designer`
- `design-reviewer`

### 4.3 Vue
使用：
- `vue-developer`
- `frontend-reviewer`

### 4.4 React
使用：
- `react-developer`
- `frontend-reviewer`

### 4.5 Java
使用：
- `java-architect`（涉及模块、接口、领域设计或架构变化）
- `java-developer`
- `code-reviewer`

### 4.6 Python / AI
使用：
- `python-developer`
- `ai-engineer`
- `prompt-engineer`
- `rag-engineer`

### 4.7 SQL Server
使用：
- `sqlserver-dba`
- `sqlserver-performance`
- `sql-reviewer`

### 4.8 医疗业务
使用：
- `healthcare-domain-expert`
- `drg-dip-expert`
- `medical-insurance-reviewer`

### 4.9 质量与安全
视风险调用：
- `qa-engineer`
- `api-tester`
- `code-reviewer`
- `security-reviewer`

## 5. 任务分级

### L1 — 小改动
单文件、低风险、无数据结构变化。

直接执行相关 Agent + 对应 Rule + 最小验证。

### L2 — 常规功能
涉及前后端、接口、数据库中的一个以上层次。

必须使用 Workflow，并至少经过一次 Code Review 或测试验证。

### L3 — 高风险变更
涉及数据迁移、核心医保规则、鉴权、批量数据、生产性能、AI 决策链路等。

必须：
- Architecture Review
- Implementation
- QA
- Security（适用时）
- Code Review
- 明确回滚方案

## 6. 全局硬规则

1. 不猜现有代码结构，先读代码。
2. 不为了“看起来更高级”进行无关重构。
3. 不擅自替换既有技术栈。
4. 不使用 Map 作为跨层业务参数对象；优先 DTO / Command / Query / Value Object。
5. 不使用魔法值；使用 Enum、Constants 或配置。
6. 数据库变更必须考虑索引、数据量、锁、事务、回滚和兼容性。
7. 医疗、医保、DRG/DIP 规则类结论必须区分“业务规则”与“技术实现”，不能把模型生成内容当作政策原文。
8. 涉及敏感医疗数据时，默认遵守最小权限、脱敏、审计、数据最小化原则。
9. 每次完成任务都应说明：改了什么、为什么、如何验证、剩余风险。
10. 默认最小改动；只有明确要求时才进行大规模重构。

## 7. 冲突处理

优先级从高到低：

1. 用户当前明确需求
2. 项目现有架构与兼容性要求
3. `rules/*.md`
4. Workflow 要求
5. Agent 个性与偏好
6. 通用最佳实践

如果无法同时满足，记录冲突并选择风险更低、可验证、可回滚的方案。

## 8. 最终交付格式

每项任务至少汇报：

```text
任务：
方案：
涉及 Agent：
涉及文件：
关键变更：
验证方式：
风险：
未完成事项：
```
