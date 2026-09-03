# Vue Rules

## 摘要（注入用）

- 跟随项目已有 Vue 写法（现有 Composition API + `<script setup>` 则保持）；版本以项目为准。
- 页面、业务组件、基础组件职责分离。
- API 用明确 TypeScript 类型，不用 `any` / 无约束对象传业务数据。
- 异步必须覆盖 loading / empty / error / retry；表格筛选分页优先复用项目已有模式。
- 不为视觉效果改业务逻辑和页面布局，除非需求明确要求。
- 状态管理、UI 库以项目既有方案为准，不擅自引入新框架。

## 全文

1. 新代码跟随当前仓库已有的 Vue 风格；若项目已用 Composition API + `<script setup>`，保持一致。版本以项目 `AGENTS.md` / `package.json` 为准。
2. 页面、业务组件、基础组件职责分离。
3. API 参数使用明确 TypeScript 类型，不使用无约束 `any` / Map 式对象传递业务数据。
4. 组件内状态优先放本地；跨页共享用项目已经在用的方案，不在中央强制 Pinia。
5. 所有异步请求考虑 loading、empty、error、retry 状态。
6. 表格、筛选、分页组件优先复用已有项目模式。
7. 不为了视觉效果改变原有业务逻辑和页面布局，除非需求明确要求。
8. UI 组件库以项目既有依赖为准，不擅自引入新的 UI 框架。
