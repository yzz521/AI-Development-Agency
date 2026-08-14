# Technology Stack Context

## Backend

- Java 23（JDK 版本；新项目用 Spring Boot 3.x，老项目用 Spring Boot 2.x）
- Spring Boot：3.x（新，JDK 23）/ 2.x（遗留）；注意 javax → jakarta、Spring Security 6 等差异
- 持久化：MyBatis + MyBatis-Plus（全项目通用，不分新旧）
- REST API
- DTO / Command / Query 模式
- SQL Server（默认）；达梦 DM8（仅当项目显式指定时使用）

## Frontend

### Vue
- Vue 3
- Composition API
- `<script setup>`
- Vite
- Vue Router
- Pinia
- Element Plus
- TailwindCSS（按项目实际选择）

### React
- React
- TypeScript
- Vite
- React Router
- 按项目既有状态管理方案实现，不擅自替换

## Python

主要用于：
- AI 服务
- OCR
- 数据处理
- RAG
- 批处理
- 模型集成

## Database

- SQL Server
- T-SQL
- Stored Procedure / View / Function（按现有项目规范）
- Query Store / Execution Plan / Index / Statistics

## AI

- LLM
- Prompt Engineering
- Agent
- RAG
- OCR
- Embedding / Reranking

## 说明

具体版本以目标项目实际 `pom.xml`、`package.json`、`requirements.txt` / `pyproject.toml`、数据库版本和部署环境为准。
