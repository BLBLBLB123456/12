import { common } from '@kit.AbilityKit';
import { promptAction, router } from '@kit.ArkUI';
import { RecordStore } from '../model/RecordStore';
import { CloudConfig } from '../model/Types';

@Entry
@Component
struct Settings {
  @State private cloudEnabled: boolean = false;
  @State private endpoint: string = '';

  aboutToAppear(): void {
    this.load();
  }

  private async load(): Promise<void> {
    const config = await RecordStore.cloudConfig(getContext(this) as common.UIAbilityContext);
    this.cloudEnabled = config.enabled;
    this.endpoint = config.endpoint;
  }

  private async save(): Promise<void> {
    if (this.cloudEnabled && !this.endpoint.startsWith('https://')) {
      promptAction.showToast({ message: '请输入 HTTPS 接口地址' });
      return;
    }
    const config: CloudConfig = { enabled: this.cloudEnabled, endpoint: this.endpoint.trim() };
    await RecordStore.saveCloudConfig(getContext(this) as common.UIAbilityContext, config);
    promptAction.showToast({ message: '设置已保存' });
  }

  private async confirmClear(): Promise<void> {
    const result = await promptAction.showDialog({
      title: '清除全部记录？',
      message: '此操作无法撤销，设备本地的观察报告和反馈都会删除。',
      buttons: [
        { text: '取消', color: '#777777' },
        { text: '清除', color: '#C73D4D' }
      ]
    });
    if (result.index === 1) {
      await RecordStore.clear(getContext(this) as common.UIAbilityContext);
      promptAction.showToast({ message: '已清除' });
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          Row() {
            Text('‹').fontSize(34).onClick(() => router.back())
            Text('设置与隐私').fontSize(24).fontWeight(FontWeight.Bold).margin({ left: 14 })
          }.width('100%').padding({ top: 20, bottom: 6 })

          Row({ space: 18 }) {
            Column({ space: 6 }) {
              Text('云端 AI 辅助').fontSize(19).fontWeight(FontWeight.Bold).width('100%')
              Text('开启后，照片会上传到你配置的服务。失败时自动使用本地模式。')
                .fontSize(14).fontColor('#73798B').lineHeight(21).width('100%')
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.cloudEnabled })
              .selectedColor('#4056D6').onChange((value: boolean) => this.cloudEnabled = value)
          }.padding(20).borderRadius(20).backgroundColor(Color.White)

          if (this.cloudEnabled) {
            Column({ space: 12 }) {
              Text('云端接口地址').fontSize(18).fontWeight(FontWeight.Bold).width('100%')
              TextInput({ text: this.endpoint, placeholder: 'https://example.com/analyze' })
                .height(48).backgroundColor('#F3F4F8').borderRadius(12)
                .onChange((value: string) => this.endpoint = value)
              Text('接口接收 JSON：imageBase64 与 tags；返回 observations、summary、suggestion。图片上限 8MB。')
                .fontSize(12).fontColor('#7A8090').lineHeight(19).width('100%')
              Button('保存云端设置', { type: ButtonType.Capsule })
                .width('100%').height(46).fontColor('#4056D6').backgroundColor('#EEF0FF')
                .onClick(() => this.save())
            }.alignItems(HorizontalAlign.Start).padding(20).borderRadius(20).backgroundColor(Color.White)
          }

          Column({ space: 8 }) {
            Text('数据说明').fontSize(19).fontWeight(FontWeight.Bold).width('100%')
            Text('本地最多保存 50 条报告。云端关闭时图片不离开设备。卸载应用或清除记录后无法恢复。')
              .fontSize(14).fontColor('#73798B').lineHeight(22).width('100%')
          }.alignItems(HorizontalAlign.Start).padding(20).borderRadius(20).backgroundColor(Color.White)

          Button('清除全部本地记录', { type: ButtonType.Capsule })
            .width('100%').height(50).fontColor('#C73D4D').backgroundColor('#FFF0F0')
            .onClick(() => this.confirmClear())

          Text('本工具不进行人脸身份识别，不判断谎言、犯罪倾向、性格、疾病或真实心理状态。')
            .fontSize(12).fontColor('#8A8F9E').lineHeight(19)
            .textAlign(TextAlign.Center).width('100%').padding({ top: 10, bottom: 24 })
        }.padding({ left: 20, right: 20 })
      }.scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#F6F7FB')
  }
}
