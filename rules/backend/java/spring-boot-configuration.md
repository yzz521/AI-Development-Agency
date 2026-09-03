# Spring Boot 配置规范

> 适用于 Java / Spring Boot 项目的 `application.yml`、`application.yaml`、`application-*.yml`、`application-*.yaml` 以及 `@ConfigurationProperties` 配置类。

## 摘要（注入用）

- YAML 用 kebab-case，Java 字段 camelCase；优先 `@ConfigurationProperties`，禁止业务代码大量 `@Value`。
- Secret / Token / 密码禁止进 Git，用环境变量，敏感默认值必须为空。
- 时间用 `Duration`（`5s` / `60s`），禁止魔法毫秒数。
- Mock 与高风险功能默认关闭，生产不得靠默认值进入 Mock。
- 配置按业务域拆分，禁止巨型 `CustomProperties`；改配置先搜引用和环境，最小修改。

---

## 1. 规范目标

统一 Spring Boot 项目中的 YAML 配置结构、命名、`@ConfigurationProperties`、外部服务、超时、Secret、多环境、Mock、默认值、兼容迁移以及 AI Coding 行为。

目标不是让 YAML 只是“看起来整齐”，而是保证：

> 配置具有清晰的业务边界、稳定的 Java 类型映射、明确的环境行为和可维护的长期结构。

---

## 2. 核心原则

1. 配置必须有明确的业务归属。
2. YAML 使用 `kebab-case`。
3. Java 字段使用 `camelCase`。
4. 优先使用 `@ConfigurationProperties`。
5. 禁止在业务代码中大量散落 `@Value`。
6. 配置类按照业务领域划分。
7. 禁止无限膨胀的全局 `CustomProperties`。
8. 时间配置优先使用 `Duration`。
9. 敏感信息禁止硬编码。
10. 不同环境必须有明确的配置边界。
11. Mock 配置默认关闭。
12. 生产环境禁止意外启用 Mock。
13. 外部服务配置结构保持统一。
14. 配置修改必须考虑向后兼容。
15. 配置项名称必须表达真实业务语义。
16. 不为了代码复用创建“大而全”的配置对象。
17. 修改已有配置时必须检查所有引用方。
18. 删除或重命名配置时必须考虑历史配置兼容。
19. 配置默认值必须经过业务判断。
20. AI 修改配置前必须读取本规范。

---

## 3. YAML 命名规范

必须使用 `kebab-case`。

推荐：

```yaml
basic-compliance:
  base-url: http://127.0.0.1:8086
  connect-timeout: 5s
  read-timeout: 60s
```

禁止：

```yaml
basicCompliance:
basic_compliance:
BasicCompliance:
```

---

## 4. Java 命名规范

Java 字段使用 `camelCase`：

```java
private String baseUrl;
private Duration connectTimeout;
private ApiConfig basicComplianceApi;
```

对应 YAML：

```yaml
base-url:
connect-timeout:
basic-compliance-api:
```

---

## 5. 配置层级规范

配置按照：

```text
业务域
  ↓
子模块
  ↓
具体配置
```

组织。

推荐：

```yaml
javert:
  ocr:
    recognition:
      base-url:
      endpoint:
      model:

    structuring:
      base-url:
      model:
```

不推荐：

```yaml
javert:
  ocr-recognition-base-url:
  ocr-recognition-endpoint:
  ocr-recognition-model:
  ocr-structuring-base-url:
  ocr-structuring-model:
```

---

## 6. 禁止全局配置垃圾桶

禁止长期维护：

```java
@ConfigurationProperties(prefix = "javert")
public class CustomProperties {
    private String xxx;
    private String xxx2;
    private ApiConfig xxx;
    private XxxConfig xxx2;
}
```

配置数量持续增加时，不允许无条件继续向 `CustomProperties` 中添加字段。

应根据业务领域拆分，例如：

```text
properties/
├── OcrProperties.java
├── AuditProperties.java
├── PatientDataProperties.java
├── DesensitizationProperties.java
├── PharmacyProperties.java
├── WechatProperties.java
└── SmsProperties.java
```

