# Database Change Workflow v1.1

## Input
- 变更目标
- 现有 Schema
- 数据量
- 性能要求

## Stages
1. `requirements-analyst` → 变更需求
2. `sqlserver-dba` → DDL / Index / Migration
3. `sqlserver-performance` → 性能与锁风险
4. `sql-reviewer` → SQL 安全与正确性
5. `qa-engineer` → Migration Validation
6. `ai-tech-lead` → Rollback / Impact Review

## Required
- 前置检查 SQL
- DDL
- Rollback SQL
- 数据校验 SQL
- 锁 / 阻塞风险
- 向后兼容说明

## 禁止
没有回滚方案时，不得将高风险 Schema 变更标记为 PASS。
