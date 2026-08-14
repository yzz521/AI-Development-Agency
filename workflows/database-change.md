# Database Change Workflow

1. 确认业务需求和现有数据结构。
2. `sqlserver-dba` 设计 DDL / Index / Migration。
3. `sqlserver-performance` 评估大表、锁和执行计划影响。
4. 应用 Agent 同步修改数据访问代码。
5. `sql-reviewer` 检查 SQL。
6. QA 验证数据一致性与回归。
7. 输出明确回滚方案。
