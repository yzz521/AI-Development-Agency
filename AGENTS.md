# AI Development Agency — 总控规则

## 1. 项目定位

AI Development Agency 是一套面向企业软件研发的 **AI 虚拟研发团队定义**。

本仓库不直接提供 Multi-Agent Runtime，而是提供一套可被 Coding Agent / LLM 直接消费的：

- **Agent：谁来干**
- **Rule：怎么干**
- **Workflow：多个角色如何协作**
- **Context：在什么背景下干**

其中最核心的是 `agents/**/*.md`。

每个 Agent 文件都应该可以在脱离其他 Agent 的情况下，直接作为一个完整的角色 Prompt 使用。

---

## 2. 四个核心概念

### 2.1 Agent —— 谁来干

目录：

```text
agents/
```

Agent 是一个专业角色定义。

一个完整 Agent 应该描述：

- 我是谁
- 我的核心职责是什么
- 我擅长什么
- 开始工作前应该读取什么
- 我应该如何工作
- 我如何进行技术 / 业务判断
- 哪些事情禁止做
- 哪些事情不属于我的职责
- 我应该输出什么
- 什么条件下算完成
- 我应该把结果交给谁

例如：

```text
agents/backend/java-developer.md
```

表示：

> Java 后端工程师这个 AI 角色。

---

### 2.2 Rule —— 怎么干

目录：

```text
rules/
```

Rule 是项目统一工程规范。

例如：

```text
rules/java.md
rules/vue.md
rules/react.md
rules/python.md
rules/sqlserver.md
rules/security.md
rules/healthcare.md
```

Rule 解决的是：

> “这个项目做事情必须遵守什么规范？”

例如 Java：

- Java 23
- DTO 作为接口入参
- 禁止 `@PathVariable` 传递业务参数
- 禁止使用 Map 进行业务参数传递
- 禁止魔法值
- MyBatis / MyBatis-Plus 使用规范
- 分页规范
- 安全规范

Agent 不应该把这些规则全部复制进去，而应该按需读取对应 Rule。

---

### 2.3 Workflow —— 怎么协作

目录：

```text
workflows/
```

Workflow 描述多个角色完成一个复杂任务时的协作顺序。

例如：

```text
产品经理
  ↓
需求分析师
  ↓
软件架构师
  ↓
UI 设计师
  ↓
SQL Server 数据库工程师
  ↓
Java 后端工程师
  ↓
Vue 前端工程师
  ↓
QA
  ↓
安全评审
  ↓
代码评审
```

Workflow 解决的是：

> “这个任务应该按照什么顺序完成？”

---

### 2.4 Context —— 在什么背景下干

目录：

```text
context/
```

Context 定义项目中的稳定事实。

例如：

```text
context/project.md
context/technology-stack.md
context/architecture.md
context/domain.md
```

Context 解决的是：

> “这个 AI 到底在什么项目、什么技术体系、什么业务背景里工作？”

这些内容不应该反复复制到每一个 Agent 中。

---

# 3. Agent 的设计原则

## 3.1 每个 Agent 必须可以独立工作

例如：

```text
agents/backend/java-developer.md
```

应该可以单独交给 Coding Agent 使用。

不应该依赖某个“超级总控 Prompt”才能理解自己是谁。

---

## 3.2 Agent 不是职位说明书

不要只写：

```text
你是 Java 开发工程师。
负责开发 Java 系统。
```

这种描述太弱。

一个完整 Agent 应至少包含：

```text
身份
核心使命
专业能力
开始工作前必须读取
工作方法
关键决策原则
硬性约束
明确不负责
标准输出
完成标准
与其他 Agent 协作
沟通风格
```

---

## 3.3 Agent 与 Rule 必须分离

错误方式：

```text
java-developer.md
里面复制一大堆 Java 规范
```

正确方式：

```text
Java Developer Agent
        +
rules/java.md
```

Agent 负责：

> 怎么思考、怎么工作。

Rule 负责：

> 项目规定必须怎么写。

这样 Java 规范只需要维护一份。

---

# 4. Agent 与 Workflow 的边界

Agent：

> 我如何完成自己的工作。

Workflow：

> 多个角色如何完成一项复杂任务。

例如：

```text
Java Developer
```

知道：

- 如何阅读 Java 项目
- 如何实现 Service
- 如何处理 DTO
- 如何写测试
- 如何自检

而：

```text
Feature Development Workflow
```

知道：

- 什么时候找 Product
- 什么时候找 UI
- 什么时候找 DB
- 什么时候找 Java
- 什么时候找 QA
- 什么时候 Review

两者不要混在一起。

---

# 5. 重要边界：本仓库不是 Multi-Agent Runtime

例如：

```text
AGENTS.md
   ↓
读取 java-developer.md
   ↓
读取 vue-developer.md
```

这并不意味着系统一定真的启动了两个独立 Agent。

在 Claude Code、Codex、Cursor 等工具中，可能只是：

```text
同一个 AI
读取多个角色定义
按照 Workflow 依次工作
```

也可能未来通过真正的 Sub-Agent / Agent Runtime：

```text
Agent A
   ↓
Agent B
   ↓
Agent C
```

因此：

> 当前仓库负责“定义 Agent 和研发方法”，不假装自己已经实现 Multi-Agent Runtime。

