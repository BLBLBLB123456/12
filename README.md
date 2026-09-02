# 观行镜（HarmonyOS NEXT）

原生 ArkTS / ArkUI 行为观察应用，面向 HarmonyOS NEXT 手机和平板。应用记录图片中可直接观察的姿态、视线与动作线索，不做人脸身份识别、读心、测谎或心理诊断。

## 当前功能

- 调用 HarmonyOS 系统相机选择器拍照，无需应用长期持有相机权限
- 从系统图库选择照片
- 本地选择并整理可观察行为线索
- 可选 HTTPS 云端视觉分析，失败时自动降级到本地
- 最多 50 条设备本地历史报告
- “基本准确 / 部分准确 / 不准确”反馈
- 将文字报告导出到系统剪贴板
- 首次拍摄同意提示、隐私说明和高风险用途限制

## 用 DevEco Studio 运行

### 环境

- DevEco Studio 5.0.0 或更新版本
- HarmonyOS NEXT SDK，API 12 或更新版本
- 真机或 HarmonyOS NEXT 模拟器

### 步骤

1. 在 DevEco Studio 中选择 **Open**，打开本仓库根目录。
2. 等待 ohpm 与 Hvigor 同步完成。
3. 打开 **File → Project Structure → Signing Configs**。
4. 登录华为开发者账号并启用自动签名，或选择自己的调试证书。
5. 选择 `entry` 模块和真机/模拟器，点击 **Run**。

系统相机选择器在真机上的行为最完整。模拟器没有相机时，可使用“从图库选择”验证完整流程。

## 生成 HAP

在 DevEco Studio 中选择 **Build → Build Hap(s)/APP(s) → Build Hap(s)**。输出通常位于：

```text
entry/build/default/outputs/default/
```

可安装到真机的 HAP 必须用与你的设备/开发者账号匹配的证书签名。仓库不包含证书或私钥。

## 正式发布前

- 把 `AppScope/app.json5` 中的 `bundleName` 改成你在 AppGallery Connect 注册的包名。
- 配置正式签名，并使用 release 构建。
- 补充主体对应的隐私政策和用户隐私保护说明。
- 若开启云端模式，部署符合 [云端接口约定](docs/cloud-api.md) 的服务，并披露图片处理目的、保存期限和删除方式。
- 在真机测试系统相机、图库 URI、弱网降级、历史记录与剪贴板导出。

## 工程结构

```text
AppScope/                       应用级配置
entry/src/main/ets/
  entryability/                Stage 模型入口
  model/                       本地分析、云端适配、持久化
  pages/                       ArkUI 页面
entry/src/main/resources/      字符串、颜色、图标与页面路由
docs/cloud-api.md              云端服务契约
```

## 隐私边界

云端模式默认关闭。本地报告保存在应用 Preferences 中，最多 50 条。图片 URI 由系统媒体组件提供；卸载应用或清除记录后，报告不可恢复。此工具不得用于招聘、授信、保险、教育录取、执法或医疗诊断等高风险决策。
