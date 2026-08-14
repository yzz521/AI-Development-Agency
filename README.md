# AI Development Agency

> 面向企业软件研发的 AI 虚拟团队定义仓库

一套以 Markdown 为载体的 AI 研发角色库、工程规范库、协作流程库和项目上下文库。

项目借鉴 `agency-agents` 的 Agent-as-Markdown 思路，但并不直接复制其完整 Agent 库，而是针对实际企业研发场景进行定制。

当前重点适配：

- Java 23 / Spring Boot
- Vue 3 / TypeScript
- React / TypeScript
- Python
- SQL Server
- AI / LLM / Agent / RAG / OCR
- 医疗信息化
- 医保审核
- DRG / DIP

---

# 1. 项目到底是什么？

简单来说：

> **这是一个 AI 软件研发团队的人才库 + 工作规范库。**

不是一个传统 Java / Python 软件项目。

也不是一个已经完成的 Multi-Agent Runtime。

它更接近：

```text
                  AI Development Agency
                           │
          ┌────────────────┼────────────────┐
          ↓                ↓                ↓
        Agent             Rule           Context
       谁来干             怎么干        在什么背景
          │
          ↓
       Workflow
    多个角色如何协作
```

---

# 2. 四个核心概念

## Agent —— 谁来干

目录：

```text
agents/
```

一个 Agent 就是一个专业 AI 角色。

例如：

```text
agents/backend/java-developer.md
agents/frontend/vue-developer.md
agents/database/sqlserver-dba.md
agents/design/ui-designer.md
agents/product/product-manager.md
```

每个 Agent 都可以独立使用。

一个完整 Agent 包含：

```text
身份
核心使命
专业能力
工作前需要读取的内容
工作方法
关键决策原则
硬性约束
不负责什么
标准输出
完成标准
协作方式
沟通风格
```

因此它不是简单的：

> “你是一名 Java 工程师。”

而是一套可以直接交给 Coding Agent 使用的角色 Prompt。

---

# 3. Rule —— 怎么干

目录：

```text
rules/
```

Rule 是项目统一工程标准。

例如：

```text
rules/java.md
rules/vue.md
rules/react.md
rules/python.md
rules/sqlserver.md
rules/ai.md
rules/healthcare.md
rules/security.md
```

例如 Java Rule 定义：

```text
Java 23
Controller DTO
禁止 @PathVariable 传业务参数
禁止 Map
禁止魔法值
MyBatis / MyBatis-Plus 规范
分页规范
安全规范
```

Agent 不应该复制这些内容。

正确方式是：

```text
Java Developer Agent
        +
rules/java.md
```

这样规则只需要维护一份。

---

# 4. Workflow —— 如何协作

目录：

```text
workflows/
```

Workflow 描述复杂任务的研发路径。

例如新功能：

```text
产品
 ↓
需求分析
 ↓
架构
 ↓
UI
 ↓
数据库
 ↓
后端
 ↓
前端
 ↓
QA
 ↓
安全
 ↓
代码评审
```

Workflow 解决的问题是：

> “这项工作应该由谁先做、谁后做？”

---

# 5. Context —— AI 在什么背景下工作

目录：

```text
context/
```

Context 保存项目稳定事实。

例如：

```text
context/project.md
context/technology-stack.md
context/architecture.md
context/domain.md
```

用于告诉 AI：

```text
这个项目是什么
使用什么技术
采用什么架构
属于什么业务领域
```

---

# 6. 当前目录结构

```text
AI-Development-Agency/
│
├── AGENTS.md
├── README.md
│
├── agents/
│   ├── leadership/
│   ├── product/
│   ├── design/
│   ├── frontend/
│   ├── backend/
│   ├── ai/
│   ├── database/
│   ├── healthcare/
│   └── quality/
│
├── rules/
├── workflows/
├── context/
├── contracts/
├── artifacts/
├── validation/
└── docs/
```

---

# 7. Agent 分类

