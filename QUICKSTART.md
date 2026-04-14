# Ralph for Copilot CLI - 快速启动指南

## 30 秒开始

### 1. 安装 Copilot CLI（如果未安装）

```bash
curl -fsSL https://gh.io/copilot-install | bash
```

### 2. 认证

```bash
copilot
# 按提示登录 GitHub
```

### 3. 在你的项目中运行

```bash
# 进入你的项目
cd /path/to/your/project

# 复制 Ralph
mkdir -p scripts/ralph
cp -r ~/sourcecode/ralph-copilot/* scripts/ralph/
cd scripts/ralph

# 初始化
./init-ralph.sh

# 启动 Copilot CLI
copilot --experimental
```

### 4. 在 Copilot CLI 中运行 Ralph

```
Load the ralph-run skill and execute all pending stories in prd.json
```

完成！Ralph 会自动实现所有用户故事。

---

## 详细流程

### 场景 1：从想法到完成

```bash
# 1. 启动 Copilot CLI
copilot --experimental

# 2. 生成 PRD
Load the prd skill and create a PRD for adding a dark mode toggle

# 3. 转换为 Ralph 格式
Load the ralph skill and convert tasks/prd-dark-mode.md to prd.json

# 4. 运行 Ralph
Load the ralph-run skill and execute all pending stories
```

### 场景 2：已有 PRD

```bash
# 1. 复制 Ralph 文件到你的项目
mkdir -p scripts/ralph
cp -r ~/sourcecode/ralph-copilot/* scripts/ralph/
cd scripts/ralph

# 2. 把你的 prd.json 放在这里
# （或用 ralph skill 转换现有 PRD）

# 3. 启动并运行
copilot --experimental
# 然后：Load the ralph-run skill and run on prd.json
```

### 场景 3：使用 Autopilot

```bash
copilot --experimental

# 按 Shift+Tab 切换到 Autopilot 模式
# 然后输入：
Run Ralph on prd.json - implement all pending stories autonomously
```

---

## 技能说明

### prd - PRD 生成器

**用途**：创建产品需求文档

**触发词**：
- "create a prd"
- "write prd for"
- "plan this feature"

**示例**：
```
Load the prd skill and create a PRD for user authentication
```

### ralph - PRD 转换器

**用途**：将 Markdown PRD 转换为 prd.json

**触发词**：
- "convert this prd"
- "turn into ralph format"
- "create prd.json"

**示例**：
```
Load the ralph skill and convert tasks/prd-auth.md to prd.json
```

### ralph-run - Ralph 运行器

**用途**：在 Copilot CLI 内部运行 Ralph 循环

**触发词**：
- "run ralph"
- "execute all stories"
- "work autonomously"

**示例**：
```
Load the ralph-run skill and execute all pending stories in prd.json
```

---

## prd.json 格式

```json
{
  "project": "MyApp",
  "branchName": "ralph/dark-mode",
  "description": "暗色模式切换功能",
  "userStories": [
    {
      "id": "US-001",
      "title": "添加主题字段到数据库",
      "description": "作为开发者，我需要存储用户主题偏好。",
      "acceptanceCriteria": [
        "添加 theme 列：'light' | 'dark' (默认 'light')",
        "生成并运行迁移",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "显示主题切换按钮",
      "description": "作为用户，我想要切换明暗主题。",
      "acceptanceCriteria": [
        "页面右上角有主题切换按钮",
        "按钮显示当前主题图标",
        "点击切换主题并保存偏好",
        "Typecheck passes",
        "Verify in browser"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    }
  ]
}
```

---

## progress.txt 格式

```markdown
# Ralph Progress Log

Started: 2026-04-14 16:00:00

---

## Codebase Patterns

- 这个项目使用 Tailwind CSS 进行样式设计
- 所有组件都放在 src/components/ 目录
- API 调用使用 fetch 封装在 src/lib/api.ts

---

## Iteration Log

## 2026-04-14 16:05:00 - US-001

### What was implemented
- 添加了 theme 字段到 users 表
- 创建了数据库迁移

### Files changed
- `src/db/schema.ts`
- `src/db/migrations/001_add_theme.ts`

### Learnings for future iterations
- 迁移文件需要按时间戳命名
- schema.ts 导出所有表定义

---
```

---

## 常见问题

**Q: Ralph 卡住了怎么办？**

A: 检查 progress.txt 了解上次迭代的状态，可能需要手动修复某些问题后继续。

**Q: 如何中途停止？**

A: 在 Copilot CLI 中按 `Ctrl+C`，Ralph 会保存当前进度。下次运行时从 `passes: false` 的第一个故事继续。

**Q: 如何在多个项目间共享配置？**

A: 将 `skills/` 目录复制到每个项目，或全局安装到 `~/.github/copilot/skills/`。

**Q: 故事太大怎么办？**

A: 在 progress.txt 中记录，然后用 ralph skill 将大故事拆分成多个小故事。

---

## 最佳实践

1. **小步快跑** - 每个故事要足够小
2. **依赖顺序** - 数据库 → 后端 → UI
3. **验收标准可验证** - 避免模糊描述
4. **记录经验** - 每次迭代都要更新 progress.txt
5. **保持 CI 绿色** - 不要提交失败的代码

---

## 命令速查

```bash
# 初始化
./init-ralph.sh

# 启动 Copilot CLI
copilot --experimental

# 在 Copilot CLI 中
Load the ralph-run skill and execute all pending stories

# 手动更新状态
./update-prd.sh US-001

# 查看剩余故事
jq '.userStories[] | select(.passes == false) | .title' prd.json
```
