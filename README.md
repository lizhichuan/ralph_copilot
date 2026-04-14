# Ralph for GitHub Copilot CLI

Ralph 是一个自主 AI 代理循环，专为 GitHub Copilot CLI 设计。它重复运行 Copilot CLI 直到所有 PRD 项目完成。

基于 [snarktank/ralph](https://github.com/snarktank/ralph) 项目改编，适配 GitHub Copilot CLI。

## 功能

- 自主运行 AI 编码任务，无需人工干预
- 每次迭代使用干净的上下文（fresh context）
- 通过 git 历史、`progress.txt` 和 `prd.json` 保持记忆
- 自动质量检查（类型检查、测试）
- 自动提交和更新进度

## 前提条件

- GitHub Copilot CLI 已安装并认证
  - 安装：`curl -fsSL https://gh.io/copilot-install | bash`
  - 或：`brew install copilot-cli`
  - 或：`npm install -g @github/copilot`
- `jq` 已安装（macOS: `brew install jq`）
- 项目已在 git 仓库中

## 安装

```bash
# 复制 ralph 文件到你的项目
mkdir -p scripts/ralph
cp -r ~/sourcecode/ralph-copilot/* scripts/ralph/
chmod +x scripts/ralph/ralph.sh
```

## 使用流程

### 1. 创建 PRD

创建 `prd.json` 文件，定义用户故事。参考 `prd.json.example`。

### 2. 运行 Ralph

```bash
# 默认 10 次迭代
./scripts/ralph/ralph.sh

# 指定最大迭代次数
./scripts/ralph/ralph.sh 20

# 使用实验模式（启用 Autopilot）
./scripts/ralph/ralph.sh --experimental
```

## 核心文件

| 文件 | 用途 |
|------|------|
| `ralph.sh` | Bash 循环脚本，启动 Copilot CLI |
| `COPilot.md` | Copilot CLI 的提示模板 |
| `prd.json` | 用户故事列表和完成状态 |
| `progress.txt` | 追加式进度日志 |
| `prd.json.example` | PRD 格式示例 |

## 工作原理

1. 从 PRD `branchName` 创建/切换到功能分支
2. 选择优先级最高且 `passes: false` 的用户故事
3. 运行 Copilot CLI 实现该故事
4. 运行质量检查（类型检查、测试）
5. 如果检查通过，提交更改
6. 更新 `prd.json` 标记故事为 `passes: true`
7. 追加进度到 `progress.txt`
8. 重复直到所有故事完成或达到最大迭代次数

## 关键概念

### 每次迭代 = 新鲜上下文

每次迭代启动一个**新的 Copilot CLI 实例**，上下文是干净的。迭代之间的记忆仅通过：
- Git 历史（之前迭代的提交）
- `progress.txt`（学到的经验）
- `prd.json`（哪些故事完成了）

### 小任务

每个 PRD 项目应该足够小，能在一个上下文窗口内完成。

合适的故事：
- 添加数据库字段和迁移
- 向现有页面添加 UI 组件
- 更新 server action 的新逻辑

太大的故事（需要拆分）：
- "构建整个仪表板"
- "添加认证"
- "重构 API"

### 反馈循环

Ralph 只有在有反馈循环时才有效：
- 类型检查捕获类型错误
- 测试验证行为
- CI 必须保持绿色
