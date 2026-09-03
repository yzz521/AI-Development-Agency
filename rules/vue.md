# Vue Rules

## 摘要（注入用）

- Vue 3 + Composition API + `<script setup>`。
- API 用明确 TypeScript 类型，不用 `any` / 无约束对象传业务数据。
- 状态优先组件本地，跨页再 Pinia；异步必须覆盖 loading / empty / error / retry。
- 表格筛选分页优先复用项目已有模式；不为视觉效果改业务逻辑。

## 全文

1. Vue 3 + Composition API + `<script setup>` 为默认。
2. 页面、业务组件、基础组件职责分离。
3. API 参数使用明确 TypeScript 类型，不使用无约束 `any` / Map 式对象传递业务数据。
4. 状态优先放在组件本地；跨页面共享状态再使用 Pinia。
5. UI 不以蓝紫渐变作为默认审美。
6. 复杂医疗后台优先保证信息层级、数据密度、扫描效率和可操作性。
7. 所有异步请求考虑 loading、empty、error、retry 状态。
8. 表格、筛选、分页组件优先复用已有项目模式。
9. 不为了视觉效果改变原有业务逻辑和页面布局，除非需求明确要求。
