# Architecture Context

## 默认架构偏好

优先使用简单、可维护、可验证的架构。只有当边界、独立部署、团队 ownership 或规模需求明确时，才增加微服务、事件总线等复杂度。

## 分层原则

```text
Controller / API
      ↓
Application / Service
      ↓
Domain / Business Logic
      ↓
Repository / Data Access
      ↓
SQL Server
```

AI 能力建议通过独立的 AI Service / Python Service 与 Java 主业务解耦；是否拆服务必须以现有系统边界为依据。

## API 统一要求

- DTO 作为接口参数
- 明确请求和响应模型
- 统一异常和错误码
- 可观测的 request / correlation id
- 参数校验
- 向后兼容
