# 项目 AI 开发规则

## 项目简介

项目名称：

项目目标：

主要业务：

## 技术栈

后端：
- Java
- Spring Boot

前端：
- Vue / React

数据库：
- SQL Server

AI：
- Python / LLM / RAG / OCR / Agent

## AI Development Agency

本项目通过稳定入口使用中央 Agency：

```text
.ai/agency/
```

总控：

```text
.ai/agency/AGENTS.md
```

## 推荐 Agent

Java：
```text
.ai/agency/agents/backend/java-developer.md
```

Vue：
```text
.ai/agency/agents/frontend/vue-developer.md
```

React：
```text
.ai/agency/agents/frontend/react-developer.md
```

Python / AI：
```text
.ai/agency/agents/backend/python-developer.md
.ai/agency/agents/ai/ai-engineer.md
```

SQL Server：
```text
.ai/agency/agents/database/sqlserver-dba.md
```

医疗：
```text
.ai/agency/agents/healthcare/healthcare-domain-expert.md
.ai/agency/agents/healthcare/medical-insurance-reviewer.md
```

## 项目特殊规则

只写本项目独有规则，不复制通用技术规范。

## 常用命令

### 构建
```bash
# TODO
```

### 测试
```bash
# TODO
```

## AI 工作原则

1. 先读当前项目代码。
2. 再读取本文件「规范路由」段（提示词自动生效，不必先跑 `agency` 命令）。
3. 只加载命中的规则摘要；默认最小改动。
4. 不做无关重构。
5. 完成后必须验证。

## 最终交付

```text
任务：
修改：
验证：
风险：
未完成事项：
```

<!-- agency-router:begin -->
## 规范路由（提示词自动生效，不必先跑命令）

收到写代码 / 改接口 / 改页面 / 改 SQL / 修 bug 的任务时，**先按本段路由，再动手**。
不要等用户输入 `agency route` 或 `agency use`。

检测技术栈：java,vue,react,python,sqlserver,ai,healthcare,any

### 怎么匹配

1. 对照下面的信号表：任务关键词或将要改的文件。
2. **只加载命中行的规则摘要**（本段已内嵌裁剪后的摘要）。
3. 摘要不够再打开原文；不要把未命中的语言规范整篇塞进上下文。
4. 每次都生效：`rules/global.md` + `rules/minimalism.md` + `rules/security.md`。

### 信号表

| 信号 | 加载规则 | Agent | 风险 |
| --- | --- | --- | --- |
| `*.java,*.kt` | `rules/java.md` | `java-developer` | L2 |
| `application*.yml,application*.yaml,application*.properties,*ConfigurationProperties.java` | `rules/backend/java/spring-boot-configuration.md` | `java-developer` | L2 |
| `*.vue` | `rules/vue.md` | `vue-developer` | L2 |
| `*.tsx,*.jsx` | `rules/react.md` | `react-developer` | L2 |
| `*.py` | `rules/python.md` | `python-developer` | L2 |
| `*.sql,*Mapper.xml,*mapper.xml` | `rules/sqlserver.md` | `sqlserver-dba` | L2 |
| `spring boot,springboot,mybatis,controller,dto` | `rules/java.md` | `java-developer` | L2 |
| `vue,pinia,element plus,script setup` | `rules/vue.md` | `vue-developer` | L2 |
| `react,hooks,tsx` | `rules/react.md` | `react-developer` | L2 |
| `python,fastapi,django,pytest` | `rules/python.md` | `python-developer` | L2 |
| `sql server,sqlserver,t-sql,tsql,存储过程,执行计划,query store` | `rules/sqlserver.md` | `sqlserver-dba` | L3 |
| `RAG,OCR,embedding,LLM,prompt,向量检索,重排序` | `rules/ai.md` | `ai-engineer,rag-engineer` | L2 |
| `医保,DRG,DIP,病组,病案,审核规则,医疗数据,患者,诊疗` | `rules/healthcare.md` | `medical-insurance-reviewer,healthcare-domain-expert` | L3 |
| `bug,修复,报错,回归,npe,exception` | — | — | L1 |

### 本项目应注入的摘要


### rules/global.md
- 先理解现有系统，再修改。
- 保持最小变更面；不删除或覆盖未知用途的代码、配置、数据。
- 密钥、密码不进源码；公共逻辑优先复用，但避免过度抽象。
- 关键逻辑必须有可验证的测试路径。
- 有意的简化必须 `agency: <上限>, <升级路径>` 留痕，见 `rules/minimalism.md`。

原文路径：`rules/global.md`（项目内通常是 `.ai/agency/rules/global.md`）

### rules/minimalism.md
- 写代码前爬 7 级阶梯：YAGNI → 复用代码库 → 标准库 → 平台原生 → 已装依赖 → 一行 → 最小可行。
- 先读任务和调用链，再爬阶梯；改错位置的小 diff 不是懒，是第二个 bug。
- Bug 修根因：grep 所有调用方，修在共享路径上。
- 绝不简化：信任边界校验、防数据丢失、安全、无障碍、用户明确要求的东西。
- 有意简化必须 `agency: <上限>, <升级路径>`；非平凡逻辑留一个可运行检查。

