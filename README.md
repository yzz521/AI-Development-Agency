# AI Development Agency

> 面向企业软件研发的 AI 虚拟研发团队规范库。  
> 当前版本：**v1.7.0**

AI Development Agency 不是新的 AI Coding Runtime，也不是把多个 Agent 强行绑定在一起的框架。

它是一套可以被 **Cursor、Codex、Reasonix、DeepSeek Harness** 等 AI Coding 工具共同使用的“AI 研发团队规范”：把研发岗位、技术规则、工作流程和项目背景整理成结构化 Markdown，让 AI 在真实项目中按照统一方法完成研发工作。

## 1. 核心理念

把软件研发拆成六个核心维度：

| 层次      | 解决的问题     | 目录                  |
| --------- | -------------- | --------------------- |
| Agent     | 谁来做         | `agents/`             |
| Rule      | 怎么做         | `rules/`              |
| Workflow  | 按什么顺序做   | `workflows/`          |
| Context   | 在什么背景下做 | `context/`            |
| Evolution | 怎么进化       | `evolution/` + `rules/evolution.md` |
| Skill     | 轻量场景即调即走 | `skills/`            |

核心关系：

```text
任务（直接下，不必先跑命令）
 ↓
规范路由（AGENTS.md / Cursor 规则 / agency-route 技能）
 ↓
注入命中规则的摘要
 ↓
读取真实项目代码
 ↓
实现
 ↓
测试 / Review
 ↓
汇报结果（含规则反馈）
```

所以本仓库不是简单的 Prompt 集合，而是一套可复用的 AI 研发角色与研发流程规范。

## 2. 重要边界

**当前仓库不是 Multi-Agent Runtime。**

`AGENTS.md` 和各 Markdown 文件负责：

- 定义角色
- 定义研发规则
- 定义工作流程
- 定义项目上下文
- 指导 AI 如何选择和使用这些内容

但：

> “读取多个 Markdown 文件”不等于运行时已经真正启动多个独立 Agent。

真正的 Agent 调度、Subagent 并行和任务编排由具体 AI Coding 工具负责。

当前版本优先保证：

> **每一个 Agent 单独加载，也能够完成自己的工作。**

未来如果需要，再根据具体 Runtime 能力增加编排层，而不是让核心 Agent 与某一个工具绑定。

## 3. 仓库结构

```text
AI-Development-Agency/
│
├── AGENTS.md                 # 总控规则 / AI 入口
├── agents/                   # AI 研发岗位
│   ├── ai/                   # AI / Prompt / RAG / Multi-Agent
│   ├── backend/              # Java / Python / API
│   ├── database/             # SQL Server / SQL Review
│   ├── design/               # UI / UX / Design Review
│   ├── frontend/             # Vue / React / 前端 Review
│   ├── healthcare/           # 医疗 / DRG-DIP / 医保审核
│   ├── leadership/           # Tech Lead / 架构 / 项目理解
│   ├── product/              # 产品 / 需求 / 项目管理
│   └── quality/              # QA / 测试 / Review / Security
│
├── rules/                    # 通用技术与研发规则
├── workflows/                # 常见研发流程
├── context/                  # 项目与技术背景
├── adapters/                 # Codex / Reasonix / DeepSeek Harness
├── contracts/                # Agent / Workflow 输出约定
├── artifacts/                # 标准研发产物
├── validation/               # 验证与质量检查（scripts/validate.sh 门禁）
├── evolution/                # 规则自进化（feedback / proposals / archive / metrics）
├── routes/                   # 任务/文件 → 规范 的单一路由表
├── checks/                   # 增量门禁规则表（catalog.tsv）
├── skills/                   # 场景技能层（agency-route / agency-check）
├── scripts/                  # 工具链：agency CLI + 初始化 / 校验 / 进化脚本
├── templates/                # 项目 AGENTS.md / hook / CI / 提案等模板
├── docs/                     # 使用手册、规则清单、批量初始化、团队推广方案、载体归属迁移清单
├── CHANGELOG.md              # 规则版本变更记录
└── .github/                  # CI（validate.yml 规范守门）
```

## 4. 快速开始（30 秒）

```bash
# 1) 安装 agency 命令到 PATH（~/.local/bin 或 ~/bin）
./scripts/install-cli.sh

# 2) 把本规范接入你的项目（.ai/agency 软链接 + 项目 AGENTS.md，已有不覆盖）
agency init ~/workspace/你的项目

# 3) 接入时写入「提示词自动路由」（AGENTS.md 段 + Cursor 规则 + 技能，均可提交）
#    之后直接对 AI 下任务即可，不必先记 agency use / agency route
agency init ~/workspace/你的项目

# 4) 可选：检查这次任务会命中哪些摘要
agency route --task "给审核加一个查询接口" --files Foo.java

# 5) 可选、单独执行：增量门禁（hook + CI，不绑进 init）
agency check --install ~/workspace/你的项目

# 6) 有规则缺口时才记反馈（不要每次 rule_applied 走流程）
agency feedback --kind rule_gap --detail "遇到的问题"
```

