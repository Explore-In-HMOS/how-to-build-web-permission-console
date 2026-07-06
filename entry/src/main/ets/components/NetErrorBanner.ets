import { NetErrorClassifier } from '../model/NetErrorClassifier';
import { WebHostState } from '../model/WebHostState';

@ComponentV2
export struct NetErrorBanner {
  @Param state: WebHostState = new WebHostState();

  build() {
    Column() {
      Column({ space: 6 }) {
      Text('Network error')
        .fontSize($r('app.float.title_font_size'))
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .width('100%')

      if (this.state.lastNetError) {
        Row({ space: 6 }) {
          Text(this.state.lastNetError!.category.toUpperCase())
            .fontSize($r('app.float.badge_font_size'))
            .fontColor(Color.White)
            .backgroundColor(NetErrorClassifier.categoryColor(this.state.lastNetError!.category))
            .borderRadius($r('app.float.badge_radius'))
            .padding({ left: 5, right: 5, top: 1, bottom: 1 })
          Text(`code ${this.state.lastNetError!.code}`)
            .fontSize($r('app.float.caption_font_size'))
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')

        Text(this.state.lastNetError!.name)
          .fontSize($r('app.float.body_font_size'))
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Text(this.state.lastNetError!.advice)
          .fontSize($r('app.float.body_font_size'))
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
      } else {
        Text('No errors captured. Tap "Net error" in the widget to load an unreachable host.')
          .fontSize($r('app.float.body_font_size'))
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
      }
      }
      .width('100%')
      .constraintSize({ maxWidth: $r('app.float.content_max_width') })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({
      left: $r('app.float.safe_pad_h'),
      right: $r('app.float.safe_pad_h'),
      top: $r('app.float.safe_pad_v'),
      bottom: $r('app.float.safe_pad_v')
    })
  }
}
