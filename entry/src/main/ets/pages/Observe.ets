import { common } from '@kit.AbilityKit';
import { promptAction, router } from '@kit.ArkUI';
import { analyze, OBSERVABLE_TAGS } from '../model/Analyzer';
import { RecordStore } from '../model/RecordStore';
import { CloudConfig, ObservableTag, ObservationRecord } from '../model/Types';

interface ObserveParams {
  imageUri: string;
}

@Entry
@Component
struct Observe {
  @State private imageUri: string = '';
  @State private tags: ObservableTag[] = [];
  @State private loading: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as ObserveParams;
    this.imageUri = params.imageUri || '';
    this.tags = OBSERVABLE_TAGS.map((item: ObservableTag) => ({
      key: item.key,
      label: item.label,
      note: item.note,
      selected: false
    }));
  }

  private toggle(key: string): void {
    this.tags = this.tags.map((item: ObservableTag) => {
      if (item.key === key) {
        item.selected = !item.selected;
      }
      return item;
    });
  }

  private async run(): Promise<void> {
    if (this.loading || !this.imageUri) {
      return;
    }
    this.loading = true;
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const config: CloudConfig = await RecordStore.cloudConfig(context);
      const keys = this.tags.filter((item: ObservableTag) => item.selected)
        .map((item: ObservableTag) => item.key);
      const record: ObservationRecord = await analyze(this.imageUri, keys, config);
      await RecordStore.save(context, record);
      router.replaceUrl({ url: 'pages/Result', params: { id: record.id } });
    } catch (_) {
      promptAction.showToast({ message: '生成失败，请重试' });
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          Row() {
            Text('‹').fontSize(34).onClick(() => router.back())
            Text('记录行为').fontSize(22).fontWeight(FontWeight.Bold).margin({ left: 14 })
          }.width('100%').padding({ top: 20 })

          Image(this.imageUri)
            .width('100%').height(340).objectFit(ImageFit.Cover)
            .borderRadius(22).backgroundColor('#E9EBF2')

          Column({ space: 10 }) {
            Text('你观察到了什么？').fontSize(20).fontWeight(FontWeight.Bold).width('100%')
            Text('选择画面中直接可见的线索，可多选。不要猜测当事人的内心。')
              .fontSize(14).fontColor('#73798B').lineHeight(21).width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tags, (item: ObservableTag) => {
                Text(item.label)
                  .fontSize(15)
                  .fontColor(item.selected ? '#4056D6' : '#4C5261')
                  .backgroundColor(item.selected ? '#EEF0FF' : '#F5F6F9')
                  .border({ width: 1, color: item.selected ? '#4056D6' : '#E1E4EB' })
                  .borderRadius(14).padding({ left: 15, right: 15, top: 11, bottom: 11 })
                  .margin({ right: 10, bottom: 10 })
                  .onClick(() => this.toggle(item.key))
              }, (item: ObservableTag) => item.key)
            }.width('100%').margin({ top: 8 })
          }
          .alignItems(HorizontalAlign.Start)
          .padding(20).borderRadius(20).backgroundColor(Color.White)

          Button(this.loading ? '正在生成…' : '生成观察报告', { type: ButtonType.Capsule })
            .width('100%').height(52).fontSize(17).fontWeight(FontWeight.Bold)
            .backgroundColor('#4056D6').enabled(!this.loading)
            .onClick(() => this.run())
        }.padding({ left: 20, right: 20, bottom: 28 })
      }.scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#F6F7FB')
  }
}
