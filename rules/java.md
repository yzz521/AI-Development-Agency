# Java 23 Rules

## 摘要（注入用）

- Java 23；Controller 接收完整 DTO，禁止用 `@PathVariable` 传业务参数。
- 跨层禁止 `Map`；用 DTO / Command / Query / VO。
- 禁止魔法值（常量类或 Enum）；输入必须校验；异常处理统一。
- Controller 不堆业务逻辑；先读 Service / Mapper / DTO / Entity / 测试再改。
- 项目级常量类名以该仓库 `AGENTS.md` 为准，不硬套其它项目的类名。

## 必须遵守

1. Java 23。
2. Controller 接收完整 DTO，不使用 `@PathVariable` 传递业务参数。
3. Controller 调用具体应用服务/实现，不逐个拆 DTO 参数向下传递。
4. 跨层参数禁止使用 `Map`；使用 DTO、Command、Query、Value Object 或明确类型。
5. 禁止魔法值；使用项目统一常量类或 Enum（类名以该仓库 `AGENTS.md` 为准）。
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
