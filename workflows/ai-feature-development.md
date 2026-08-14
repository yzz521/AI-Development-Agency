# AI Feature Development Workflow v1.1

## Scope
LLM、Agent、RAG、OCR、模型调用、AI 决策链路。

## Stages
1. `product-manager`
2. `requirements-analyst`
3. `ai-engineer`
4. `prompt-engineer`（提示词 / 结构化输出）
5. `rag-engineer`（RAG）
6. `python-developer` / `java-developer`
7. `qa-engineer`
8. `security-reviewer`
9. `code-reviewer`
10. `ai-tech-lead`

## Required
- 模型输入输出定义
- Prompt / Tool Contract
- Failure / Fallback
- Evaluation / Test Dataset
- Sensitive Data Handling
- Hallucination Risk
- Cost / Latency considerations

## Medical AI
涉及医疗判断时，必须把模型输出和正式规则 / 政策依据分离，并明确最终人工或规则引擎责任边界。