当前包含以下主要角色。

## 产品

```text
产品经理
需求分析师
项目经理
```

## 设计

```text
UI 设计师
UX 设计师
设计评审师
```

## 前端

```text
Vue 前端工程师
React 前端工程师
前端代码评审师
```

## 后端

```text
Java 后端架构师
Java 后端工程师
Python 工程师
API 设计师
```

## AI

```text
AI 工程师
提示词工程师
RAG 工程师
多 Agent 架构师
```

## 数据库

```text
SQL Server 数据库工程师
SQL Server 性能工程师
SQL 评审师
```

## 医疗

```text
医疗信息化业务专家
DRG/DIP 业务专家
医保审核专家
```

## 质量

```text
质量保证工程师
API 测试工程师
代码评审师
安全评审师
```

## 总控

```text
AI 技术负责人
软件架构师
代码库分析师
```

---

# 8. 最简单的使用方式

不需要一开始就使用整个虚拟团队。

## 修改 Java

加载：

```text
AGENTS.md
agents/backend/java-developer.md
rules/global.md
rules/java.md
context/project.md
context/technology-stack.md
```

然后让 Coding Agent 执行任务。

---

## 修改 Vue

加载：

```text
AGENTS.md
agents/frontend/vue-developer.md
rules/global.md
rules/vue.md
context/project.md
context/technology-stack.md
```

---

## 优化 SQL Server

加载：

```text
AGENTS.md
agents/database/sqlserver-performance.md
rules/global.md
rules/sqlserver.md
context/project.md
context/technology-stack.md
```

---

# 9. 复杂功能怎么做？

例如：

> 新增一个医保审核规则配置模块。

可以按照：

```text
                  AI 技术负责人
                       │
                       ↓
                    产品经理
                       │
                       ↓
                   需求分析师
                       │
                       ↓
                  软件架构师
                       │
            ┌──────────┼──────────┐
            ↓          ↓          ↓
          UI设计      数据库      后端
            │          │          │
            │       SQL Server   Java
            │          │          │
            └──────────┼──────────┘
                       ↓
                    Vue 前端
                       ↓
                       QA
                       ↓
                    安全评审
                       ↓
                    代码评审
```

这些角色可以：

1. 真正作为多个独立 Agent 运行；
2. 也可以由同一个 Coding Agent 按角色顺序执行。

当前仓库不强制绑定具体 Runtime。

---

# 10. 为什么不做成一个超级 Prompt？

不推荐：

```text
一个巨大的 Prompt
+
Java
+
Vue
+
SQL Server
+
Python
+
医疗
+
AI
+
QA
```

因为：

- 上下文太大
- 角色边界不清
- 技术规则容易互相污染
- 修改规范时很难维护
- 很难单独测试一个角色

因此采用：

```text
Agent
+
Rule
+
Workflow
+
Context
```

进行拆分。

---

# 11. 为什么 Agent 还要独立存在？

即使没有真正的 Multi-Agent Runtime：

```text
agents/backend/java-developer.md
```

也可以直接使用。

这保证了：

```text
单 Agent
```

模式可以正常工作。

未来再增加：

```text
Multi-Agent Runtime
```

时，只需要把多个 Agent 编排起来，而不需要重新设计 Agent 本身。

---

# 12. 本仓库不是什么？

## 不是完整的 Multi-Agent Runtime

当前仓库主要负责：

```text
Agent Definitions
Rules
Workflows
Context
Contracts
Artifacts
Validation
```

不负责：

- 模型调度
- Agent 进程管理
- Token 管理
- Agent 间消息传递
- 分布式任务调度
- 长期运行的 Agent Runtime

这些属于未来的运行层。

---

# 13. 与 agency-agents 的关系

本项目借鉴：

`msitarzewski/agency-agents`

重点借鉴：

```text
Agent-as-Markdown
角色定义
专业化角色
角色工作流程
角色交付物
角色行为规范
```

但不会简单复制整个 Agent 库。