---

## 7. `@ConfigurationProperties` 规范

优先：

```java
@ConfigurationProperties(prefix = "javert.ocr")
@Getter
@Setter
public class OcrProperties {
}
```

或者：

```java
@ConfigurationProperties(prefix = "javert.audit")
@Getter
@Setter
public class AuditProperties {
}
```

不推荐在业务代码中大量使用：

```java
@Value("${javert.ocr.base-url}")
private String baseUrl;
```

尤其禁止大量重复：

```java
@Value("${javert.xxx.xxx}")
private String xxx;

@Value("${javert.xxx.xxx}")
private String xxx2;
```

---

## 8. 配置类职责

一个配置类应该表达一个明确的业务领域。

推荐：

```java
@ConfigurationProperties(prefix = "javert.audit")
public class AuditProperties {

    private String submitUrl;

    private String resultsUrlTemplate;
}
```

不推荐把 OCR、短信、微信、药房、审核等几十个领域全部塞进：

```java
@ConfigurationProperties(prefix = "javert")
public class CustomProperties {
}
```

---

## 9. 配置类拆分原则

不是所有配置都需要拆成一个类。

例如 OCR 可以：

```text
OCR
├── Pipeline
├── Recognition
└── Structuring
```

对应：

```java
public class OcrProperties {
    private Pipeline pipeline;
    private Recognition recognition;
    private Structuring structuring;
}
```

除非这些配置具有独立生命周期或大量独立逻辑，否则不必为了拆分而创建过多 Properties 类。

---

## 10. 配置对象不要过度复用

不要因为多个服务都有：

```text
baseUrl
timeout
token
```

就强行全部使用一个“大而全”的：

```java
ApiConfig
```

例如：

```java
public class ApiConfig {
    private String baseUrl;
    private String ingestPath;
    private String auditPath;
    private String authToken;
    private Duration connectTimeout;
    private Duration readTimeout;
}
```

如果两个服务虽然都有 `baseUrl`，但业务语义不同，应优先保持独立。

---

## 11. 外部服务配置规范

推荐：

```yaml
javert:
  external:
    example-service:
      base-url: ${EXAMPLE_SERVICE_BASE_URL:http://127.0.0.1:8080}
      connect-timeout: ${EXAMPLE_SERVICE_CONNECT_TIMEOUT:5s}
      read-timeout: ${EXAMPLE_SERVICE_READ_TIMEOUT:30s}
      retry-count: ${EXAMPLE_SERVICE_RETRY_COUNT:1}
```

具有特殊业务配置时可以继续扩展：

```yaml
javert:
  external:
    desensitization:
      base-url:
      ingest-path:
      auth-token:
      connect-timeout:
      read-timeout:
      completion-timeout:
      poll-interval:
```

---

## 12. URL 配置规范

推荐：

```yaml
base-url:
submit-url:
results-url:
results-url-template:
health-path:
ingest-path:
audit-path:
```

禁止含义模糊：

```yaml
url:
address:
path:
api:
```

如果 URL 是模板，例如：

```text
/api/audit/results/{SYXH}
```

必须使用：

```yaml
results-url-template:
```

---

## 13. 时间配置规范

优先使用 Spring Boot `Duration`。

Java：

```java
private Duration connectTimeout = Duration.ofSeconds(5);
private Duration readTimeout = Duration.ofSeconds(60);
private Duration completionTimeout = Duration.ofHours(6);
private Duration pollInterval = Duration.ofSeconds(5);
```

YAML：

```yaml
connect-timeout: 5s
read-timeout: 60s
completion-timeout: 6h
poll-interval: 5s
```

不推荐：

```yaml
connect-timeout: 5000
read-timeout: 60000
completion-timeout: 21600000
```

如果底层 API 必须使用毫秒，在调用边界转换：

```java
readTimeout.toMillis();
```

而不是让配置层全部使用 `long`。

---

## 14. Secret / Token / Password 规范

禁止：

```yaml
auth-token: abcdef123456
password: 123456
app-secret: xxxx
```

必须使用环境变量、Secret 或配置中心。

