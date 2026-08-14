# AI Development Agency

面向企业软件研发的 AI 虚拟团队定义仓库。

## 定位

本项目借鉴 `agency-agents` 的 Agent-as-Markdown 思路，但不复制其完整 Agent 库。目标是形成适配当前研发体系的“角色 + 规范 + 工作流 + 上下文”基础设施。

适用技术与业务范围：

- Java 23 / Spring Boot
- Vue 3 / TypeScript
- React / TypeScript
- Python
- SQL Server
- AI / LLM / Agent / RAG / OCR
- 医疗信息化、医保审核、DRG/DIP

## 目录

```text
AGENTS.md       # 总控和任务路由
agents/         # AI 专业角色
rules/          # 工程与业务规则
workflows/      # 常见研发流程
context/        # 稳定项目上下文
```

## 使用方式

将本仓库作为项目级 AI 规范目录，让 AI 在开始任务前读取 `AGENTS.md`。当任务进入具体领域时，再读取对应 Agent、Rule、Workflow 和 Context。

## 设计原则

- 角色职责与技术规范分离
- 通用规范与项目上下文分离
- 高风险变更必须经过验证与审查
- 最小变更优先
- 可追踪、可复盘、可持续演进

## 与 agency-agents 的关系

`agency-agents` 可以作为外部 Agent 人才库和灵感来源；本仓库承担企业内部适配层。新增 Agent 时优先复用成熟的方法论，再根据本项目技术栈、业务规则和团队习惯进行重写。
