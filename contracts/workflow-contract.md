# Workflow Contract

每个 Workflow 必须包含：

## Metadata

```yaml
name:
version:
purpose:
risk_level:
```

## Input

定义启动该 Workflow 所需的信息。

## Stages

每个阶段定义：

```text
stage_id
agent
input_artifacts
output_artifacts
entry_conditions
done_conditions
failure_transition
```

## Completion

必须明确：
- 正常完成条件
- Review 条件
- Validation 条件
- 回滚要求（适用时）