> 完整日常用法见 `docs/日常使用手册.md`（含「怎么知道规范有没有被用到」和「门禁怎么做」）；校验规范库用 `agency validate`。
> 当前有哪些硬规则、想删哪些，见 `docs/规则清单.md`。增量门禁见 `agency check` / `contracts/check-contract.md`。

## 5. 当前覆盖的角色

### 产品

- Product Manager
- Requirements Analyst
- Project Manager

### UI / UX

- UI Designer
- UX Designer
- Design Reviewer

### 前端

- Vue Developer
- React Developer
- Frontend Reviewer

### 后端

- Java Architect
- Java Developer
- Python Developer
- API Designer

### AI

- AI Engineer
- Prompt Engineer
- RAG Engineer
- Multi-Agent Architect

### 数据库

- SQL Server DBA
- SQL Server Performance
- SQL Reviewer

### 医疗

- Healthcare Domain Expert
- DRG/DIP Expert
- Medical Insurance Reviewer

### 质量 / 架构

- QA Engineer
- API Tester
- Code Reviewer
- Security Reviewer
- AI Tech Lead
- Software Architect
- Codebase Onboarding
- Agency Curator（规范自进化评审）

完整角色以 `agents/` 目录实际文件为准。

## 6. 当前支持的 AI Coding 工具

通过 `adapters/` 提供接入说明，目前包括：

- **Cursor**
- **Codex**
- **Reasonix**
- **DeepSeek Harness**

统一关系：

```text
                 AI Development Agency
                           │
     ┌──────────┬──────────┼──────────┬──────────┐
     ↓          ↓          ↓          ↓          ↓
  Cursor     Codex     Reasonix  DeepSeek    其它读
     │          │          │      Harness   AGENTS.md
     └──────────┴──────────┴──────────┴──────────┘
                           ↓
                  同一张 routes/table.tsv
```

**工具是运行层，Agency 是规范层。**

不要为了适配某一个工具，把完整 Agent Prompt 复制到工具自己的配置目录中。

## 7. 如何接入真实项目

推荐采用：

> **中央 Agency + 项目级 `AGENTS.md` + `.ai/agency` 稳定入口**

例如：

```text
~/workspace/
│
├── AI-Development-Agency/
│
├── project-a/
│   ├── AGENTS.md
│   └── .ai/
│       └── agency -> ../../AI-Development-Agency
│
├── project-b/
│   ├── AGENTS.md
│   └── .ai/
│       └── agency -> ../../AI-Development-Agency
│
└── project-c/
    ├── AGENTS.md
    └── .ai/
        └── agency -> ../../AI-Development-Agency
```

项目统一通过：

```text
.ai/agency/
```

访问中央 Agency。

**不要在项目 `AGENTS.md` 中写死中央仓库的绝对路径。**

这样移动整个 workspace、换目录或者换电脑时，不需要重新修改大量路径。

## 8. 项目级 AGENTS.md 的职责

中央 Agency 负责通用规范，项目自己的 `AGENTS.md` 负责项目特有信息：

```text
项目 AGENTS.md
│
├── 项目是什么
├── 当前技术栈
├── 项目特殊规则
├── 构建 / 测试命令
├── 数据库说明
└── .ai/agency 入口
```

不要把中央 Agency 的所有规则复制进每个项目。

推荐关系：

```text
中央 Agency
    ↓
通用 Agent / Rule / Workflow
    ↓
项目 AGENTS.md
    ↓
真实项目代码
```

## 9. 一个典型任务

例如：

> 给现有 Java 医保审核系统增加一个规则查询接口。

用户**直接说这句话**。不要先输入 `agency use`。

工具自动：读项目 `AGENTS.md` 路由段 → 命中 Java + 医保摘要 → 再读代码 → 实现。

若要人工核对命中了什么：

```bash
agency route --task "给现有 Java 医保审核系统增加一个规则查询接口" --files Foo.java
```

对于简单任务，不需要强行加载所有 Agent。

核心原则：

> **选择最小必要 Agent，而不是 Agent 越多越好。**

## 10. 风险等级

### L1 — 低风险

- 单文件修改
- 小范围 Bug 修复
- 不改变公共 API
- 不改变数据库 Schema

使用对应 Agent + Rule + 最小验证即可。

### L2 — 中风险

- 跨模块开发
- 前后端联动
- 多技术层修改
- 较大范围重构

需要 Workflow，并至少进行一次 QA 或 Code Review。

### L3 — 高风险

- 数据库迁移
- 核心医保规则
- 权限系统
- 敏感医疗数据
- 大批量数据处理
- 核心 AI 决策
- 核心架构调整

根据实际情况增加：

- Architecture Review
- QA
- Security Review
- Code Review
- Rollback 方案
- 验证证据

## 11. 全局研发原则

与总控 `AGENTS.md` §6 一致（常驻红线）。语言/领域细则走规范路由。

