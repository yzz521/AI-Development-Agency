---
name: agency-feedback
description: 记录规则使用反馈，必要时升级为规则改进提案。当用户说"这条规则有用/没用""这里没有规则覆盖""规则过时了""提个规则改进""记一下规则反馈"时使用。自动选择合法 kind，不编造证据。
---

# Skill: agency-feedback — 记录规则反馈与提案

## 触发

- "这条规则帮到了 / 这条规则没用"
- "这里没有规则覆盖 / 团队出现了两种写法"
- "规则过时了 / 和现状冲突"
- "提个规则改进 / 提案"
- 任务收尾时发现规则缺口

## 过程

1. 判断属于哪一类，`--kind` 只能取以下合法值：

   | kind | 含义 |
   | --- | --- |
   | `rule_applied` | 规则被正确应用（正面证据） |
   | `rule_violated` | 规则存在但未被遵守 |
   | `rule_gap` | 遇到情况但没有规则覆盖 |
   | `rule_stale` | 规则已过时 / 与现状冲突 |
   | `workflow_ok` | workflow 有效 |
   | `workflow_gap` | workflow 缺失或不适配 |
   | `context_gap` | context 缺失或过时 |

2. 运行 `agency feedback --kind <类型> --detail "<描述>" [--project <项目> --agent <agent> --task "<任务>" --rule <规则路径>]`。
3. `--detail` 必须写**可核查的观察**：在哪个项目、哪个任务、观察到什么现象。不写主观评价。
4. 若同类反馈已累积到值得固化，再运行
   `agency propose --type <rule-add|rule-change|rule-remove|workflow-add|workflow-change|context-add|agent-add|other> --title "<标题>" --evidence "<证据>" --impact "<影响范围>"`。
5. 汇报记录路径。

## 边界

- **不编造证据**：`--evidence` 只能引用真实发生的项目与任务；没证据的提案会被评审打回。
- 一个提案只做一件事，不打包多个变更。
- 不直接改 `rules/` 下的规则文件——规则变更走提案 + 评审，不走本技能。
- 不替用户判断提案该不该合并。

## 退出

输出反馈/提案文件路径后即结束；规则本身的修改另开任务并走 `agency review`。
