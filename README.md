# Ralph for GitHub Copilot CLI

Ralph 是一个自主 AI 代理循环，**直接在 GitHub Copilot CLI 内部运行**，无需外部 bash 脚本。

基于 [snarktank/ralph](https://github.com/snarktank/ralph) 项目改编。

## 快速开始

### 1. 安装依赖

```bash
# 安装 GitHub Copilot CLI
curl -fsSL https://gh.io/copilot-install | bash
# 或：brew install copilot-cli
# 或：npm install -g @github/copilot

# 安装 jq
brew install jq  # macOS
```

### 2. 认证

```bash
copilot
# 按提示登录 GitHub
```

### 3. 在你的项目中设置

```bash
cd /path/to/your/project

# 复制 Ralph 文件
mkdir -p scripts/ralph
cp -r ~/sourcecode/ralph-copilot/* scripts/ralph/

# 初始化
cd scripts/ralph
./init-ralph.sh
```

### 4. 在 Copilot CLI 中运行 Ralph

```bash
cd /path/to/your/project/scripts/ralph

# 启动 Copilot CLI（启用实验模式）
copilot --experimental
```

然后在 Copilot CLI 中说：

```
Load the ralph-run skill and execute all pending stories in prd.json
```

或者按 `Shift+Tab` 切换到 **Autopilot** 模式，然后说：

```
Run Ralph - implement all stories in prd.json where passes is false
```

---

## 核心文件

| 文件 | 用途 |
|------|------|
| `prd.json` | 用户故事列表和完成状态 |
| `progress.txt` | 追加式进度日志 |
| `skills/ralph-run/SKILL.md` | Ralph 运行技能（在 Copilot CLI 中使用） |
| `skills/prd/SKILL.md` | PRD 生成技能 |
| `skills/ralph/SKILL.md` | PRD 转 JSON 技能 |

---

## 完整工作流

### 步骤 1：生成 PRD

在 Copilot CLI 中：

```
Load the prd skill and create a PRD for adding user authentication
```

回答澄清问题，PRD 会保存到 `tasks/prd-user-auth.md`。

### 步骤 2：转换为 Ralph 格式

```
Load the ralph skill and convert tasks/prd-user-auth.md to prd.json
```

这会创建 `prd.json` 文件。

### 步骤 3：运行 Ralph

```
Load the ralph-run skill and execute all pending stories
```

Ralph 会：
1. 读取 `prd.json` 找到第一个 `passes: false` 的故事
2. 实现该故事
3. 运行质量检查
4. 提交更改
5. 更新 `prd.json` 和 `progress.txt`
6. 继续下一个故事，直到全部完成

### 步骤 4：完成

当所有故事完成后，Ralph 会显示：

```
<promise>COMPLETE</promise>

All user stories completed!
- Total stories: 4
- Completed in 4 iterations
```

---

## 使用 Autopilot 模式

Autopilot 模式让 Ralph 更自主地工作：

1. 启动 Copilot CLI：`copilot --experimental`
2. 按 `Shift+Tab` 切换到 **Autopilot** 模式
3. 输入：`Run Ralph on prd.json`
4. Ralph 会自主工作直到完成

---

## 关键概念

### 每次迭代 = 新鲜上下文

Ralph 每次实现一个故事后会结束当前会话。下次迭代是新的 Copilot CLI 实例，但通过以下保持记忆：
- Git 历史（提交）
- `progress.txt`（学到的经验）
- `prd.json`（完成状态）

### 小任务

每个故事应该足够小，能在一次迭代中完成：

✅ **好的：**
- 添加数据库字段和迁移
- 向现有页面添加 UI 组件

❌ **太大：**
- "构建整个仪表板"
- "添加认证系统"

---

## 命令参考

```bash
# 初始化 Ralph
./init-ralph.sh

# 在 Copilot CLI 中运行（外部启动）
copilot --experimental
# 然后：Load the ralph-run skill and execute all pending stories

# 手动更新 PRD 状态
./update-prd.sh US-001

# 查看剩余故事
jq '.userStories[] | select(.passes == false) | .title' prd.json

# 查看进度
cat progress.txt
```

---

## 项目结构

```
your-project/
└── scripts/ralph/
    ├── prd.json                 # 用户故事（运行时）
    ├── progress.txt             # 进度日志（运行时）
    ├── init-ralph.sh            # 初始化脚本
    ├── update-prd.sh            # 更新 PRD 工具
    └── skills/
        ├── prd/SKILL.md         # PRD 生成器
        ├── ralph/SKILL.md       # PRD 转 JSON
        └── ralph-run/SKILL.md   # Ralph 运行器
```

---

## 故障排除

### Copilot CLI 未找到
```bash
curl -fsSL https://gh.io/copilot-install | bash
```

### 认证问题
```bash
copilot /login
```

### prd.json 格式错误
```bash
jq empty prd.json  # 验证 JSON 格式
```

---

## 与原始 Ralph 的区别

| 特性 | 原始 Ralph | ralph-copilot |
|------|-----------|---------------|
| 运行方式 | bash 脚本外部循环 | Copilot CLI 内部技能 |
| AI 工具 | Claude Code / Amp | GitHub Copilot CLI |
| Autopilot | 无 | 支持（Shift+Tab） |
| 技能 | claude-code | ralph-run |

---

## 许可证

MIT License
