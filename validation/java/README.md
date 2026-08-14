# Java Validation

建议自动检查：

- `@PathVariable` 使用
- Controller 直接出现业务逻辑
- Controller 使用 Map
- 未集中管理的错误码
- 明显魔法值
- 无条件 update/delete
- 分页是否走 SQL
- 测试是否覆盖关键分支

自动检查失败时，Agent 必须进入 REWORK。