推荐：

```yaml
auth-token: ${DESENSITIZATION_API_TOKEN:}
app-secret: ${WX_APP_SECRET:}
password: ${DATABASE_PASSWORD:}
```

敏感配置默认值必须为空，不得为了本地开发方便把真实 Secret 放进 Git。

---

## 15. 内网地址规范

开发环境可以：

```yaml
base-url: ${OCR_BASE_URL:http://127.0.0.1:18090}
```

如果默认地址依赖固定服务器，必须确认它是否属于开发环境、是否所有开发人员都可访问，以及是否应该改为环境变量。

生产环境不得依赖开发环境默认地址。

---

## 16. 多环境配置

推荐：

```text
application.yml
application-dev.yml
application-test.yml
application-prod.yml
```

### application.yml

放：

- 通用配置
- 不敏感默认值
- 所有环境基本一致的配置

### application-dev.yml

放：

- 本地开发地址
- Mock
- 开发环境专属参数

### application-test.yml

放：

- 测试环境地址
- 自动化测试配置

### application-prod.yml

放：

- 生产环境配置
- 生产安全策略

Secret 不直接放入这些文件。

---

## 17. Mock 配置规范

Mock 默认必须关闭：

```yaml
wechat:
  miniapp:
    mock-enabled: false
```

或者：

```yaml
sms:
  provider: real
```

开发环境可以：

```yaml
sms:
  provider: mock
```

生产环境必须明确：

```yaml
sms:
  provider: real
```

禁止生产环境通过默认值意外进入 Mock。

---

## 18. `enabled` 配置规范

对于具有外部依赖、数据写入或高风险行为的功能：

```yaml
enabled: false
```

优先于：

```yaml
enabled: true
```

例如：

```yaml
ocr-pipeline:
  enabled: ${OCR_PIPELINE_ENABLED:false}
```

如果功能依赖多个服务同时就绪，应采用：

```text
默认关闭
    ↓
部署所有依赖
    ↓
健康检查通过
    ↓
显式开启
```

---

## 19. 配置默认值规范

默认值必须回答：

> 如果完全不配置，这个功能是否安全？

如果答案是否定的，应默认关闭。

如果默认行为会产生真实数据写入、真实消息发送或真实外部调用，不应随意开启。

---

## 20. 配置校验

重要配置应该增加 Bean Validation。

例如：

```java
@ConfigurationProperties(prefix = "javert.ocr")
@Validated
@Getter
@Setter
public class OcrProperties {

    @NotBlank
    private String baseUrl;

    @NotNull
    private Duration timeout;
}
```

范围校验：

```java
@Min(1)
private int workerThreads;
```

具体校验注解根据项目实际依赖选择。

---

## 21. 配置类不要承载业务逻辑

Properties 只负责：

- 配置数据
- 默认值
- 配置校验

不要在 Properties 中实现：

```java
public void executeOcr() {
}
```

或：

```java
public Result audit() {
}
```

业务逻辑必须放在 Service / Component 等业务层。

---

## 22. 默认值的位置

简单、安全的默认值可以放在配置类：

```java
private int retryCount = 1;
```

环境相关默认值可以放在 YAML：

```yaml
retry-count: ${OCR_RETRY_COUNT:1}
```

具有业务意义的默认值必须增加说明。

---

## 23. 配置注释规范

配置注释应该解释：

- 为什么存在
- 单位
- 是否安全
- 特殊约束
- 是否有依赖

例如：

```yaml
ocr-pipeline:
  # OCR、结构化、脱敏服务全部部署完成后才能开启。
  enabled: ${OCR_PIPELINE_ENABLED:false}

  # 单个任务最大执行时间。
  overall-timeout: ${OCR_PIPELINE_OVERALL_TIMEOUT:6h}
```

不要只写：

```yaml
# timeout
timeout: 6h
```

---

## 24. 配置项命名必须表达业务语义

不推荐：

```yaml
timeout:
```

推荐：

```yaml
connect-timeout:
read-timeout:
completion-timeout:
overall-timeout:
```

