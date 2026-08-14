# Contribution Guide

新增 Agent：
1. 明确职责边界。
2. 遵循 Agent Contract。
3. 关联必要 Rules / Context。
4. 定义输入、输出、验证和失败处理。
5. 不复制其他 Agent 的职责。

新增 Workflow：
1. 定义适用范围。
2. 定义输入。
3. 定义阶段和交接物。
4. 定义完成条件。
5. 定义失败 / REWORK 路径。

新增 Rule：
- 优先写可验证、可执行的规则。
- 区分 MUST / SHOULD / MAY。
- 尽量提供反例和验证方式。
