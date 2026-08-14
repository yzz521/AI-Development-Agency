# Agent Contract

## 1. Agent 输入

每个 Agent 至少接收：

```text
task_id
task_description
task_level
workflow
current_state
project_context
relevant_artifacts
```

## 2. Agent 必须读取

- `AGENTS.md`
- `rules/global.md`
- 自己对应的领域 Rule
- 需要的 Context
- 上游 Artifact

## 3. Agent 执行

Agent 必须：

1. 先确认任务边界。
2. 识别缺失信息。
3. 读取现有实现。
4. 做最小必要变更。
5. 自检。
6. 生成标准 Artifact。
7. 指定下一 Agent。

## 4. Agent 禁止

- 擅自扩大任务范围。
- 擅自改变技术栈。
- 没读代码就重写。
- 把推测当成事实。
- 跳过必要验证。
- 在未声明的情况下修改数据库、权限或公共 API。

## 5. Agent 输出

```yaml
status: PASS | FAIL | BLOCKED | NEED_REWORK
summary:
changed_files:
decisions:
validation:
risks:
rollback:
next_agent:
artifacts:
unresolved:
```
