# Evolution — 自动化规范自进化

目标：真实使用中自动发现并记录规范问题，定期汇总，交由 Agency Curator 核验后形成 PR。

## 自动闭环

```text
任务完成
  ↓ Agent 自动自检并记录（仅有真实问题时）
evolution/feedback/
  ↓ 每周 GitHub Actions 统计最近 30 天
评审报告 + GitHub Issue（达到阈值时）
  ↓ Agency Curator 核验证据、语义归并、判断根因
evolution/proposals/
  ↓ 最小变更 + validate + PR
人工审核合并 → 版本化 → 归档
```

## 自动化边界

| 环节 | 自动程度 |
|---|---|
| 任务收尾检查 | Agent 按常驻指令自动执行 |
| 反馈写入 | Agent 自动调用 `agency feedback`，不要求用户手动输入 |
| 反馈统计 | `agency evolve` / GitHub Actions 自动执行 |
| 达阈值提醒 | 自动创建 GitHub Issue，避免重复提醒 |
| 语义分析与提案 | Curator 读取真实反馈后执行；不是 shell 关键词脚本 |
| 规则修改 | 可以自动准备分支和 PR |
| 最终合并 | 人工审核；高风险变更必须人工批准 |

> GitHub Actions 不会凭空获得大模型能力。本版本的定时任务只负责统计和提醒；要无人值守的语义分析，需要另行配置模型 API 与权限，当前不假设你已经配置。

## 命令

```bash
# 最近 30 天统计并输出报告
agency evolve

# 指定窗口
agency evolve --days 14

# CI 用法（输出报告到指定文件）
agency evolve --days 30 --output /tmp/evolution-review.md
```

反馈记录由 Agent 在任务收尾时自动完成；用户不需要再手动输入 `agency feedback`。如果当前 AI 工具没有中央仓库写权限，Agent 必须如实说明未落盘。

## 目录

- `feedback/`：按日期存储的真实反馈。
- `proposals/`：待评审提案。
- `archive/`：已处理提案。
- `metrics.md`：评审指标。
- 定时评审：`.github/workflows/evolution-review.yml`

治理规则：`rules/evolution.md`；执行流程：`workflows/evolution-review.md`；评审角色：`agents/leadership/agency-curator.md`。