不推荐在复杂层级中直接出现含义不明确的：

```yaml
enabled:
```

应通过上下文保证语义：

```yaml
ocr:
  pipeline:
    enabled:
```

---

## 25. 配置结构不要为了少写几行而扁平化

不推荐：

```yaml
javert:
  ocr-pipeline-enabled:
  ocr-pipeline-timeout:
  ocr-model:
  ocr-url:
```

推荐：

```yaml
javert:
  ocr:
    pipeline:
      enabled:
      timeout:

    recognition:
      model:
      base-url:
```

配置文件应该优先服务于可理解性。

---

## 26. 旧配置迁移规范

如果已有：

```yaml
desensitizationApi:
```

需要迁移为：

```yaml
desensitization-api:
```

不要直接删除旧配置。

迁移前必须：

1. 搜索所有代码引用。
2. 搜索所有部署配置。
3. 搜索 Docker / K8s / Helm / CI 配置。
4. 搜索环境变量。
5. 确认生产环境。
6. 增加兼容期。
7. 修改代码绑定。
8. 验证新旧配置。
9. 最后删除旧配置。

---

## 27. 禁止悄悄改变配置语义

例如原来：

```yaml
enabled: true
```

不能仅因为“规范化”就直接改成：

```yaml
enabled: false
```

除非明确确认业务行为允许改变。

配置重构必须区分：

```text
结构重构
```

和：

```text
行为改变
```

---

## 28. 配置重构检查清单

修改配置结构之前必须检查：

```text
□ application.yml
□ application-*.yml
□ @ConfigurationProperties
□ @Value
□ Environment#getProperty
□ Docker
□ Docker Compose
□ Kubernetes
□ Helm
□ CI/CD
□ 环境变量
□ 启动脚本
□ README / 部署文档
□ 测试代码
□ 集成测试
```

---

## 29. AI Coding 行为规范

当 AI 收到：

> “整理 application.yml”

不得直接修改。

必须先：

```text
1. 阅读项目 AGENTS.md
2. 阅读本 Spring Boot Configuration Rule
3. 搜索对应 @ConfigurationProperties
4. 搜索配置项引用
5. 判断配置是否被多个环境使用
6. 判断是否存在环境变量覆盖
7. 制定最小修改方案
8. 再修改 YAML / Java
9. 编译
10. 执行相关测试
11. 汇报配置变更
```

---

## 30. AI 不得进行无关配置重构

如果用户只要求：

> 修改 OCR 超时时间。

AI 不应该顺便：

- 重命名所有配置
- 拆分 Properties
- 改动其他服务
- 修改所有环境配置
- 重构整个配置体系

除非用户明确要求。

遵循：

> **最小修改原则。**

---

## 31. AI 新增配置的标准流程

```text
需求
 ↓
确定业务归属
 ↓
确定配置名称
 ↓
确定 YAML 层级
 ↓
确定 Java Properties
 ↓
确定默认值
 ↓
确定是否敏感
 ↓
确定环境覆盖方式
 ↓
增加配置校验
 ↓
实现
 ↓
测试
```

---

## 32. 新增外部服务配置示例

推荐：

```yaml
javert:
  external:
    example-service:
      base-url: ${EXAMPLE_SERVICE_BASE_URL:http://127.0.0.1:8080}
      connect-timeout: ${EXAMPLE_SERVICE_CONNECT_TIMEOUT:5s}
      read-timeout: ${EXAMPLE_SERVICE_READ_TIMEOUT:30s}
      retry-count: ${EXAMPLE_SERVICE_RETRY_COUNT:1}
```

Java：

```java
@ConfigurationProperties(prefix = "javert.external.example-service")
@Getter
@Setter
@Validated
public class ExampleServiceProperties {

    @NotBlank
    private String baseUrl;

    @NotNull
    private Duration connectTimeout = Duration.ofSeconds(5);

    @NotNull
    private Duration readTimeout = Duration.ofSeconds(30);

    @Min(0)
    private int retryCount = 1;
}
```

---

## 33. 推荐配置结构

大型 Java 项目推荐：

