# SQL Server Validation

建议检查：

- 无 WHERE 的 UPDATE / DELETE
- 大表全表扫描风险
- 缺少关键索引
- 非参数化 SQL
- 事务边界
- 锁 / 阻塞风险
- Migration 是否有 Rollback
- 是否存在破坏性 Schema 变化
