import { camera, cameraPicker } from '@kit.CameraKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State private privacyAccepted: boolean = false;

  aboutToAppear(): void {
    this.privacyAccepted = AppStorage.get('privacyAccepted') as boolean || false;
  }

  private async ensureConsent(): Promise<boolean> {
    if (this.privacyAccepted) {
      return true;
    }
    const result = await promptAction.showDialog({
      title: '拍摄前请确认',
      message: '请确保已获得画面中人物同意。本应用只记录可观察行为，不用于读心、测谎、身份识别或心理诊断。',
      buttons: [
        { text: '取消', color: '#777777' },
        { text: '我已理解并同意', color: '#4056D6' }
      ]
    });
    if (result.index === 1) {
      this.privacyAccepted = true;
      AppStorage.setOrCreate('privacyAccepted', true);
      return true;
    }
    return false;
  }

  private async takePhoto(): Promise<void> {
    if (!await this.ensureConsent()) {
      return;
    }
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const profile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };
      const result = await cameraPicker.pick(
        context,
        [cameraPicker.PickerMediaType.PHOTO],
        profile
      );
      if (result.resultUri) {
        router.pushUrl({ url: 'pages/Observe', params: { imageUri: result.resultUri } });
      }
    } catch (_) {
      promptAction.showToast({ message: '未拍摄照片' });
    }
  }

  private async choosePhoto(): Promise<void> {
    if (!await this.ensureConsent()) {
      return;
    }
    try {
      const options = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 1;
      const picker = new photoAccessHelper.PhotoViewPicker();
      const result = await picker.select(options);
      if (result.photoUris.length > 0) {
        router.pushUrl({ url: 'pages/Observe', params: { imageUri: result.photoUris[0] } });
      }
    } catch (_) {
      promptAction.showToast({ message: '未选择照片' });
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          Column({ space: 12 }) {
            Text('BEHAVIOR OBSERVER')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4056D6')
              .letterSpacing(2)
              .width('100%')
            Text('看见行为，\n不替别人下结论')
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor('#202433')
              .width('100%')
            Text('拍摄或选择一张图片，记录姿态、视线与动作等可直接观察的线索。默认在设备本地处理。')
              .fontSize(16)
              .fontColor('#73798B')
              .lineHeight(25)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding({ top: 34, bottom: 10 })

          Row({ space: 14 }) {
            Text('✓')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#25845F')
              .backgroundColor('#EAF8F1')
              .borderRadius(12)
              .padding(12)
            Column({ space: 6 }) {
              Text('隐私优先').fontSize(19).fontWeight(FontWeight.Bold)
              Text('使用系统相机界面；云端模式关闭时，照片不会上传。')
                .fontSize(14).fontColor('#73798B').lineHeight(21)
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          }
          .padding(20)
          .borderRadius(20)
          .backgroundColor(Color.White)

          Button('拍摄照片', { type: ButtonType.Capsule })
            .width('100%').height(52).fontSize(17).fontWeight(FontWeight.Bold)
            .backgroundColor('#4056D6')
            .onClick(() => this.takePhoto())
          Button('从图库选择', { type: ButtonType.Capsule })
            .width('100%').height(52).fontSize(17).fontWeight(FontWeight.Bold)
            .fontColor('#4056D6').backgroundColor('#EEF0FF')
            .onClick(() => this.choosePhoto())

          Row({ space: 12 }) {
            this.NavCard('历史记录', '查看设备本地报告', 'pages/History')
            this.NavCard('设置', '云端接口与隐私', 'pages/Settings')
          }.width('100%')

          Text('请勿用于招聘、授信、执法、医疗诊断等高风险决策。')
            .fontSize(12).fontColor('#8A8F9E').textAlign(TextAlign.Center)
            .width('100%').padding({ top: 10, bottom: 24 })
        }
        .padding({ left: 20, right: 20 })
      }.scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#F6F7FB')
  }

  @Builder
  NavCard(title: string, subtitle: string, url: string) {
    Column({ space: 7 }) {
      Text(title).fontSize(17).fontWeight(FontWeight.Bold).width('100%')
      Text(subtitle).fontSize(12).fontColor('#7A8090').width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .padding(18)
    .borderRadius(18)
    .backgroundColor(Color.White)
    .onClick(() => router.pushUrl({ url }))
  }
}

