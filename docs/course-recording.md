# 实验过程记录：完整使用与演示教程

本教程演示如何打开真实 rCore 实验仓库，在另一个窗口看到操作记录，并找到已经保存的日志文件。日常使用只需运行仓库根目录的 `course.py`。

## 1. 开始前确认

- 使用包含 `course.py` 和 `.course-monitor/` 的课程仓库版本。仅克隆上游原始仓库不代表已经包含这些本地新增文件。
- 已安装 Python 3.10+、Git、VS Code 1.93+。
- Windows 上推荐 PowerShell 7，以便采集 VS Code 集成终端命令。
- 演示 Codex 时，另需已安装、登录且网络可用的 Codex CLI；文件操作演示不需要 Codex。

工具运行在学生本机，日志保存在学生的实验仓库中。实时日志窗口也是本机查看器，目前不是老师端远程监控网站。

## 2. 最短演示路径

### 第一步：启动

首次使用，在 PowerShell 中克隆本课程仓库并启动：

```powershell
git clone https://github.com/numpy1314/tg-rcore-tutorial.git
cd tg-rcore-tutorial
python3 course.py
```

如果换了电脑或移动了仓库，先进入实际仓库目录，再运行 `python3 course.py`。无需修改脚本中的路径。

脚本会安装随仓库提供的 VS Code 插件、配置 Git 提交 Hook，然后打开真实实验仓库和独立的实时日志窗口（Windows）。如果 VS Code 弹出工作区信任提示，请确认信任你正在演示的课程仓库。后续操作在本次打开的 VS Code 窗口中进行。

Linux/macOS 使用相同入口，但日志在启动脚本的终端中持续显示。需要另一个终端运行其他命令。

### 第二步：操作一个实验文件

在 VS Code 中：

1. 打开 `tg-rcore-tutorial-ch1/src/main.rs`。
2. 在文件中单独添加一行注释 `// course demo`。
3. 按 `Ctrl+S` 保存。
4. 点击“终端 → 新建终端”，在 VS Code 内运行：

```powershell
git status
```

演示后可以删除刚加的注释并保存，恢复文件内容。恢复动作也会产生记录。

### 第三步：观察实时日志窗口

将 VS Code 和日志窗口并排放置。等待片刻，应能看到对应的新事件：

| 操作 | 预期记录 |
|---|---|
| 打开实验文件 | 文件打开事件及文件路径 |
| 添加注释 | 文件修改事件；短时间内多次修改可能合并 |
| 保存文件 | 文件保存事件 |
| 执行 `git status` | 命令开始、结束及退出码，前提是终端支持 Shell Integration |

每条事件带有时间信息。点击日志窗口中的记录可以查看详情。文件修改事件不包含具体代码行或源码差异。

### 第四步：查看保存下来的日志

在 VS Code 左侧展开 `.ai/events/`，打开最近更新的 `.jsonl` 文件。每一行是一个独立的 JSON 事件。

也可以在仓库终端运行以下 Windows 命令，直接打开日志文件夹：

```powershell
explorer.exe .ai\events
```

这些文件是实际落盘的日志。关闭日志窗口后文件仍然保留，下次运行 `python3 course.py logs` 可以重新查看。

**演示成功的判断：刚才操作的文件路径和事件类型，既出现在实时窗口中，也能在 `.ai/events/` 的日志文件中找到。**

## 3. 演示一次真实 Codex 调用

在实验仓库的终端运行：

```powershell
python3 course.py codex
```

出现“请输入实验问题”后，输入一行问题并回车，例如：

```text
请阅读 tg-rcore-tutorial-ch1/src/main.rs，用中文简要说明启动流程，不要修改文件。
```

等待调用结束，终端会显示回答。实时窗口和 `.ai/events/` 中会记录本次会话、输入的问题，以及 Codex 实际产生的命令结果或文件操作事件。没有发生的操作不会产生对应事件。

默认调用为只读。如确实需要演示 AI 修改实验文件，使用：

```powershell
python3 course.py codex --allow-edits
```

每次运行这个入口提交一个问题。当前课程日志不保存 AI 完整回答、推理过程、命令输出或源码 diff，因此它不是完整对话存档。普通 Codex 桌面聊天或扩展聊天不会被这个入口自动采集。

## 4. 日志、快照和程序在哪里

以下路径均相对于实验仓库根目录：

```text
tg-rcore-tutorial/
├─ course.py                 # 日常使用入口
├─ .course-monitor/          # 随仓库分发的插件和辅助脚本
├─ .ai/
│  ├─ events/                # 自动保存的本地事件日志（JSONL）
│  ├─ submissions/           # 用于随作业提交的增量快照
│  └─ ide/                   # 本机工作区配置、查看器状态等
└─ docs/course-recording.md  # 本教程
```

