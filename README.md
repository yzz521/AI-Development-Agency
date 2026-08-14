# AI Development Agency — 项目初始化脚本

## 批量接入

```bash
cd ~/workspace/AI-Development-Agency
./scripts/init-all.sh ~/workspace
```

## 单个项目

```bash
./scripts/init-project.sh ../project-a
```

## 检查

```bash
./scripts/doctor.sh ../project-a
```

## 递归扫描

```bash
RECURSIVE=1 ./scripts/init-all.sh ~/workspace
```

## 删除链接

```bash
./scripts/remove-link.sh ../project-a
```

## 核心约定

每个项目统一使用：

```text
.ai/agency/
```

作为 AI Development Agency 的稳定入口。

中央仓库位置可以变化，项目内不保存绝对路径。
