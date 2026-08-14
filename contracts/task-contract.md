# Task Contract

## 任务最小模型

```yaml
task_id:
title:
request:
task_type:
risk_level:
status:
workflow:
project:
constraints:
acceptance_criteria:
```

## 状态

```text
PENDING
ANALYZING
IN_PROGRESS
WAITING_REVIEW
PASS
REWORK
BLOCKED
FAILED
DONE
```

## 结束要求

任务必须具备：
- acceptance_criteria
- validation_evidence
- final_summary

高风险任务还必须具备：
- architecture_review
- security_review（适用时）
- rollback_plan
