# Validation

Validation 用于把 Rule 从"模型阅读规范"升级为"可执行检查"。

## 原则

- Rule 定义要求
- Validation 检查证据
- Review 做语义判断
- CI 做最终门禁

## 可执行检查

```bash
# 一键校验规范库完整性（引用悬空 / front matter / 提案状态 / 反馈格式）
scripts/validate.sh

# 或通过 CLI
agency validate
```

校验内容：

1. 目录结构完整性（agents / rules / workflows / context / contracts / artifacts / validation / evolution / templates / scripts）
2. Agent"开始工作前必须读取"引用全部可解析（防悬空引用）
3. Workflow 的 Agent 引用全部可解析
4. AGENTS.md 路由引用全部可解析
5. Agent front matter 完整（name / description）
6. Agent 名称全局唯一
7. 提案状态合法（draft/review 在 proposals/，merged/rejected 在 archive/）
8. 反馈 kind 合法

## CI 接入

`scripts/validate.sh` 已接入 GitHub Actions（`.github/workflows/validate.yml`），每次 push/PR 自动执行。
本地提交前建议运行一次，确保规则库变更不破坏引用。
