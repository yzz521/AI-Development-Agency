# DeepSeek Harness 接入指南

## 1. 定位

DeepSeek Harness 更适合作为：

- DeepSeek 模型调用层
- Tool / MCP 能力层
- Agent 能力承载层
- 本地或自定义 AI 工作流的基础设施

推荐架构：

```text
AI Development Agency
        ↓
Agent Prompt / Rule / Workflow / Evolution
        ↓
DeepSeek Harness
        ↓
DeepSeek Model + Tools / MCP
        ↓
真实项目
```

## 2. 日常使用（每次会话）

在 DeepSeek Harness 中开始任何项目任务前：

1. 读取项目 `AGENTS.md`（项目会声明 `.ai/agency` 稳定入口）。
2. 读取 `.ai/agency/AGENTS.md`（总控规则）。
3. 用 `agency use <agent>` 或直接读取 `agents/<domain>/<role>.md` 加载角色。
4. 按角色"开始工作前必须读取"清单加载 `rules/` 与 `context/`。
5. 执行任务，最终汇报必须包含"规则反馈"（`kind / 证据 / 提案`）。

任务完成后（自进化闭环）：

- 用 `agency feedback --kind <type> --detail "..." --project <项目> --rule <规则>` 记录反馈。
- 发现规则缺口时用 `agency propose --type <type> --title "<标题>" --evidence "..."` 创建提案。
- 每周用 `agency review` 生成本轮评审简报，交由 agency-curator 处理。

## 3. 具体示例（Javert 项目）

```text
项目: javert（Java 23 / Spring Boot / SQL Server / Vue 3）
入口: AGENTS.md → .ai/agency/AGENTS.md
角色: .ai/agency/agents/backend/java-developer.md
规则: .ai/agency/rules/java.md + rules/sqlserver.md + rules/global.md
流程: workflows/feature-development.md（或 bug-fixing.md）
进化: 完成后 agency feedback 记录规则使用反馈
```

## 2. 核心原则

不要把：

```text
AI Development Agency
```

改造成 DeepSeek Harness 专属 Prompt 格式。

应该保持：

```text
Agency = 通用角色定义
Harness = 运行与工具能力
```

这样以后替换模型或运行框架时，不需要重新设计 Agent。

## 3. 推荐加载顺序

一个开发任务：

```text
AGENTS.md
  ↓
Agent Definition
  ↓
Rule
  ↓
Context
  ↓
Code
```

例如 Java：

```text
agents/backend/java-developer.md
rules/java.md
context/technology-stack.md
```

## 4. Tool / MCP

当任务需要：

- Git
- 数据库
- 文件系统
- API
- 企业内部 MCP

建议：

```text
Agent
  ↓
Tool / MCP
```

而不是把工具使用说明大量复制到每个 Agent。

工具能力属于 Harness / Runtime。

角色决策属于 Agency。

## 5. 注意事项

医疗场景不要因为模型可以调用工具，就允许 Agent：

- 自动修改生产数据库
- 自动执行破坏性 SQL
- 自动发布
- 绕过人工审批

高风险操作必须受到项目权限和安全机制约束。
