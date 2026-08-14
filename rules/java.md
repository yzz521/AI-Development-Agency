# Java 23 Rules

## 必须遵守

1. Java 23。
2. Controller 接收完整 DTO，不使用 `@PathVariable` 传递业务参数。
3. Controller 调用具体应用服务/实现，不逐个拆 DTO 参数向下传递。
4. 跨层参数禁止使用 `Map`；使用 DTO、Command、Query、Value Object 或明确类型。
5. 禁止魔法值；使用 `JavertConstants`、其他统一常量类或 Enum。
6. 错误码必须集中管理并避免重复定义。
7. 输入参数必须进行校验。
8. 异常处理统一，不在 Controller 内堆积业务逻辑。
9. 事务边界由业务一致性决定，并明确读写范围。
10. 修改前先阅读相关 Service、Repository、DTO、Entity、Mapper 和测试。

## 代码质量

- 优先清晰、可读、可测试的实现。
- 不为了“架构漂亮”新增无必要层次。
- 新增公共能力必须说明复用场景。
- 外部调用必须定义超时、异常和重试策略（适用时）。
- 方法不超过 50 行，超限必须拆分。
- Controller 只做参数校验与结果返回，不写业务逻辑。
- 可被多个 Controller 复用的逻辑必须放进 Service。
- Mapper 方法名表达 SQL 意图（如 `selectUsersByDeptId`），禁止 `getList` 这类无意义命名。

## 持久化（MyBatis / MyBatis-Plus）

MyBatis + MyBatis-Plus 全项目通用。查询方式按「需要的列数 + 表大小」选择，而非一刀切：

| 场景 | 方式 | 理由 |
|------|------|------|
| 下拉/选项列表（只需 id + name） | 手写 SQL，只选 2-3 列 | `BaseMapper` 会 `SELECT *`，拉大字段 |
| 列表页，列数 ≤15 且无大字段 | `BaseMapper.selectPage()` + `LambdaQueryWrapper` | 列少，`SELECT *` 开销可忽略 |
| 列表页，列数 >15 或含 TEXT/BLOB | 手写 SQL，只选列表所需列 | 避免拉大字段，便于用覆盖索引 |
| 详情/编辑回显 | `BaseMapper.selectById()` | 详情本就需要全字段 |
| 增/改/删 | `BaseMapper.insert/updateById/deleteById` | MP 直接支持 |
| 多表关联 | 手写 XML | 非单表操作 |
| 聚合（COUNT/SUM/GROUP BY） | 手写 SQL | LambdaQueryWrapper 聚合能力有限 |
| 批量 | MP `saveBatch` / `updateBatch` | 内置批量能力 |

也可使用 `LambdaQueryWrapper.select(列...)` 限定列，无需写 XML。

## 分页

- **优先 PageHelper**：对任意查询（BaseMapper / `@Select` / 手写 XML）都能按库自动加方言（SQL Server → `OFFSET FETCH`，DM8 → `LIMIT`）。
- 若项目已用 MP 原生分页（`BaseMapper.selectPage()` + `Page<T>`），沿用现状；二者都满足「SQL 级分页」。
- **禁止内存分页**：不得全表查询后在 Java 里 `skip/limit`。
- **禁止手写** `LIMIT` / `OFFSET` 分页 SQL（绑定单一库类型）；手写 SQL 不内嵌分页语法，交给 PageHelper/MP 处理方言。
- 分页参数约定：DTO 继承 `BaseCommonDTO`，`pageIndex`（从 1 起）、`pageSize`（默认 20）。前端请求：`{ "pageIndex": 1, "pageSize": 20 }`。

## 安全基线（后端）

- Controller 入参必须校验（`@Valid` / `@NotNull`）。
- SQL 必须带 WHERE 条件：禁止无条件 `UPDATE`/`DELETE`，MyBatis-Plus `UpdateWrapper` 同样必须带条件。
- 敏感接口必须标权限注解（默认 Sa-Token；用户指定 Spring Security/Shiro 等则按其规范）。
- 详见 `rules/security.md`。
