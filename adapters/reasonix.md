# Reasonix 接入指南

## 1. 定位

Reasonix 更适合承担：

- 复杂任务规划
- Research
- Explore
- Review
- Subagent 协作
- 多阶段任务

因此推荐：

```text
AI Development Agency
        ↓
Reasonix
        ↓
Planner / Subagent / Review
        ↓
真实项目
```

## 2. 推荐使用方式

Reasonix 项目中优先让：

```text
AGENTS.md
```

作为项目级总入口。

Agency 的具体 Agent 可以按任务显式引用。

Reasonix 支持使用文件 / 目录作为上下文，因此对于复杂任务，可以按需加载：

```text
agents/backend/java-developer.md
rules/java.md
context/architecture.md
```

不要一开始把整个 `agents/` 目录全部加入上下文。

## 3. 简单任务

例如：

```text
请按照 Java 后端工程师角色完成当前 Bug 修复。

请读取：
- AGENTS.md
- AI Development Agency 的 agents/backend/java-developer.md
- rules/java.md
- 当前相关代码

先定位根因，再修改。
```

## 4. 复杂任务

例如：

> 新增医保审核规则配置模块。

推荐分阶段：

```text
Planner
  ↓
产品 / 需求分析
  ↓
架构
  ↓
数据库
  ↓
Java
  ↓
Vue
  ↓
QA
  ↓
Security
  ↓
Code Review
```

Reasonix 的 Subagent / Worker 负责实际运行这些阶段。

Agency 中的：

```text
agents/
```

负责定义每个角色应该怎么工作。

`workflows/`

负责定义角色之间的协作顺序。

## 5. 推荐组合

复杂 Java 功能：

```text
agents/leadership/ai-tech-lead.md
agents/backend/java-architect.md
agents/backend/java-developer.md
agents/database/sqlserver-dba.md
agents/quality/code-reviewer.md
```

医疗 AI：

```text
agents/healthcare/healthcare-domain-expert.md
agents/healthcare/medical-insurance-reviewer.md
agents/ai/ai-engineer.md
agents/ai/rag-engineer.md
agents/quality/security-reviewer.md
```

## 6. 注意事项

不要因为 Reasonix 有 Subagent，就把 Agency 的每一个 Agent 都永久注册为独立 Subagent。

优先按任务动态选择。

目标是：

```text
有需要才拆
能一个 Agent 做就不要拆
```
