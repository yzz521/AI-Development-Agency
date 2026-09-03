# AI Rules

## 摘要（注入用）

- 模型输出不是事实，尤其是政策、外部知识和未引用的数字。
- Prompt 写清角色、上下文、输入、约束、输出格式和失败处理。
- Agent 任务尽量单一、可验证；Structured Output 优先。
- 生产链路要有超时、重试、fallback、成本与日志；RAG 评估召回、引用、chunk 与重排序。
- 若进入医疗/医保链路，加读 `rules/healthcare.md`，不得静默覆盖确定性业务规则。

## 全文

1. 模型输出不是事实。
2. Prompt 必须明确角色、上下文、输入、约束、输出格式和失败处理。
3. Agent 任务要尽量单一、可验证。
4. Structured Output 优先于自由文本。
5. 生产链路必须有超时、重试、fallback、成本和日志策略。
6. RAG 必须评估召回质量、引用来源、chunk 策略和重排序。
7. 涉及医疗、医保时必须同时遵守 `rules/healthcare.md`。
