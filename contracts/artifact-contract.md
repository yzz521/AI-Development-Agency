# Artifact Contract

Artifact 是 Agent 之间的标准交接物。

## Metadata

```yaml
artifact_type:
task_id:
producer:
status:
created_at:
```

## 必备内容

```text
1. 目标
2. 输入
3. 事实 / 假设
4. 决策
5. 输出
6. 修改文件
7. 验证
8. 风险
9. 回滚
10. 下一步
```

## 原则

- 可被下一个 Agent 直接消费。
- 不依赖上一个 Agent 的隐含记忆。
- 事实与模型推断必须区分。
- 每个结论尽可能提供代码 / 文件 /测试证据。
