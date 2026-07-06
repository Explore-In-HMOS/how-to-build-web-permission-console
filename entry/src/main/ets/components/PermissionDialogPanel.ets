import { WebHostState } from '../model/WebHostState';

@ComponentV2
export struct PermissionDialogPanel {
  @Param state: WebHostState = new WebHostState();
  @Local promptValue: string = '';

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Text('Permissions & Dialogs')
          .fontSize($r('app.float.title_font_size'))
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')

        this.SectionTitle('Permission request')
        if (this.state.pendingPermission) {
          this.Field('Origin', this.state.pendingPermission!.origin)
          this.Field('Resources', this.state.pendingPermission!.resources.join(', '))
          Row({ space: 8 }) {
            this.DecisionButton('Grant', $r('app.color.decision_grant'), () => this.state.resolvePermission(true))
            this.DecisionButton('Deny', $r('app.color.decision_deny'), () => this.state.resolvePermission(false))
          }
          .width('100%')
        } else {
          this.Idle(this.state.lastPermissionDecision.length > 0
            ? this.state.lastPermissionDecision
            : 'No pending request. Tap "Microphone" in the widget.')
        }

        Divider().color($r('app.color.surface'))

        this.SectionTitle('JS dialog')
        if (this.state.pendingDialog) {
          this.Field('Type', this.state.pendingDialog!.kind)
          this.Field('Message', this.state.pendingDialog!.message)
          if (this.state.pendingDialog!.kind === 'prompt') {
            TextInput({ text: this.promptValue, placeholder: this.state.pendingDialog!.defaultValue })
              .fontSize($r('app.float.body_font_size'))
              .backgroundColor($r('app.color.surface'))
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .onChange((v: string) => this.promptValue = v)
          }
          Row({ space: 8 }) {
            this.DecisionButton(
              this.state.pendingDialog!.kind === 'alert' ? 'OK' : 'Confirm',
              $r('app.color.decision_grant'),
              () => {
                const v = this.promptValue.length > 0 ? this.promptValue : this.state.pendingDialog!.defaultValue;
                this.state.resolveDialog(true, v);
                this.promptValue = '';
              }
            )
            if (this.state.pendingDialog!.kind !== 'alert') {
              this.DecisionButton('Cancel', $r('app.color.decision_deny'), () => {
                this.state.resolveDialog(false, '');
                this.promptValue = '';
              })
            }
          }
          .width('100%')
        } else {
          this.Idle(this.state.lastDialogDecision.length > 0
            ? this.state.lastDialogDecision
            : 'No pending dialog. Tap Alert/Confirm/Prompt in the widget.')
        }
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
  SectionTitle(label: string) {
    Text(label)
      .fontSize($r('app.float.body_font_size'))
      .fontColor($r('app.color.accent'))
      .fontWeight(FontWeight.Medium)
      .width('100%')
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
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  Idle(text: string) {
    Text(text)
      .fontSize($r('app.float.body_font_size'))
      .fontColor($r('app.color.text_secondary'))
      .width('100%')
  }

  @Builder
  DecisionButton(label: string, color: ResourceColor, action: () => void) {
    Button(label)
      .layoutWeight(1)
      .height($r('app.float.button_height'))
      .fontSize($r('app.float.body_font_size'))
      .backgroundColor(color)
      .fontColor(Color.White)
      .onClick(action)
  }
}
