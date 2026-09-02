import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { RecordStore } from '../model/RecordStore';
import { ObservationRecord } from '../model/Types';

@Entry
@Component
struct History {
  @State private items: ObservationRecord[] = [];

  aboutToAppear(): void {
    this.load();
  }

  private async load(): Promise<void> {
    this.items = await RecordStore.list(getContext(this) as common.UIAbilityContext);
  }

  build() {
    Column() {
      Row() {
        Text('‹').fontSize(34).onClick(() => router.back())
        Text('观察记录').fontSize(24).fontWeight(FontWeight.Bold).margin({ left: 14 })
      }.width('100%').padding({ top: 20, left: 20, right: 20, bottom: 16 })

      if (this.items.length === 0) {
        Column({ space: 12 }) {
          Text('◎').fontSize(54).fontColor('#4056D6')
          Text('还没有记录').fontSize(20).fontWeight(FontWeight.Bold)
          Text('完成一次观察后，报告会保存在这台设备上。')
            .fontSize(14).fontColor('#73798B').textAlign(TextAlign.Center)
        }
        .padding(36).margin(20).borderRadius(20).backgroundColor(Color.White)
      } else {
        List({ space: 12 }) {
          ForEach(this.items, (item: ObservationRecord) => {
            ListItem() {
              Row({ space: 14 }) {
                Image(item.imageUri).width(76).height(76).objectFit(ImageFit.Cover)
                  .borderRadius(12).backgroundColor('#E9EBF2')
                Column({ space: 6 }) {
                  Text(item.summary).fontSize(16).fontWeight(FontWeight.Bold)
                    .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
                  Text(new Date(item.createdAt).toLocaleString() + ' · ' + item.mode)
                    .fontSize(12).fontColor('#7A8090').maxLines(1)
                  if (item.feedback) {
                    Text('已反馈').fontSize(11).fontColor('#4056D6')
                  }
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Text('›').fontSize(30).fontColor('#A0A5B1')
              }
              .padding(14).borderRadius(18).backgroundColor(Color.White)
              .onClick(() => router.pushUrl({ url: 'pages/Result', params: { id: item.id } }))
            }
          }, (item: ObservationRecord) => item.id)
        }
        .width('100%').layoutWeight(1).padding({ left: 20, right: 20, bottom: 20 })
        .scrollBar(BarState.Off)
      }
    }.width('100%').height('100%').backgroundColor('#F6F7FB')
  }
}

