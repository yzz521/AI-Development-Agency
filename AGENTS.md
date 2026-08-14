# AI Development Agency — 总控规则 v1.1

## 1. 定位

本仓库是一套“AI 软件研发团队定义”，由以下四层组成：

- **Agent**：谁来干。
- **Rule**：怎么干。
- **Workflow**：按什么顺序干。
- **Context**：在什么背景下干。

`AGENTS.md` 是任务入口与路由规则，不是业务代码，也不是运行时框架。

## 2. 执行原则

收到任务后，先执行“任务识别”，再选择最小必要流程与 Agent。

必须遵循：

1. 先读当前代码、配置、测试和相关上下文，禁止凭空假设。
2. 先判断风险级别，再决定是否需要架构、数据库、安全和完整回归。
3. 只加载与任务相关的 Agent / Rule / Context，避免无意义地塞入全部知识。
4. Agent 之间必须通过标准 Artifact 交接，不得只依赖自然语言上下文。
5. 任何实现类 Agent 都必须有验证步骤。
6. Review / QA 失败时进入 REWORK，不得直接宣布完成。
7. 高风险任务必须有回滚策略。
8. 默认最小改动，禁止借任务名义进行无关重构。

## 3. 任务分级

### L1 — 小改动

单文件、低风险、不改变数据结构、不改变公共 API。

执行：
- 相关 Agent
- 相关 Rule
- 最小验证

### L2 — 常规功能

涉及多个文件或两个以上技术层次，例如前端 + 后端、接口 + 数据库。

执行：
- 主 Workflow
- 至少一次 QA 或 Code Review
- 必要时 Architecture Review

### L3 — 高风险

涉及以下任一情况：

- 数据迁移
- 核心医保 / DRG / DIP 规则
- 鉴权与敏感数据
- 大批量数据
- 生产性能
- 核心 AI 决策链路
- 破坏性 API / Schema 变化

必须：
- Architecture Review
- Implementation
- QA
- Security Review（适用时）
- Code Review
- Rollback Plan
- 明确验证证据

## 4. Agent 路由

| 任务 | 主 Agent | 可选 Agent |
|---|---|---|
| 产品需求 | product-manager | requirements-analyst, project-manager |
| UI / UX | ui-designer | ux-designer, design-reviewer |
| Vue | vue-developer | frontend-reviewer |
| React | react-developer | frontend-reviewer |
| Java | java-developer | java-architect, code-reviewer |
| Python | python-developer | api-designer, code-reviewer |
| AI / LLM | ai-engineer | prompt-engineer, rag-engineer |
| 多 Agent | multi-agent-architect | ai-tech-lead |
| SQL Server | sqlserver-dba | sqlserver-performance, sql-reviewer |
| 医疗 | healthcare-domain-expert | drg-dip-expert, medical-insurance-reviewer |
| 测试 | qa-engineer | api-tester |
| 安全 | security-reviewer | sql-reviewer, code-reviewer |
| 架构 | software-architect | ai-tech-lead |
| 代码理解 | codebase-onboarding | 对应领域 Agent |
| 总控 | ai-tech-lead | 所有领域 Agent |

## 5. 标准执行状态

所有 Workflow 任务统一使用：

`PENDING → ANALYZING → IN_PROGRESS → WAITING_REVIEW → PASS → DONE`

失败：

`FAILED → REWORK → IN_PROGRESS`

阻塞：

`BLOCKED`

规则：
- 没有验证证据不得进入 `PASS`。
- Reviewer / QA 出现 blocker 时必须进入 `REWORK`。
- `DONE` 必须有最终交付摘要。

## 6. 标准交接

Agent 完成后必须产出至少一个 Artifact，格式遵循：

`contracts/artifact-contract.md`

最少包含：
- 任务
- 输入
- 修改 / 决策
- 输出文件
- 验证方式
- 风险
- 下一 Agent
- 未完成事项

## 7. Rules 加载

默认：

1. `rules/global.md`
2. 当前领域 Rule
3. `rules/security.md`（敏感 / 高风险时）
4. `rules/healthcare.md`（医疗业务时）

技术领域映射：

- Java → `rules/java.md`
- Vue → `rules/vue.md`
- React → `rules/react.md`
- Python → `rules/python.md`
- AI → `rules/ai.md`
- SQL Server → `rules/sqlserver.md`
- 医疗 → `rules/healthcare.md`

## 8. Context 加载

默认读取：
- `context/project.md`
- `context/technology-stack.md`

需要时再读取：
- `context/architecture.md`
- `context/domain.md`

任务特定资料放在项目实际工作目录，不污染稳定 Context。

## 9. 冲突优先级

1. 用户当前明确需求
2. 当前项目现有架构与兼容性
3. `rules/*.md`
4. Workflow
5. Agent 偏好
6. 通用最佳实践

无法同时满足时，选择更安全、可验证、可回滚的方案，并记录冲突。

## 10. 最终交付

最终至少汇报：

```text
任务：
任务级别：
Workflow：
涉及 Agent：
涉及 Artifact：
关键变更：
验证方式：
验证结果：
风险：
回滚方案：
未完成事项：
```