本项目更关注：

```text
企业软件研发
Java
Vue
React
Python
SQL Server
AI
医疗
医保审核
DRG/DIP
```

目标是形成自己的企业研发 AI 角色体系。

---

# 14. 项目设计原则

## 角色与规则分离

```text
Agent = 谁 + 如何工作
Rule = 项目必须遵守什么
```

## 通用知识与项目事实分离

```text
Agent / Rule
    +
Context
```

## 最小必要上下文

不要每次任务都加载全部 Agent。

## 最小变更

不为了体现 AI 能力而重构无关代码。

## 可验证

每个 Agent 都应该有明确的完成标准。

## 可复盘

发现重复问题时，优先沉淀为 Rule / Workflow / Validation。

---

# 15. 下一阶段重点

项目不会无限增加 Agent。

下一阶段重点是：

## 1. Agent 评测

建立真实任务测试集：

```text
Java
Vue
SQL Server
AI
医疗
```

验证：

```text
任务完成度
规范遵守
代码质量
测试完整性
上下文理解
```

---

## 2. Agent 边界

逐渐补充：

```text
适用条件
触发条件
退出条件
交接对象
```

避免多个 Agent 职责重叠。

---

## 3. Context 演进

随着业务增加，Context 会逐步按领域拆分：

```text
context/
├── project.md
├── technology-stack.md
├── architecture.md
├── domain/
│   ├── medical.md
│   ├── drg-dip.md
│   └── insurance-review.md
└── modules/
```

---

## 4. Rule 版本化

对于医疗、医保、DRG/DIP 等会变化的规则，需要逐步支持：

```text
规则版本
生效时间
适用地区
规则来源
当前状态
```

避免不同版本规则混用。

---

## 5. Coding Agent 适配

未来可以针对：

```text
Claude Code
Codex
Cursor
Gemini CLI
OpenCode
```

分别增加轻量 Adapter。

但不会让核心 Agent 定义依赖某个具体工具。

---

## 6. 真正的 Multi-Agent Runtime

当 Agent 定义、Rules、Workflow 和评测体系稳定后，再考虑实现：

```text
Task Router
      ↓
Agent Scheduler
      ↓
Context Manager
      ↓
Artifact Manager
      ↓
Review Loop
      ↓
Evaluation
```

真正做到：

```text
用户一句话
   ↓
自动识别任务
   ↓
自动选择 Agent
   ↓
自动执行 Workflow
   ↓
自动 Review
   ↓
自动验证
```

---

# 16. 最终目标

最终希望形成：

```text
                       用户需求
                          │
                          ↓
                    AI 技术负责人
                          │
                    Task Router
                          │
                    Workflow Engine
                          │
        ┌─────────────────┼─────────────────┐
        ↓                 ↓                 ↓
      Product           Design           Engineering
        │                 │                 │
        └─────────────────┼─────────────────┘
                          ↓
                  Backend / Frontend
                          │
                 ┌────────┴────────┐
                 ↓                 ↓
              Database             AI
                 │                 │
                 └────────┬────────┘
                          ↓
                          QA
                          ↓
                       Security
                          ↓
                       Review
                          ↓
                    Validation
                          ↓
                       Delivery
```

最终不是：

> “AI 帮我写代码。”

而是：

> **“AI 像一个完整的软件研发团队一样协助我完成软件交付。”**

---

# 17. 当前版本

当前版本：

```text
v1.2
```

核心能力：

```text
✅ 中文 Agent 定义
✅ Agent 独立可用
✅ Java / Vue / React / Python
✅ SQL Server
✅ AI / RAG / Prompt
✅ 医疗 / 医保 / DRG / DIP
✅ Product / Design / QA / Security
✅ Rules
✅ Workflows
✅ Context
✅ Contracts
✅ Artifacts
✅ Validation
```

当前阶段重点不是继续增加 Agent 数量，而是：

> **验证现有 Agent 是否真的能稳定完成真实研发任务。**
