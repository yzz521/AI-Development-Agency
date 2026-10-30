# Java Rules

## 摘要（注入用）

- 语言与框架版本以项目 `AGENTS.md` 和构建文件为准，不在中央库写死。
- Controller 接收完整 DTO，禁止用 `@PathVariable` 传业务参数；不把 DTO 拆成一串参数往下传。
- 跨层禁止 `Map`；用 DTO / Command / Query / VO。
- 禁止魔法值（项目常量类或 Enum）；错误码集中管理；输入必须校验。
- 异常处理统一，Controller 不堆业务；事务边界由业务一致性决定。
- 分页与权限走项目既有模式，不另起一套。
- 依赖方向单向（Controller → Service → Repository）；`@Transactional` 只在 Service 层，事务内不调外部服务。
- 禁止 `new Thread` / `Executors.newXxx` / `static SimpleDateFormat`；异常日志带堆栈，不 catch 后返回 null。

## 必须遵守

1. Java / Spring Boot 版本以当前项目 `AGENTS.md`、`pom.xml` / Gradle 为准。
2. Controller 接收完整 DTO，不使用 `@PathVariable` 传递业务参数。
3. Controller 调用具体应用服务/实现，不逐个拆 DTO 参数向下传递。
4. 跨层参数禁止使用 `Map`；使用 DTO、Command、Query、Value Object 或明确类型。
5. 禁止魔法值；使用项目统一常量类或 Enum（类名以该仓库 `AGENTS.md` 为准）。
6. 错误码必须集中管理并避免重复定义。
7. 输入参数必须进行校验。
8. 异常处理统一，不在 Controller 内堆积业务逻辑。
9. 事务边界由业务一致性决定，并明确读写范围。
10. 分页、鉴权、数据权限复用项目既有写法，不另起一套。
11. 依赖方向单向：Controller → Service → Repository/Mapper。禁止 Service 依赖 Controller，
    禁止 Repository/Mapper 依赖 Service。
12. `@Transactional` 只加在 Service 层，禁止加在 Controller（事务会跨越参数校验与序列化）。
    事务内禁止调用 HTTP / RPC / MQ —— 长事务持锁，连接池会被打空。
13. 查询方法标 `@Transactional(readOnly = true)`，不占写连接。
14. 同类自调用、`private` 方法上的 `@Transactional` 不生效（绕过代理）。需要事务时必须经由
    注入的代理对象调用，否则注解静默失效。
15. 禁止 `new Thread(...)` 与 `Executors.newXxx()`。线程池由容器注入，并显式配置队列容量与
    拒绝策略；无界队列等于没有背压。
16. 禁止 `static SimpleDateFormat`（非线程安全，并发下会解析出错乱日期）。用 `DateTimeFormatter`。
17. 异常日志必须带堆栈，禁止只打 `e.getMessage()`（丢掉堆栈等于放弃排查）。
    禁止 catch 后返回 `null` 或空对象掩盖失败。
18. 集合返回值用空集合，不返回 `null`（调用方少一次判空，也少一次 NPE）。

## 代码质量

- 优先清晰、可读、可测试的实现。
- 不为了“架构漂亮”新增无必要层次。
- 新增公共能力必须说明复用场景。
- 外部调用必须定义超时、异常和重试策略（适用时）。
- 改前先读相关代码（见全局红线「先理解再修改」）。
