# Codex 接入指南

## 1. 定位

Codex 作为主要 Coding Agent 时：

> **Codex 负责执行代码任务，AI Development Agency 负责提供角色、规则、工作流和项目上下文。**

## 2. 推荐结构

中央 Agency：

```text
~/ai/AI-Development-Agency/
├── AGENTS.md
├── agents/
├── rules/
├── workflows/
├── context/
├── contracts/
├── artifacts/
└── validation/
```

实际项目：

```text
your-project/
├── AGENTS.md
├── src/
└── ...
```

## 3. 项目 AGENTS.md

项目根目录的 `AGENTS.md` 是进入项目后的第一入口。

它应该告诉 Codex：

1. 当前项目是什么。
2. 使用什么技术。
3. Agency 在哪里。
4. 当前项目优先使用哪些 Agent / Rule。
5. 如何运行测试和构建。
6. 有哪些项目特殊约束。

不要把整个 Agency 复制进项目。

## 4. 推荐启动方式

进入项目：

```bash
cd /path/to/your-project
codex
```

开始任务时可以直接：

```text
先读取项目根目录 AGENTS.md。
根据任务类型选择 AI Development Agency 中最小必要的 Agent 和 Rule。
先阅读现有代码，再修改。
完成后运行项目要求的验证。
```

## 5. Java 任务示例

```text
请按照 AI Development Agency 的 Java 后端工程师角色完成：

新增“医保审核规则配置”的查询接口。

要求：
1. 先分析现有代码。
2. 使用项目已有 DTO / Service / Mapper 模式。
3. 遵守 rules/java.md。
4. 如果涉及数据库，再读取 SQL Server Agent 和规则。
5. 完成后补测试并进行代码自检。
```

推荐加载：

```text
agents/backend/java-developer.md
rules/java.md
```

复杂任务再增加：

```text
agents/backend/java-architect.md
agents/database/sqlserver-dba.md
agents/healthcare/medical-insurance-reviewer.md
```

## 6. 原则

不要每个任务都加载全部 Agent。

优先：

```text
任务
 ↓
最小必要 Agent
 ↓
对应 Rule
 ↓
真实代码
```
