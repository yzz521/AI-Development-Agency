# Check Contract — 增量规范门禁

## 目的

注入（AGENTS.md / 技能 / Cursor 规则）只降低违规概率。
**强制**只来自：git hook + CI，检查的是 diff 里的新增行，不是全仓库存量。

## 单一真相

```text
checks/catalog.tsv
```

业务仓库开关（可提交，覆盖 catalog 的 default）：

```text
agency-check.conf
```

## 命令

```text
agency check [dir]                 # 工作区相对 HEAD 的增量 + 未跟踪文件
agency check --staged [dir]        # 暂存区（pre-commit）
agency check --base <ref> [dir]    # 相对 ref 的三路 diff（CI / PR）
agency check --all [dir]           # 全量扫描，只做存量台账，不当默认门禁
agency check --install [dir]       # 写入 hook / CI / 可提交的检查副本
agency check --list [dir]          # 列出检查项及当前开关
```

`agency check` **不再**是 `agency status` / `doctor` 的别名。

## 默认开启（on）

| id | 对应规则 | 为什么能机检 |
| --- | --- | --- |
| `java-map-object` | `rules/java.md` | `Map<String, Object>` 形态稳定 |
| `sql-select-star` | `rules/sqlserver.md` | `SELECT *` 形态稳定 |
| `secret-hardcoded` | `rules/global.md` | 明文 password/secret，排除 `${ENV}` |

## 默认关闭（off）

| id | 原因 |
| --- | --- |
| `java-pathvariable` | 无法区分业务参数与资源 id |
| `sql-limit` / `sql-backtick` | 中央规则未收 |
| `java-fqcn` | 排除 import 前曾误报约 18 倍 |
| `java-requestbody-valid` | 注解分行会漏检或误报 |
| `java-sensitive-log` | 敏感字段清单未定 |

不要把 Javert 专有项（一律 POST、`ylzzjgdm`）做成中央默认 on。

## 增量语义

- 只看 **added** 行（`git diff -U0` 的 `+` 行）。
- 改到「本来就违规」的旧行、但没有新增多余违规 → **不拦**。
- `--all` 才扫整文件，用于债务台账，不作为 hook/CI 默认。

## 存量治理（与门禁分开）

增量门禁**不**按库龄自动 FAIL。存量另开节奏：

1. 每月（或每个迭代）在业务仓跑一次：`agency check --all 2>&1 | tee agency-stock-YYYYMM.log`
2. 把命中按模块记入台账（文件、检查 id、是否本迭代清），不要把 log 当 hook。
3. 清理走普通 PR，清一块少一块；未清的继续留在台账。
4. 禁止为了「看起来干净」把 `--all` 接到 pre-commit / CI。

`agency debt` 收割的是 `agency:` 简化留痕，和本表的机检存量不是同一件事。

## 跳过

- `import` / `package` 行（java-map-object、java-fqcn）
- 注释行（`//` `/*` `*` `--` `#` `<!--`）
- 示例/文档：`*.md`、路径含 `/docs/`、文件名含 `example`/`sample`
- 生成物与依赖：`node_modules/` `target/` `dist/` `build/` `.git/` `.agency-check/`

## 安装产物（均可提交）

`.ai/` 在不少业务仓是 gitignore，门禁文件不能放进去。

| 路径 | 作用 |
| --- | --- |
| `agency-check.conf` | 开关与 CI base |
| `.agency-check/check.sh` + `catalog.tsv` | 不依赖软链接也能跑 |
| `.githooks/pre-commit` | 本机拦截；需 `git config core.hooksPath .githooks` |
| `.github/workflows/agency-check.yml` | PR/push 强制 |
| `.agents/skills/agency-check/` | 技能提示，**无强制力** |

不要绑进每次 `agency init`，避免没准备好的仓库被 hook 吓到。

## 禁止

- 用全量扫描当默认门禁去卡存量。
- 把魔法值、DTO 语义、医疗口径做成机检。
- 为了过门禁而关检查或把违规写进注释。