原文路径：`rules/minimalism.md`（项目内通常是 `.ai/agency/rules/minimalism.md`）

### rules/security.md
- 默认最小权限；密钥不进源码、不进日志。
- 所有外部输入视为不可信；SQL 必须参数化。
- API 必须认证、授权和输入校验；医疗数据访问必须可审计。
- 安全问题按 Blocker / High / Medium / Low 分级并给出修复建议。

原文路径：`rules/security.md`（项目内通常是 `.ai/agency/rules/security.md`）

### rules/java.md
- Java 23；Controller 接收完整 DTO，禁止用 `@PathVariable` 传业务参数。
- 跨层禁止 `Map`；用 DTO / Command / Query / VO。
- 禁止魔法值（常量类或 Enum）；输入必须校验；异常处理统一。
- Controller 不堆业务逻辑；先读 Service / Mapper / DTO / Entity / 测试再改。
- 项目级常量类名以该仓库 `AGENTS.md` 为准，不硬套其它项目的类名。

原文路径：`rules/java.md`（项目内通常是 `.ai/agency/rules/java.md`）

### rules/backend/java/spring-boot-configuration.md
- YAML 用 kebab-case，Java 字段 camelCase；优先 `@ConfigurationProperties`，禁止业务代码大量 `@Value`。
- Secret / Token / 密码禁止进 Git，用环境变量，敏感默认值必须为空。
- 时间用 `Duration`（`5s` / `60s`），禁止魔法毫秒数。
- Mock 与高风险功能默认关闭，生产不得靠默认值进入 Mock。
- 配置按业务域拆分，禁止巨型 `CustomProperties`；改配置先搜引用和环境，最小修改。

原文路径：`rules/backend/java/spring-boot-configuration.md`（项目内通常是 `.ai/agency/rules/backend/java/spring-boot-configuration.md`）

### rules/vue.md
- Vue 3 + Composition API + `<script setup>`。
- API 用明确 TypeScript 类型，不用 `any` / 无约束对象传业务数据。
- 状态优先组件本地，跨页再 Pinia；异步必须覆盖 loading / empty / error / retry。
- 表格筛选分页优先复用项目已有模式；不为视觉效果改业务逻辑。

原文路径：`rules/vue.md`（项目内通常是 `.ai/agency/rules/vue.md`）

### rules/react.md
- TypeScript 优先；组件职责单一。
- API 参数和响应使用明确类型；优先复用项目既有状态管理和组件库。
- Hooks 只放状态 / 生命周期 / 可复用逻辑；保持可测试与可访问。

原文路径：`rules/react.md`（项目内通常是 `.ai/agency/rules/react.md`）

### rules/python.md
- 优先明确类型和函数职责；AI / OCR / RAG 与 Web API、数据处理解耦。
- 外部调用必须有超时、重试、错误分类和日志；密钥与环境差异不写死。
- 长任务考虑幂等、断点、重试和资源释放。
- AI 输出进入医疗链路必须结构化校验且人工可追溯。

原文路径：`rules/python.md`（项目内通常是 `.ai/agency/rules/python.md`）

### rules/sqlserver.md
- 禁止 `SELECT *`；SQL 必须参数化。
- 索引和字段变更要结合真实访问模式，评估锁与执行时间。
- 慢 SQL 先看 Query Store / Actual Execution Plan，关注参数嗅探、隐式转换、扫描。
- 结构变更必须说明影响对象、数据量、窗口、锁、回滚、前后兼容。

原文路径：`rules/sqlserver.md`（项目内通常是 `.ai/agency/rules/sqlserver.md`）

### rules/ai.md
- 模型输出不是事实，尤其是医疗、医保和政策问题。
- Prompt 写清角色、上下文、输入、约束、输出格式和失败处理。
- Structured Output 优先；生产链路要有超时、重试、fallback、成本与日志。
- RAG 评估召回、引用、chunk 与重排序；医疗 AI 不得静默覆盖确定性业务规则。

原文路径：`rules/ai.md`（项目内通常是 `.ai/agency/rules/ai.md`）

### rules/healthcare.md
- 业务规则来源必须可追溯；命中 / 未命中 / 无法判断必须区分。
- AI 建议与系统最终审核结论必须区分；医疗 AI 不得静默覆盖确定性规则。
- 规则变更保留版本、启停时间、适用范围和变更记录。
- 生产数据按敏感数据处理；日志避免患者身份、完整病历等敏感字段。

原文路径：`rules/healthcare.md`（项目内通常是 `.ai/agency/rules/healthcare.md`）

### 仍不要做的事

- 不要为了「走完流程」加载全部 Agent Prompt。
- 不要把 `.ai/agency/` 整库读进上下文。
- 红线靠本摘要降低违规概率；真正强制仍是 git hook / CI。
<!-- agency-router:end -->
