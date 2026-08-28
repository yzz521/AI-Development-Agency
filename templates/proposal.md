# Proposal Template — 规范改进提案

> 提案由 `agency propose` 自动生成（脚本内置同款模板）。
> 本文件是人可读的格式参考与写作指引。

## Front Matter

```yaml
---
id: <YYYYMMDD>-<slug>          # 脚本自动生成
title: <一句话标题>
type: rule-add | rule-change | rule-remove | workflow-add | workflow-change | context-add | agent-add | other
author: <提交人/Agent>
status: draft | review | merged | rejected
created: <YYYY-MM-DD>
evidence:                       # 必填：真实项目/任务观察
  - <证据>
impact:                         # 影响面
  - <影响的 Agent / Rule / Workflow>
---
```

## 正文结构

```markdown
# 提案：<标题>

## 背景与证据
（哪个项目、哪个任务、观察到了什么。无证据 = 打回）

## 现状问题
（当前规则/规范缺失或不适配的具体表现）

## 建议变更
（拟新增/修改/删除的规则原文或要点）

## 影响面
- 影响的 Agent：
- 影响的 Rule / Workflow：
- 兼容性：向后兼容 / 破坏性（需 MAJOR 版本）

## 评审记录
| 日期 | 评审人 | 结论 | 备注 |
| --- | --- | --- | --- |
```

## 写作要点

- 一个提案只做一件事。
- 删除规则必须有替代方案或声明弃用期。
- 破坏性变更必须显式声明并升级人工确认。
- 合并后：状态置 `merged`，移入 `evolution/archive/`，同步更新 `CHANGELOG.md`。
