# 20秒点点乐 (TapGame)

一款专为 iOS 16+ 设计的轻量级纯原生 SwiftUI 反应力小游戏。支持 iPhone 与 iPad。

## 游戏特点
- **3×3 经典九宫格布局**：自适应 iPhone 与 iPad 屏幕显示。
- **随机目标**：红色的目标方格随机跳动，轻触得分 +1 并触发震动反馈。
- **20 秒限时挑战**：顶部倒计时与动态进度条，紧张刺激。
- **高分持久化**：使用 `UserDefaults` 自动记录并保存历史最高分。
- **零外部依赖**：纯原生 SwiftUI 构建，无第三方库，不依赖后端服务器。

## 项目结构
```text
TapGame/
├── .github/
│   └── workflows/
│       └── build-ipa.yml              # GitHub Actions 自动化打包未签名 IPA
├── TapGame/
│   ├── App/
│   │   └── TapGameApp.swift           # App 入口
│   ├── Views/
│   │   ├── ContentView.swift          # 主游戏界面、仪表盘与结算弹窗
│   │   └── GridButtonView.swift       # 九宫格单个按键与动画效果
│   ├── ViewModels/
│   │   └── GameViewModel.swift        # 游戏状态机、计时器与 UserDefaults 逻辑
│   └── Resources/
│       ├── Info.plist                 # 应用权限与多设备适配配置
│       └── Assets.xcassets/           # 图标与配色资源
└── TapGame.xcodeproj/                 # Xcode 工程配置与构建 Scheme
```

## 构建与签名安装
1. 将本仓库推送至个人 GitHub 仓库。
2. 进入 GitHub Actions 标签页，触发或等待 `Build Unsigned iOS IPA` 工作流运行完成。
3. 在 Actions Run 的 Artifacts 中下载 `TapGame-unsigned-ipa`（即 `TapGame_unsigned.ipa`）。
4. 在 iPad / iPhone 上使用 **全能签 (Esign)** / **TrollStore** / **巨魔** 导入该 IPA，完成个人签名并安装即可。
