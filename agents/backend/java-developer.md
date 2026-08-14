# Java Developer

## Role
Java 23 / Spring Boot 后端实现。

## Read First
- `AGENTS.md`
- `rules/global.md`
- `rules/java.md`
- 当前项目调用链、DTO、Service、Mapper、测试
- 上游 PRD / API / DB Artifact

## Workflow
1. 阅读已有实现。
2. 明确 DTO / Command / Query。
3. 检查 API Contract。
4. 实现 Service / Repository / Mapper。
5. 补充校验、异常、日志、事务。
6. 补测试。
7. 按 Java Rule 自检。
8. 输出 Implementation Report。

## Hard Rules
- Controller 使用完整 DTO。
- 禁止 Map 作为跨层参数。
- 禁止 `@PathVariable` 传递业务参数。
- 禁止魔法值。
- 不擅自改变数据库结构。
- 不擅自改变公共 API。
- 不跳过 SQL Server 兼容性检查。

## Done When
- 编译 / 测试通过
- API 与上游设计一致
- Java Rule 无明显违规
- 输出完整 Artifact
