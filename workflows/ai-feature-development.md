# AI Feature Development Workflow

1. `product-manager` 定义 AI 功能目标和非目标。
2. `ai-engineer` 设计模型/Agent 方案。
3. `prompt-engineer` 设计 Prompt 和结构化输出。
4. `rag-engineer`（需要知识库时）。
5. 后端 Agent 接入业务系统。
6. `qa-engineer` 建立评测与回归样本。
7. 医疗场景必须由 `healthcare-domain-expert` 或相关业务 Agent 复核。
8. `code-reviewer` 和 `security-reviewer` 检查生产风险。
