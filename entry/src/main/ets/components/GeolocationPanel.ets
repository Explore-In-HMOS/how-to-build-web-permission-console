import { WebHostState } from '../model/WebHostState';

@ComponentV2
export struct GeolocationPanel {
  @Param state: WebHostState = new WebHostState();

  build() {
    Scroll() {
      Column({ space: 8 }) {
        Text('Geolocation')
          .fontSize($r('app.float.title_font_size'))
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')

        if (this.state.pendingGeo) {
          Text('Pending request')
            .fontSize($r('app.float.body_font_size'))
            .fontColor($r('app.color.accent'))
            .fontWeight(FontWeight.Medium)
            .width('100%')
          this.Field('From', this.state.pendingGeo!.origin)
          Row({ space: 6 }) {
            this.SmallButton('Allow', $r('app.color.decision_grant'), () => this.state.resolveGeolocation(true, false))
            this.SmallButton('Allow+keep', $r('app.color.decision_grant_retain'), () => this.state.resolveGeolocation(true, true))
            this.SmallButton('Deny', $r('app.color.decision_deny'), () => this.state.resolveGeolocation(false, false))
          }
          .width('100%')
          Divider().color($r('app.color.surface'))
        }

        this.Field('Origin', this.state.currentOrigin.length > 0 ? this.state.currentOrigin : '—')
        this.Field('Last decision', this.state.lastGeoDecision)
        if (this.state.accessResult.length > 0) {
          this.Field('Access check', this.state.accessResult)
        }

        Text(`Stored origins (${this.state.storedOrigins.length})`)
          .fontSize($r('app.float.caption_font_size'))
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
        if (this.state.storedOrigins.length === 0) {
          Text('none')
            .fontSize($r('app.float.body_font_size'))
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
        } else {
          ForEach(this.state.storedOrigins, (origin: string) => {
            Text(origin)
              .fontSize($r('app.float.body_font_size'))
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }, (origin: string) => origin)
        }

        this.ActionButton('Allow & store origin', () => this.state.allowOrigin(this.state.currentOrigin))
        this.ActionButton('Check access', () => this.state.checkAccess(this.state.currentOrigin))
        this.ActionButton('Delete origin', () => this.state.deleteOrigin(this.state.currentOrigin))
        this.ActionButton('Delete all', () => this.state.deleteAll())
        this.ActionButton('Refresh stored', () => this.state.refreshStoredOrigins())
      }
      .width('100%')
      .constraintSize({ maxWidth: $r('app.float.content_max_width') })
      .alignItems(HorizontalAlign.Center)
      .padding({
        left: $r('app.float.safe_pad_h'),
        right: $r('app.float.safe_pad_h'),
        top: $r('app.float.safe_pad_v'),
        bottom: $r('app.float.safe_pad_v')
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Auto)
  }

  @Builder
  Field(label: string, value: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize($r('app.float.caption_font_size'))
        .fontColor($r('app.color.text_secondary'))
      Text(value)
        .fontSize($r('app.float.body_font_size'))
        .fontColor($r('app.color.text_primary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  SmallButton(label: string, color: ResourceColor, action: () => void) {
    Button(label)
      .layoutWeight(1)
      .height($r('app.float.button_height'))
      .fontSize($r('app.float.caption_font_size'))
      .backgroundColor(color)
      .fontColor(Color.White)
      .onClick(action)
  }

  @Builder
  ActionButton(label: string, action: () => void) {
    Button(label)
      .width('100%')
      .height($r('app.float.button_height'))
      .fontSize($r('app.float.body_font_size'))
      .backgroundColor($r('app.color.surface'))
      .fontColor($r('app.color.accent'))
      .onClick(action)
  }
}
