import { common } from '@kit.AbilityKit';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction, router } from '@kit.ArkUI';
import { RecordStore } from '../model/RecordStore';
import { Observation, ObservationRecord } from '../model/Types';

interface ResultParams {
  id: string;
}

@Entry
@Component
struct Result {
  @State private record?: ObservationRecord;
  @State private date: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as ResultParams;
    this.load(params.id);
  }

  private async load(id: string): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    this.record = await RecordStore.get(context, id);
    if (this.record) {
      this.date = new Date(this.record.createdAt).toLocaleString();
    }
  }

  private async setFeedback(value: string): Promise<void> {
    if (!this.record) {
      return;
    }
    const context = getContext(this) as common.UIAbilityContext;
    await RecordStore.feedback(context, this.record.id, value);
    this.record.feedback = value;
    this.record = { ...this.record };
    promptAction.showToast({ message: '已记录反馈' });
  }

  private async exportText(): Promise<void> {
    if (!this.record) {
      return;
    }
    let body = `观行镜 · 观察报告\n${this.date} · ${this.record.mode}\n\n可观察线索：\n`;
    this.record.observations.forEach((item: Observation) => {
      body += `• ${item.label}：${item.note}\n`;
    });
    body += `\n理解建议：${this.record.suggestion}\n\n本报告仅记录可观察行为，不代表性格、意图或心理诊断。`;
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, body);
    await pasteboard.getSystemPasteboard().setData(data);
    promptAction.showToast({ message: '报告已复制，可粘贴到备忘录或文档' });
  }

  build() {
    Column() {
      if (this.record) {
        Scroll() {
          Column({ space: 18 }) {
            Row() {
              Text('‹').fontSize(34).onClick(() => router.back())
              Column({ space: 3 }) {
                Text('观察报告').fontSize(24).fontWeight(FontWeight.Bold)
                Text(this.date + ' · ' + this.record!.mode).fontSize(12).fontColor('#73798B')
              }.alignItems(HorizontalAlign.Start).margin({ left: 14 }).layoutWeight(1)
              Text('非诊断').fontSize(12).fontColor('#9A641B')
                .backgroundColor('#FFF1DC').borderRadius(12).padding({ left: 10, right: 10, top: 6, bottom: 6 })
            }.width('100%').padding({ top: 20 })

            Image(this.record!.imageUri)
              .width('100%').height(220).objectFit(ImageFit.Cover)
              .borderRadius(22).backgroundColor('#E9EBF2')

            Column({ space: 16 }) {
              Text('可观察线索').fontSize(20).fontWeight(FontWeight.Bold).width('100%')
              ForEach(this.record!.observations, (item: Observation) => {
                Row({ space: 12 }) {
                  Text('•').fontSize(24).fontColor('#4056D6')
                  Column({ space: 5 }) {
                    Text(item.label).fontSize(16).fontWeight(FontWeight.Bold).width('100%')
                    Text(item.note).fontSize(14).fontColor('#73798B').lineHeight(21).width('100%')
                  }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                }.alignItems(VerticalAlign.Top)
              }, (item: Observation) => item.label)
            }
            .alignItems(HorizontalAlign.Start)
            .padding(20).borderRadius(20).backgroundColor(Color.White)

            Column({ space: 8 }) {
              Text('如何理解').fontSize(19).fontWeight(FontWeight.Bold).width('100%')
              Text(this.record!.suggestion).fontSize(14).fontColor('#73798B').lineHeight(22).width('100%')
            }
            .alignItems(HorizontalAlign.Start).padding(20).borderRadius(20)
            .backgroundColor('#FFFBF2').border({ width: { left: 4 }, color: '#EFB455' })

            Column({ space: 14 }) {
              Text('这份描述准确吗？').fontSize(18).fontWeight(FontWeight.Bold).width('100%')
              Row({ space: 8 }) {
                this.FeedbackButton('基本准确', 'useful')
                this.FeedbackButton('部分准确', 'partial')
                this.FeedbackButton('不准确', 'wrong')
              }.width('100%')
            }.padding(20).borderRadius(20).backgroundColor(Color.White)

            Button('导出文字报告', { type: ButtonType.Capsule })
              .width('100%').height(52).fontSize(17).fontWeight(FontWeight.Bold)
              .backgroundColor('#4056D6').onClick(() => this.exportText())
            Text('导出后可直接粘贴到备忘录、邮件或文档。')
              .fontSize(12).fontColor('#8A8F9E').width('100%').textAlign(TextAlign.Center)
          }.padding({ left: 20, right: 20, bottom: 30 })
        }.scrollBar(BarState.Off)
      } else {
        Column({ space: 16 }) {
          Text('未找到报告').fontSize(22).fontWeight(FontWeight.Bold)
          Button('返回首页').onClick(() => router.clear())
        }.justifyContent(FlexAlign.Center).width('100%').height('100%')
      }
    }.width('100%').height('100%').backgroundColor('#F6F7FB')
  }

  @Builder
  FeedbackButton(label: string, value: string) {
    Button(label)
      .layoutWeight(1).height(38).fontSize(13)
      .fontColor(this.record?.feedback === value ? '#4056D6' : '#606779')
      .backgroundColor(this.record?.feedback === value ? '#EEF0FF' : '#F5F6F9')
      .border({ width: 1, color: this.record?.feedback === value ? '#4056D6' : '#E1E4ED' })
      .onClick(() => this.setFeedback(value))
  }
}

