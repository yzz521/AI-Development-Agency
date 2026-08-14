# Vue Rules

1. Vue 3 + Composition API + `<script setup>` 为默认。
2. 页面、业务组件、基础组件职责分离。
3. API 参数使用明确 TypeScript 类型，不使用无约束 `any` / Map 式对象传递业务数据。
4. 状态优先放在组件本地；跨页面共享状态再使用 Pinia。
5. UI 不以蓝紫渐变作为默认审美。
6. 复杂医疗后台优先保证信息层级、数据密度、扫描效率和可操作性。
7. 所有异步请求考虑 loading、empty、error、retry 状态。
8. 表格、筛选、分页组件优先复用已有项目模式。
9. 不为了视觉效果改变原有业务逻辑和页面布局，除非需求明确要求。
10. UI 库采用 **Tailwind CSS + Element Plus 混合**：Tailwind 负责布局/间距/卡片/样式，Element Plus 负责复杂交互组件（表格、日期选择、消息提示）。
11. **禁用 Ant Design**（Vue 项目）。
12. 表单必须带校验规则（`el-form` rules），提交前校验通过才发请求。
