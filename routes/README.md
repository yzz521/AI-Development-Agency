# 规范路由表

`table.tsv` 是「任务 / 文件 → 读哪些规范」的单一真相。

## 怎么生效（不必记命令）

用户直接下任务即可。工具侧靠三层自动匹配，**不要求先跑 `agency ...`**：

1. 项目根目录 `AGENTS.md` 里的「规范路由」段（Cursor / Codex 等会自动读）
2. `.cursor/rules/agency-router.mdc`（Cursor `alwaysApply`）
3. 技能 `skills/agency-route`（按 description 自动匹配写代码任务）

`agency route` 是同一张表的检查/安装器：给人类看匹配结果，或给已安装 CLI 的环境生成项目内路由段。没有 CLI 时，智能体读本表 + 各规则文件的 `## 摘要（注入用）` 即可。

## 格式

见 `table.tsv` 文件头注释。修改路由只改这一张表，然后：

```bash
# 刷新本仓库文档中的路由段（AGENTS.md / 项目模板 / Cursor 规则模板）
agency route --refresh-docs

# 写入某个业务项目（按该项目技术栈裁剪摘要）
agency route --install ~/path/to/project
```

`scripts/validate.sh` 会检查表内 Agent / Rule / Workflow 引用可解析，且每条被路由的规则含摘要区。
