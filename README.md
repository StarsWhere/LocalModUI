# LocalModUI

Beat Saber 1.45.2_28848 / Windows x64 的自定义模组中心与公共导航。

从 [Releases](https://github.com/StarsWhere/LocalModUI/releases) 下载安装包，关闭游戏后将 Plugins 目录合并到游戏目录。依赖 BSIPA、BSML 和 SiraUtil，版本范围见 `scripts/local_mod_ui/manifest.json`。本次使用含本地移植版的依赖环境，未追加游戏或 VR 测试。

## 构建

需要 PowerShell 7、.NET 8 SDK 或更新版本，以及带兼容模组依赖的游戏安装。

```powershell
git clone https://github.com/StarsWhere/LocalModUI.git
cd LocalModUI
pwsh -File scripts/build_release.ps1 -GameRoot 'C:\Games\Beat Saber'
```

`scripts/build.ps1` 只编译本模组。发布包、源码包和 SHA256 校验文件写入 `releases/`，临时文件写入 `.tmp/`，不安装或修改游戏。

## 公共源码

其他模组通过固定提交的 Git 子模块引用本仓库。`scripts/shared_http_contracts` 提供 JSON 契约校验，`scripts/contract_generator` 提供契约代码生成器，`scripts/shared_profiles` 提供公共配置存储。它们不包含其他模组的功能实现。

原创代码使用 [MIT](LICENSE)，第三方声明见 [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt)。
