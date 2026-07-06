import { ConsoleLogEntry, WebConsoleStore } from '../model/WebConsoleStore';

@ComponentV2
export struct ConsolePanel {
  @Param store: WebConsoleStore = new WebConsoleStore();
  @Local expandedId: number = -1;

  build() {
    Column() {
      Column({ space: 6 }) {
        Row() {
          Text('Console')
            .fontSize($r('app.float.title_font_size'))
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Bold)
          Blank()
          Text(`${this.store.logs.length}`)
            .fontSize($r('app.float.caption_font_size'))
            .fontColor($r('app.color.text_secondary'))
          Button('Clear')
            .fontSize($r('app.float.caption_font_size'))
            .height($r('app.float.clear_button_height'))
            .margin({ left: 6 })
            .backgroundColor($r('app.color.surface'))
            .onClick(() => this.store.clear())
        }
        .width('100%')

        if (this.store.logs.length === 0) {
          Text('Tap "Log" in the widget to capture console output.')
            .fontSize($r('app.float.caption_font_size'))
            .fontColor($r('app.color.text_secondary'))
            .textAlign(TextAlign.Center)
            .margin({ top: 12 })
        } else {
          List({ space: 4 }) {
            ForEach(this.store.logs, (entry: ConsoleLogEntry) => {
              ListItem() {
                this.LogRow(entry)
              }
            }, (entry: ConsoleLogEntry) => `${entry}`)
          }
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Auto)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .constraintSize({ maxWidth: $r('app.float.content_max_width') })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({
      left: $r('app.float.safe_pad_h'),
      right: $r('app.float.safe_pad_h'),
      top: $r('app.float.safe_pad_v'),
      bottom: $r('app.float.safe_pad_v')
    })
  }

  @Builder
  LogRow(entry: ConsoleLogEntry) {
    Column({ space: 2 }) {
      Row({ space: 6 }) {
        Text(entry.levelLabel)
          .fontSize($r('app.float.badge_font_size'))
          .fontColor(Color.White)
          .backgroundColor(WebConsoleStore.levelToColor(entry.level))
          .borderRadius($r('app.float.badge_radius'))
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
        Text(`${entry.sourceId.length > 0 ? entry.sourceId : 'inline'}:${entry.line}`)
          .fontSize($r('app.float.badge_font_size'))
          .fontColor($r('app.color.text_secondary'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')

      Text(entry.message)
        .fontSize($r('app.float.body_font_size'))
        .fontColor($r('app.color.text_primary'))
        .maxLines(this.expandedId === entry.id ? 8 : 2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding($r('app.float.row_padding'))
    .borderRadius($r('app.float.row_radius'))
    .backgroundColor($r('app.color.panel_background'))
    .onClick(() => {
      this.expandedId = this.expandedId === entry.id ? -1 : entry.id;
    })
  }
}