日常检查保存记录请查看 `.ai/events/`。如果旧 Demo 留有 `.ai/ide/rewind.db`，它是此前 SQLite 路线的产物，不是当前入口的日志验收位置。

需要手动生成提交快照时，在仓库根目录运行：

```powershell
python3 course.py export
```

这会导出尚未导出的事件；有新事件时生成 `.ai/submissions/` 下的增量快照，不会自动提交或上传。没有新事件时可能没有新快照。

已配置的提交 Hook 会在正常 Git 提交前导出并暂存增量快照。原始 `.ai/events/` 和本机 `.ai/ide/` 默认被 Git 忽略；`.ai/submissions/` 用于随代码提交。上传仍依赖正常的 Git 推送，工具不会自动把本地日志发送到老师的服务器。

## 5. 日常命令速查

在实验仓库根目录执行：

| 命令 | 用途 |
|---|---|
| `python3 course.py` | 配置并打开实验仓库和实时日志 |
| `python3 course.py logs` | 只打开日志查看器 |
| `python3 course.py status` | 查看记录开关、日志位置和文件数量 |
| `python3 course.py install` | 只配置插件和提交 Hook |
| `python3 course.py codex` | 发起一次只读 Codex 调用并记录 |
| `python3 course.py codex --allow-edits` | 发起允许修改文件的 Codex 调用 |
| `python3 course.py export` | 手动导出增量快照，不自动提交 |

关闭查看器只结束查看，不会停止仍在运行的 VS Code 插件采集。

需要关闭项目记录时，将 `.course-monitor/config.json` 中的 `enabled` 改为 `false`，保存后在 VS Code 命令面板执行 `Developer: Reload Window`。恢复记录时改回 `true` 并再次重载。已保存的日志不会因此删除。

## 6. 当前采集范围

| 类别 | 当前行为 |
|---|---|
| 文件操作 | 项目内文件打开、关闭、修改、保存、新建、重命名和删除 |
| 终端与任务 | 支持 Shell Integration 的 VS Code 集成终端命令、退出码等，以及 Tasks 事件 |
| AI 操作 | 课程 Codex 入口的 Prompt、会话和最终操作事件 |
| 不采集的内容 | 光标移动、逐键输入、源码 diff、终端输出和 AI 推理过程 |
| 操作者归因 | 普通文件事件不能单独证明由人或 AI 操作；明确的 AI 归因来自专用入口 |

采集会排除配置定义的敏感路径及日志目录，并在写入前做规则脱敏。自由文本脱敏有识别边界，不能保证任意密码或敏感内容都能自动识别。

## 7. 常见问题

### 找不到 Python、Git 或 VS Code

先确认相应程序已安装且可在终端调用。Windows 若 `python3` 不可用，但已安装的 `python` 为 3.10 或更高版本，可以将命令中的 `python3` 换成 `python`。安装程序后重新打开终端再尝试。

### 打开了窗口，但没有新的文件记录

确认操作的是脚本打开的实验仓库，工作区已受信任，课程插件已启用，配置中的 `enabled` 为 `true`。执行 `Developer: Reload Window` 后，重新打开并保存一个普通实验文件。不要用 `.ai/` 中的文件测试采集，它们被排除。

### 文件记录正常，但没有终端命令记录

请在 VS Code 内新建终端再测试，不要使用外部 PowerShell 窗口。Windows 推荐使用脚本配置的 `Course PowerShell`（需要 PowerShell 7）。确认终端 Shell Integration 已启用。

### 日志窗口被关掉了

运行 `python3 course.py logs`，无需重新安装。Windows 会重新打开独立窗口；Linux/macOS 在当前终端查看，按 `Ctrl+C` 结束查看。

### Codex 调用失败

根据终端错误确认 Codex CLI 是否可找到、账号是否已登录、网络是否可用。失败记录不等于 AI 任务已完成，以终端结果为准。文件操作采集可以独立演示。

### 提示已有 Git Hook

脚本会保留已有 Hook 并停止配置。请由助教将课程导出流程与原有 Hook 整合后再安装，不要直接覆盖原有提交检查。

## 8. 发给其他学生或放入容器

分发课程仓库时，需要同时包含 `course.py`、`.course-monitor/` 中的插件及辅助脚本，以及本教程。学生只运行一个入口，但不能只复制 `course.py` 而遗漏依赖。不要把本机 `.ai/events/` 中的已有日志当作程序文件一起分发。

在已具备实验运行环境的容器内，可先在仓库根目录初始化提交 Hook：

```sh
python3 course.py install --skip-extension
```

随后在连接到该容器的 VS Code 中，通过“Extensions: Install from VSIX...”选择 `.course-monitor/rewind-ide-0.3.0.vsix`，确保扩展安装在容器工作区侧。容器终端可运行 `python3 course.py logs` 查看事件。

这个入口不负责安装 Rust、QEMU 或构建内核，实验运行仍按各章节 README 操作。
