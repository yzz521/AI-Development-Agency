# SQL Server Rules

## Schema

- 主键、唯一约束、外键和必要索引必须根据真实访问模式设计。
- 大表新增字段或索引必须评估锁和执行时间。
- 索引不能只看单字段选择性，要结合过滤、Join、排序和覆盖需求。

## SQL

- 避免 `SELECT *`。
- 优先参数化 SQL。
- 复杂 SQL 必须关注执行计划、统计信息和基数估算。
- 发现慢 SQL 时优先读取 Query Store / Actual Execution Plan。
- 关注参数嗅探、隐式类型转换、扫描、Key Lookup、排序、Hash Join 等典型问题。
- 批量操作必须评估事务大小、锁升级、TempDB 与日志压力。

## Migration

任何结构变更都应说明：

- 影响对象
- 数据量
- 执行窗口
- 锁风险
- 回滚方式
- 前后版本兼容性

## 应用层协作

- 大表操作前提醒为查询列建索引。
- 批量写入优先用 MyBatis-Plus `saveBatch` / `updateBatch`。
- 涉及达梦 DM8 时避免 `MERGE`、`CROSS APPLY` 等不兼容语法，改用标准 SQL。
- 手写 SQL 只选必要列：下拉/选项列表只查 `id` + `name`，避免 `SELECT *` 拉大字段。
- 手写 SQL 不内嵌分页语法，交给 PageHelper / MyBatis-Plus 处理方言（见 `rules/java.md`）。