未来可以在本仓库之上增加真正的运行层。

---

# 6. 接收到任务后的标准流程

```text
用户任务
   ↓
读取 AGENTS.md
   ↓
读取基础 Context
   ↓
判断任务类型
   ↓
判断风险等级
   ↓
选择 Workflow
   ↓
选择 Agent
   ↓
加载 Rules
   ↓
读取真实代码
   ↓
执行任务
   ↓
验证
   ↓
Review
   ↓
最终交付
```

---

# 7. Context 加载原则

默认读取：

```text
context/project.md
context/technology-stack.md
```

需要时再读取：

```text
context/architecture.md
context/domain.md
```

不要每个任务都加载整个 `context/`。

应根据任务选择最小必要上下文。

---

# 8. Agent 选择原则

原则：

> **最小必要角色。**

不要因为任务复杂，就把所有 Agent 都叫进来。

### 产品需求

```text
product-manager
requirements-analyst
```

涉及排期时：

```text
project-manager
```

### UI / UX

```text
ui-designer
ux-designer
```

实现完成后：

```text
design-reviewer
```

### Vue

```text
vue-developer
frontend-reviewer
```

必要时：

```text
design-reviewer
```

### React

```text
react-developer
frontend-reviewer
```

### Java

一般：

```text
java-developer
code-reviewer
```

涉及模块边界、API、事务架构、服务拆分时：

```text
java-architect
software-architect
```

### Python / AI

一般：

```text
python-developer
```

AI 场景：

```text
ai-engineer
prompt-engineer
rag-engineer
```

### 多 Agent

只有真正需要多个独立 Agent 或复杂 Agent 协作时：

```text
multi-agent-architect
```

### SQL Server

一般：

```text
sqlserver-dba
sql-reviewer
```

性能问题：

```text
sqlserver-performance
```

### 医疗业务

根据业务场景：

```text
healthcare-domain-expert
drg-dip-expert
medical-insurance-reviewer
```

### 质量 / 安全

```text
qa-engineer
api-tester
code-reviewer
security-reviewer
```

---

# 9. 风险等级

## L1 —— 小改动

例如：

- 单文件修改
- 简单 Bug
- 小范围 UI 调整
- 低风险代码优化

使用：

```text
相关 Agent
+
对应 Rule
+
最小验证
```

---

## L2 —— 常规功能

例如：

- Vue + Java
- API + SQL
- Python + AI
- 页面 + 接口

要求：

```text
Workflow
+
至少一次 QA 或 Code Review
```

---

## L3 —— 高风险

涉及：

- 数据迁移
- 核心医保规则
- DRG/DIP 核心逻辑
- 权限
- 敏感医疗数据
- 大批量数据
- 生产性能
- 核心 AI 决策
- 核心架构
- 破坏性 API / Schema 变更

必须：

```text
Architecture Review
+
Implementation
+
QA
+
Security Review（适用时）
+
Code Review
+
Rollback Plan
+
Validation Evidence
```

---

# 10. 全局硬规则

1. 先读代码，再修改。
2. 禁止凭空假设现有项目结构。
3. 默认最小修改。
4. 禁止借任务名义进行无关重构。
5. 不擅自替换现有技术栈。
6. 不使用 Map 代替明确业务对象。
7. 不使用魔法值。
8. 数据库变更必须考虑：
   - 数据量
   - 索引
   - 锁
   - 事务
   - 回滚
   - 兼容性
9. 医疗业务必须区分：
   - 正式政策 / 正式规则
   - 项目业务事实
   - 模型推断
10. 不把模型生成内容当成正式医保政策原文。
11. 敏感医疗数据默认遵守：
   - 最小权限
   - 脱敏
   - 审计
   - 数据最小化
12. 外部接口应考虑：
   - 超时
   - 异常
   - 重试
   - 幂等
13. 完成任务必须说明：
   - 改了什么
   - 为什么
   - 怎么验证
   - 还有什么风险

---

# 11. Agent 输出要求

所有开发 / 分析类 Agent 最终至少说明：

```text
任务：
结论：

关键变更：
- ...

涉及文件：
- ...

验证：
- ...

风险：
- ...

回滚：
- ...

下一步：
- ...
```

Review 类 Agent 至少说明：

```text
结论：
Blocker：
Major：
Minor：

证据：

建议：

是否通过：
PASS / REWORK
```

---

# 12. Review 原则

Review 关注：

1. 正确性
2. 安全性
3. 数据完整性
4. API 兼容性
5. 性能
6. 可维护性
7. 测试覆盖
8. Rule 遵循情况

不要因为：

- 个人代码风格
- 个人框架偏好
- 可有可无的重构

随意阻塞任务。

---

# 13. 学习与演进

发现重复问题时：

优先修改：

```text
rules/
workflows/
validation/
```

其次再考虑：

```text
agents/
```

不要因为一个问题就不断新增 Agent。

Agent 数量不是体系成熟度的指标。

真正重要的是：

> Agent 能不能稳定完成任务。

---

# 14. 最终交付

每项任务最终至少汇报：

```text
任务：
任务级别：
使用 Agent：
使用 Workflow：
关键变更：
涉及文件：
验证方式：
验证结果：
风险：
回滚方案：
未完成事项：
```
