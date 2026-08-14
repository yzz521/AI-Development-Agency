# AI Development Agency

面向企业软件研发的 AI 虚拟团队定义仓库。

本版本在原有 Agent / Rule / Workflow / Context 四层结构基础上，加入：

- 标准 Agent Contract
- 标准 Workflow Contract
- 标准 Artifact Contract
- Task Contract
- 交付物模板
- Definition of Done
- Validation 规则
- Agent 生命周期与协作文档

## 核心模型

```text
AGENTS.md
   ↓
任务识别
   ↓
Workflow
   ↓
Agent
   ↓
Rules + Context
   ↓
Artifact
   ↓
QA / Security / Review
   ↓
Validation
   ↓
Final Result
```

## 使用

将本仓库作为项目级 AI 研发规范目录。

AI 在接到任务后：
1. 读取 `AGENTS.md`
2. 选择 Workflow
3. 加载必要 Agent
4. 加载对应 Rules / Context
5. 按 Artifact Contract 交接
6. 进行 QA / Review / Validation
7. 形成最终交付摘要

## 技术范围

- Java 23 / Spring Boot
- Vue 3 / TypeScript
- React / TypeScript
- Python
- SQL Server
- AI / LLM / Agent / RAG / OCR
- 医疗信息化
- 医保审核
- DRG / DIP

## 设计原则

- 角色、规则、流程、上下文分离
- 最小必要上下文
- 可验证交付
- 失败可回退
- 高风险变更可追踪
- 通用能力与项目事实分离