```yaml
javert:

  # ==============================
  # OCR
  # ==============================
  ocr:
    pipeline:
    recognition:
    structuring:

  # ==============================
  # Patient Data
  # ==============================
  patient-data:

  # ==============================
  # External Services
  # ==============================
  external:
    desensitization:
    basic-compliance:

  # ==============================
  # Audit
  # ==============================
  audit:

  # ==============================
  # Pharmacy
  # ==============================
  pharmacy:

  # ==============================
  # WeChat
  # ==============================
  wechat:

  # ==============================
  # SMS
  # ==============================
  sms:
```

注释用于大型配置文件的业务分区，不要为每一行都增加注释。

---

## 34. 不建议的做法

### 34.1 YAML camelCase

```yaml
basicComplianceApi:
```

### 34.2 Java 大量 `@Value`

```java
@Value("${javert.xxx}")
private String xxx;
```

### 34.3 巨型 `CustomProperties`

```text
CustomProperties
    ├── OCR
    ├── SMS
    ├── WeChat
    ├── Pharmacy
    ├── Audit
    ├── DRG
    ├── Database
    └── ...
```

### 34.4 魔法数字

```yaml
timeout: 21600000
```

### 34.5 Secret 硬编码

```yaml
token: abc123
```

### 34.6 Mock 默认开启

```yaml
mock-enabled: true
```

### 34.7 无业务语义的名称

```yaml
url:
path:
timeout:
config:
```

---

## 35. Code Review 检查项

### 命名

```text
□ YAML 是否全部 kebab-case
□ Java 是否 camelCase
□ 是否存在 camelCase YAML
```

### 结构

```text
□ 是否有明确业务域
□ 是否存在配置垃圾桶
□ 是否出现无限膨胀的 CustomProperties
```

### 类型

```text
□ 时间是否使用 Duration
□ 数字范围是否合理
□ 是否需要 @Validated
```

### 安全

```text
□ Token 是否硬编码
□ Password 是否硬编码
□ Secret 是否硬编码
□ Mock 是否可能进入生产
```

### 环境

```text
□ dev/test/prod 是否明确
□ 默认值是否安全
□ 环境变量是否正确
```

### 兼容

```text
□ 是否影响旧配置
□ 是否影响 Docker
□ 是否影响 K8s
□ 是否影响 CI/CD
□ 是否影响部署脚本
```

---

## 36. 与项目 `AGENTS.md` 的关系

项目级 `AGENTS.md` 负责项目自己的配置约定。

例如：

```text
本项目使用：
- application.yml
- application-dev.yml
- application-test.yml
- application-prod.yml

生产环境配置通过环境变量注入。
```

本 Rule 负责通用 Spring Boot 配置规范。

关系：

```text
AI Development Agency
        │
        ↓
Spring Boot Configuration Rule
        │
        ↓
项目 AGENTS.md
        │
        ↓
项目实际配置
```

项目规则可以覆盖通用规则，但必须明确说明原因。

---

## 37. 与其他 Agent 的关系

### Java Developer

负责：

- Properties
- YAML
- Spring Boot 配置
- 配置绑定
- 配置校验

修改配置前必须遵守本规范。

### Software Architect

负责：

- 配置领域划分
- 配置架构
- 大规模配置迁移

### Security Reviewer

负责：

- Secret
- Token
- Password
- Mock
- 生产配置风险

### QA Engineer

负责：

- 配置启动验证
- 环境验证
- 配置兼容性测试

---

## 38. 最终原则

Spring Boot 配置不是简单的 YAML。

它是：

```text
业务配置
    +
Java 类型
    +
环境配置
    +
部署配置
    +
安全配置
```

因此任何配置修改都必须考虑完整链路：

```text
YAML
 ↓
@ConfigurationProperties
 ↓
Java Service
 ↓
外部服务 / 数据库 / 消息系统
 ↓
Docker / K8s / CI/CD
 ↓
Dev / Test / Prod
```

最终目标：

> **让配置成为稳定、可理解、可验证、可演进的代码契约，而不是散落在项目中的字符串和魔法数字。**
