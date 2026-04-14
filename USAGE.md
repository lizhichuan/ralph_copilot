# Ralph for GitHub Copilot CLI - 使用指南

## 快速开始

### 1. 安装依赖

```bash
# 安装 GitHub Copilot CLI
curl -fsSL https://gh.io/copilot-install | bash

# 或使用 Homebrew (macOS)
brew install copilot-cli

# 或使用 npm
npm install -g @github/copilot

# 安装 jq
brew install jq  # macOS
sudo apt-get install jq  # Linux
```

### 2. 认证 GitHub

```bash
copilot
# 然后按照提示登录 GitHub
```

### 3. 在你的项目中初始化 Ralph

```bash
# 复制 Ralph 文件到你的项目
mkdir -p scripts/ralph
cp -r ~/sourcecode/ralph-copilot/* scripts/ralph/
cd scripts/ralph

# 运行初始化脚本
./init-ralph.sh
```

### 4. 配置 PRD

编辑 `prd.json` 文件，添加你的用户故事：

```json
{
  "project": "MyApp",
  "branchName": "ralph/user-auth",
  "description": "用户认证系统",
  "userStories": [
    {
      "id": "US-001",
      "title": "添加用户数据库表",
      "description": "作为开发者，我需要存储用户信息以便进行认证。",
      "acceptanceCriteria": [
        "创建 users 表，包含 id, email, password_hash 字段",
        "生成并运行迁移",
        "类型检查通过"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### 5. 运行 Ralph

```bash
# 运行最多 10 次迭代
./ralph.sh

# 运行最多 20 次迭代
./ralph.sh 20

# 使用实验模式（启用 Autopilot）
./ralph.sh --experimental
```

## 最佳实践

### 编写好的用户故事

✅ **好的故事（小到可以在一次迭代中完成）：**
- 添加数据库字段和迁移
- 向现有页面添加 UI 组件
- 更新 API 端点的新逻辑
- 添加过滤器下拉菜单

❌ **太大的故事（需要拆分）：**
- "构建整个仪表板"
- "添加认证系统"
- "重构 API 层"

### 质量检查

自定义 `quality-check.sh` 脚本以适应你的项目：

```bash
# 编辑 quality-check.sh
# 添加你的项目特定的检查命令
```

### 进度跟踪

- `progress.txt` - 追加式进度日志，包含学到的经验
- `prd.json` - 用户故事状态（passes: true/false）
- Git 历史 - 每次迭代的提交

### 分支管理

Ralph 会自动：
1. 从 `prd.json` 的 `branchName` 读取目标分支
2. 创建或切换到该分支
3. 如果分支名称改变，自动归档之前的运行

## 故障排除

### Copilot CLI 未找到

```bash
# 检查安装
which copilot

# 重新安装
curl -fsSL https://gh.io/copilot-install | bash
```

### 认证问题

```bash
# 重新认证
copilot /login
```

### 迭代失败

检查 `progress.txt` 了解上次迭代的详细信息：

```bash
cat progress.txt
```

### 手动更新 PRD

如果需要手动标记故事为完成：

```bash
./update-prd.sh US-001
```

## 高级用法

### 自定义提示

编辑 `COPilot.md` 文件以自定义 AI 代理的行为。

### 添加 MCP 服务器

在 Copilot CLI 中配置 MCP 服务器以扩展功能：

```bash
copilot
/mcp add <server-name>
```

### 使用 Autopilot 模式

实验模式启用 Autopilot，让 AI 更自主地工作：

```bash
./ralph.sh --experimental
```

在 Copilot CLI 中，按 `Shift+Tab` 切换到 Autopilot 模式。

## 文件结构

```
ralph-copilot/
├── README.md           # 项目说明
├── ralph.sh            # 主循环脚本
├── COPilot.md          # Copilot CLI 提示模板
├── prd.json            # 用户故事列表（运行时）
├── prd.json.example    # PRD 格式示例
├── progress.txt        # 进度日志（运行时）
├── progress.txt.template # 进度日志模板
├── update-prd.sh       # 更新 PRD 工具
├── quality-check.sh    # 质量检查脚本
├── init-ralph.sh       # 初始化脚本
├── LICENSE             # MIT 许可证
└── .gitignore          # Git 忽略文件
```

## 与原始 Ralph 的区别

这个项目是基于 [snarktank/ralph](https://github.com/snarktank/ralph) 的改编版本，主要区别：

1. **AI 工具**: 使用 GitHub Copilot CLI 而不是 Claude Code 或 Amp
2. **提示文件**: 使用 `COPilot.md` 而不是 `CLAUDE.md` 或 `prompt.md`
3. **命令**: 使用 `copilot` 命令而不是 `claude` 或 `amp`
4. **实验模式**: 支持 Copilot CLI 的 `--experimental` 标志和 Autopilot 模式

## 贡献

欢迎提交问题和拉取请求！

## 许可证

MIT License - 见 LICENSE 文件
