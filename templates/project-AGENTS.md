# 项目 AI 开发规则

## 1. 项目简介

项目名称：

项目目标：

主要业务：

---

## 2. 技术栈

后端：

- 

前端：

- 

数据库：

- 

AI：

- 

其他：

- 

---

## 3. AI Development Agency

Agency 路径：

```text
/你的路径/AI-Development-Agency
```

通用入口：

```text
${AGENCY_PATH}/AGENTS.md
```

---

## 4. 本项目默认 Agent

### Java

```text
agents/backend/java-developer.md
```

### Vue

```text
agents/frontend/vue-developer.md
```

### React

```text
agents/frontend/react-developer.md
```

### Python

```text
agents/backend/python-developer.md
```

### SQL Server

```text
agents/database/sqlserver-dba.md
```

### 医疗

根据任务选择：

```text
agents/healthcare/healthcare-domain-expert.md
agents/healthcare/drg-dip-expert.md
agents/healthcare/medical-insurance-reviewer.md
```

---

## 5. 项目特殊规则

这里写只有本项目拥有的规则。

例如：

- 特殊模块约束
- 特殊命名
- 特殊 API
- 特殊数据库约束
- 特殊部署方式

不要把通用 Java / Vue / SQL Server 规范复制到这里。

---

## 6. 常用开发命令

### 后端

```bash
# TODO
```

### 前端

```bash
# TODO
```

### 测试

```bash
# TODO
```

### 构建

```bash
# TODO
```

---

## 7. 开发原则

1. 先读代码，再修改。
2. 默认最小变更。
3. 不擅自改变技术栈。
4. 不做无关重构。
5. 完成后必须验证。
6. 涉及数据库、权限、敏感数据时提高风险等级。

---

## 8. 任务开始时

Coding Agent 默认：

1. 读取本文件。
2. 读取 Agency `AGENTS.md`。
3. 判断任务类型。
4. 选择最小必要 Agent。
5. 加载对应 Rule。
6. 阅读实际代码。
7. 执行任务。
8. 运行项目验证。

---

## 9. 最终交付

```text
任务：
修改：
验证：
风险：
未完成事项：
```