1. 先理解现有系统再修改；不凭空假设已有结构。
2. 保持最小变更面；禁止无关重构；不擅自替换技术栈。
3. 不删除或覆盖未知用途的代码、配置、数据。
4. 密钥不进源码、不进日志；外部输入不可信；SQL 必须参数化；API 必须认证、授权和输入校验。
5. 关键逻辑必须有可验证路径；数据与日志最小必要。
6. 有意简化必须 `agency: <上限>, <升级路径>` 留痕。
7. 完成后说明改了什么、为什么、怎么验证、还有什么风险。
8. 规范库自身的任务必须记规则反馈；业务仓库建议记录，不强制每次。

## 12. 三种工具怎么分工

### Codex

更适合：

- 日常编码
- Bug 修复
- 重构
- 测试
- Code Review
- 多文件代码修改

进入具体项目后，让 Codex 读取项目 `AGENTS.md`，再按任务加载 Agency 中的 Agent / Rule / Workflow。

### Reasonix

更适合：

- 复杂任务分析
- 任务拆解
- Subagent 协作
- 复杂代码理解
- Review

可以把 Agency 中的 Agent 定义作为 Reasonix 的角色 / Profile / 上下文来源。

### DeepSeek Harness

更适合：

- 使用 DeepSeek 模型进行研发任务
- 自定义 Harness / Tool / Context
- 将 Agency 作为上层研发规范

具体接入方式：

```text
adapters/deepseek-harness.md
```

## 13. 当前阶段暂时不做什么

为了避免过早复杂化，当前阶段暂时不做：

- 不新增大量 Agent
- 不把 Agency 改造成完整 Multi-Agent Runtime
- 不绑定某一个 AI Coding 工具
- 不复制 Agent Prompt 到多个工具目录
- 不引入复杂中心化调度服务
- 不为了“看起来像 Agent 平台”而增加不必要的代码

当前最重要的是：

> **先让 Agent / Rule / Workflow 真正进入日常研发，并验证它是否能够稳定提升开发质量。**

## 14. 推荐使用顺序

```text
第一阶段
项目 AGENTS.md
      ↓
AI Development Agency
      ↓
Codex / Reasonix / DeepSeek Harness

第二阶段
真实项目持续使用
      ↓
发现问题 → agency feedback 记录反馈
      ↓
agency propose 创建提案
      ↓
agency-curator 评审合并（evolution-review workflow）

第三阶段
积累稳定研发模式
      ↓
再考虑 Runtime / 自动编排
```

不要一开始就做复杂的 Agent 平台。

先把：

> **规范 → AI → 代码 → 验证**

这个闭环真正跑通。

## 15. 规则自进化（Evolution）

使用不再是一次性的：每次任务完成后按硬规则记录反馈（`agency feedback`），缺口升级为提案（`agency propose`），agency-curator 按 `workflows/evolution-review.md` 评审合并，版本与变更记录在 `CHANGELOG.md`。闭环：

```text
使用 → 反馈 → 提案 → 评审 → 合并 → 版本化 → 再使用
```

- 治理规则：`rules/evolution.md`
- 评审角色：`agents/leadership/agency-curator.md`
- 评审流程：`workflows/evolution-review.md`
- 日常命令：`agency`（`scripts/agency.sh`），详见 `docs/日常使用手册.md`

## 15.1 让技能在各智能体里真正生效

`skills/` 下的技能**放在本仓库里不会被任何工具自动发现** —— 各工具只扫自己的技能目录。
把技能软链到用户级中立目录，即可在 Cursor / Claude Code / Codex 中对所有项目生效：

```bash
mkdir -p ~/.agents/skills
for s in debt diff-review task-audit agency-task agency-feedback agency-route agency-check; do
  ln -sfn ~/workspace/AI-Development-Agency/skills/$s ~/.agents/skills/$s
done
```

- 软链而非复制：规范库更新后技能自动跟随，避免出现多份漂移。
- 生效需**新开一个会话**（工具在会话启动时扫描技能目录）。
- 技能必须带 frontmatter（`name` + `description`）才会被发现，详见 `skills/README.md`。

> 常驻红线规范不要做成技能（技能是按需触发，漏一次即失效），应进项目根目录
> `AGENTS.md`；真正的强制靠 `agency check`（git hooks + CI，只卡增量）。载体如何归属见
> `docs/载体归属迁移清单.md`，团队推广路径见 `docs/团队推广方案.md`。

## 16. 最终目标

```text
                 人
                 │
                 ↓
              提出需求
                 │
                 ↓
        ┌────────────────────┐
        │ AI Development     │
        │ Agency             │
        └────────────────────┘
                 │
       ┌─────────┼─────────┐
       ↓         ↓         ↓
     Agent      Rule    Workflow
       │         │         │
       └─────────┼─────────┘
                 ↓
        Codex / Reasonix /
        DeepSeek Harness
                 ↓
             真实项目代码
                 ↓
          Test / QA / Review
                 ↓
              可交付结果
```

**Agency 定义“应该怎样研发”，AI Coding 工具负责“真正去执行”。**

## 17. 仓库

GitHub：

https://github.com/yzz521/AI-Development-Agency

当前阶段优先保持架构稳定，基于真实研发场景持续验证，再决定是否增加新的 Agent、Workflow 或 Runtime 能力。
