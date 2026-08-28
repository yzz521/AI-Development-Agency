# Evolution — 规则与规范自进化

> 让 AI Development Agency 从"一堆 Markdown"变成"会自我迭代的规范库"。

## 一、为什么需要进化

规则库的宿命是**腐烂**：项目在变、技术栈在变、坑在变，规则不更新就会慢慢从"指南"变成"噪音"甚至"误导"。

自进化的目标：**每一次真实使用都留下证据，每一条规则都有来处，每一次变更都有记录。**

## 二、闭环

```text
使用 → 反馈 → 提案 → 评审 → 合并 → 版本化 → 再使用
```

| 环节 | 谁 | 工具/文件 | 产物 |
| --- | --- | --- | --- |
| 采集 | 任何执行任务的 Agent | `agency feedback` | `feedback/<日期>.md` |
| 提案 | 发现缺口的 Agent / 人 | `agency propose` | `proposals/<日期>-<slug>.md` |
| 评审 | agency-curator | `agency review` + `workflows/evolution-review.md` | 结论 merged/rejected |
| 合并 | agency-curator + 人（破坏性时） | 改文件 + `scripts/validate.sh` | 规则更新 + `CHANGELOG.md` + 版本 bump |
| 归档 | agency-curator | 移动文件 | `archive/` |

## 三、目录

```text
evolution/
├── README.md          # 本文件
├── feedback/          # 使用反馈（按日期，自动追加）
├── proposals/         # 待评审提案（draft / review）
├── archive/           # 已合并 / 已拒绝提案
└── metrics.md         # 评审指标（合并率、反馈分布、老化规则）
```

## 四、快速上手

```bash
# 记录一条反馈（任务完成后）
agency feedback --kind rule_gap --rule rules/java.md --project javert \
  --task "新增规则查询接口" --detail "遇到了 XXX 但没有规则覆盖"

# 把反馈升级为提案
agency propose --type rule-add --title "新增 XXX 规则" --evidence "来自 javert 项目 XXX 任务"

# 生成本轮评审简报
agency review

# 合并前守门
agency validate
```

## 五、规则速览

- 治理规则：`rules/evolution.md`
- 评审角色：`agents/leadership/agency-curator.md`
- 评审流程：`workflows/evolution-review.md`
- 版本历史：`CHANGELOG.md`

## 六、指标（metrics.md）

每次评审后更新：

- 提案数 / 合并数 / 拒绝数 / 合并率
- 反馈按 kind 分布（gap 多 = 规则库盲区）
- 被反馈命中最多的规则（优先评审）
- 超过 90 天未更新的规则（老化候选）

指标的意义不是 KPI，而是**发现"该进化哪里"**。
