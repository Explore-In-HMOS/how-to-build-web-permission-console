import { webview } from '@kit.ArkWeb';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { WebConsoleStore } from '../model/WebConsoleStore';
import { WebHostState } from '../model/WebHostState';
import { requestRuntimePermissions } from '../model/PermissionsHelper';
import { ConsolePanel } from '../components/ConsolePanel';
import { GeolocationPanel } from '../components/GeolocationPanel';
import { PermissionDialogPanel } from '../components/PermissionDialogPanel';
import { NetErrorBanner } from '../components/NetErrorBanner';

const DOMAIN = 0x1500;
const TAG = 'WebHost';
const HOME_URL = 'demo/index.html';

@Entry
@ComponentV2
struct WebHost {
  private controller: webview.WebviewController = new webview.WebviewController();
  @Local console: WebConsoleStore = new WebConsoleStore();
  @Local state: WebHostState = new WebHostState();
  @Local supported: boolean = false;
  @Local webReady: boolean = false;
  @Local dialogPromptValue: string = '';

  aboutToAppear(): void {
    this.supported = canIUse('SystemCapability.Web.Webview.Core');
    if (!this.supported) {
      hilog.warn(DOMAIN, TAG, 'ArkWeb Web component is not available on this device.');
      return;
    }
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    requestRuntimePermissions(context).then((results: Map<string, boolean>) => {
      results.forEach((granted: boolean, name: string) => {
        hilog.info(DOMAIN, TAG, 'permission %{public}s granted=%{public}s', name, `${granted}`);
      });
    });
  }

  private runJs(fn: string): void {
    if (!this.webReady) {
      return;
    }
    this.controller.runJavaScript(`${fn}()`).catch((e: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'runJavaScript failed: %{public}s', JSON.stringify(e));
    });
  }

  private reload(): void {
    try {
      this.controller.loadUrl($rawfile(HOME_URL));
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'reload failed: %{public}s', JSON.stringify(e as BusinessError));
    }
  }

  build() {
    Column() {
      if (this.supported) {
        Swiper() {
          this.WebPage()
          this.ControlsPage()
          ConsolePanel({ store: this.console })
          GeolocationPanel({ state: this.state })
          PermissionDialogPanel({ state: this.state })
          NetErrorBanner({ state: this.state })
        }
        .loop(false)
        .indicator(
          new DotIndicator()
            .bottom($r('app.float.indicator_bottom'))
        )
        .width('100%')
        .height('100%')
      } else {
        this.Fallback()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  WebPage() {
    Stack() {
      Web({ src: $rawfile(HOME_URL), controller: this.controller })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .geolocationAccess(true)
        .width('100%')
        .height('100%')
        .onPageEnd(() => {
          this.webReady = true;
        })
        .onConsole((event: OnConsoleEvent) => {
          this.console.addFromConsoleMessage(event.message);
          return false;
        })
        .onGeolocationShow((event: OnGeolocationShowEvent) => {
          this.state.noteGeolocationRequest(event.origin, event.geolocation);
        })
        .onPermissionRequest((event: OnPermissionRequestEvent) => {
          this.state.pendingPermission = {
            origin: event.request.getOrigin(),
            resources: event.request.getAccessibleResource(),
            request: event.request
          };
        })
        .onAlert((event: OnAlertEvent) => {
          this.state.pendingDialog = {
            kind: 'alert',
            message: event.message,
            defaultValue: '',
            result: event.result
          };
          return true;
        })
        .onConfirm((event: OnConfirmEvent) => {
          this.state.pendingDialog = {
            kind: 'confirm',
            message: event.message,
            defaultValue: '',
            result: event.result
          };
          return true;
        })
        .onPrompt((event: OnPromptEvent) => {
          this.state.pendingDialog = {
            kind: 'prompt',
            message: event.message,
            defaultValue: event.value,
            result: event.result
          };
          return true;
        })
        .onErrorReceive((event: OnErrorReceiveEvent) => {
          if (event.request.isMainFrame()) {
            this.state.noteNetError(event.error.getErrorCode());
          }
        })

      if (this.state.pendingDialog) {
        this.DialogOverlay()
      } else if (this.state.pendingPermission) {
        this.PermissionOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DialogOverlay() {
    Column() {
      Column({ space: 10 }) {
        Text(this.state.pendingDialog!.kind.toUpperCase())
          .fontSize($r('app.float.title_font_size'))
          .fontColor($r('app.color.accent'))
          .fontWeight(FontWeight.Bold)
        Text(this.state.pendingDialog!.message)
          .fontSize($r('app.float.body_font_size'))
          .fontColor($r('app.color.text_primary'))
          .textAlign(TextAlign.Center)
        if (this.state.pendingDialog!.kind === 'prompt') {
          TextInput({ text: this.dialogPromptValue, placeholder: this.state.pendingDialog!.defaultValue })
            .fontSize($r('app.float.body_font_size'))
            .backgroundColor($r('app.color.surface'))
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .onChange((v: string) => this.dialogPromptValue = v)
        }
        Row({ space: 8 }) {
          Button(this.state.pendingDialog!.kind === 'alert' ? 'OK' : 'Confirm')
            .layoutWeight(1)
            .height($r('app.float.button_height'))
            .fontSize($r('app.float.body_font_size'))
            .backgroundColor($r('app.color.decision_grant'))
            .fontColor(Color.White)
            .onClick(() => {
              const v = this.dialogPromptValue.length > 0
                ? this.dialogPromptValue
                : this.state.pendingDialog!.defaultValue;
              this.state.resolveDialog(true, v);
              this.dialogPromptValue = '';
            })
          if (this.state.pendingDialog!.kind !== 'alert') {
            Button('Cancel')
              .layoutWeight(1)
              .height($r('app.float.button_height'))
              .fontSize($r('app.float.body_font_size'))
              .backgroundColor($r('app.color.decision_deny'))
              .fontColor(Color.White)
              .onClick(() => {
                this.state.resolveDialog(false, '');
                this.dialogPromptValue = '';
              })
          }
        }
        .width('100%')
      }
      .width('80%')
      .padding($r('app.float.screen_padding'))
      .backgroundColor($r('app.color.panel_background'))
      .borderRadius($r('app.float.panel_radius'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.scrim'))
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  PermissionOverlay() {
    Column() {
      Column({ space: 10 }) {
        Text('Permission request')
          .fontSize($r('app.float.title_font_size'))
          .fontColor($r('app.color.accent'))
          .fontWeight(FontWeight.Bold)
        Text(this.state.pendingPermission!.resources.join(', '))
          .fontSize($r('app.float.body_font_size'))
          .fontColor($r('app.color.text_primary'))
          .textAlign(TextAlign.Center)
        Row({ space: 8 }) {
          Button('Grant')
            .layoutWeight(1)
            .height($r('app.float.button_height'))
            .fontSize($r('app.float.body_font_size'))
            .backgroundColor($r('app.color.decision_grant'))
            .fontColor(Color.White)
            .onClick(() => this.state.resolvePermission(true))
          Button('Deny')
            .layoutWeight(1)
            .height($r('app.float.button_height'))
            .fontSize($r('app.float.body_font_size'))
            .backgroundColor($r('app.color.decision_deny'))
            .fontColor(Color.White)
            .onClick(() => this.state.resolvePermission(false))
        }
        .width('100%')
      }
      .width('80%')
      .padding($r('app.float.screen_padding'))
      .backgroundColor($r('app.color.panel_background'))
      .borderRadius($r('app.float.panel_radius'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.scrim'))
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ControlsPage() {
    Scroll() {
        Column({ space: 6 }) {
          Text('Controls')
            .fontSize($r('app.float.title_font_size'))
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width('100%')
          Text('Drives the widget via runJavaScript')
            .fontSize($r('app.float.caption_font_size'))
            .fontColor($r('app.color.text_secondary'))
            .textAlign(TextAlign.Center)
            .width('100%')

          this.CtrlButton('Locate (geolocation)', () => this.runJs('triggerGeolocation'))
          this.CtrlButton('Log all levels', () => this.runJs('triggerConsole'))
          this.CtrlButton('Alert', () => this.runJs('triggerAlert'))
          this.CtrlButton('Confirm', () => this.runJs('triggerConfirm'))
          this.CtrlButton('Prompt', () => this.runJs('triggerPrompt'))
          this.CtrlButton('Microphone (permission)', () => this.runJs('triggerMicrophone'))
          this.CtrlButton('Trigger net error', () => this.runJs('triggerNetError'))
          this.CtrlButton('Reload widget', () => this.reload())
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
  CtrlButton(label: string, action: () => void) {
    Button(label)
      .width('100%')
      .height($r('app.float.button_height'))
      .fontSize($r('app.float.body_font_size'))
      .backgroundColor($r('app.color.surface'))
      .fontColor($r('app.color.accent'))
      .enabled(this.webReady)
      .onClick(action)
  }

  @Builder
  Fallback() {
    Column({ space: 8 }) {
      Text('Web engine unavailable')
        .fontSize($r('app.float.title_font_size'))
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
      Text('The ArkWeb Web component is not supported on this device type, so the live demo cannot run here. Run the sample on a phone/tablet target to exercise the geolocation, permission, console, dialog and network-error callbacks.')
        .fontSize($r('app.float.body_font_size'))
        .fontColor($r('app.color.text_secondary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .constraintSize({ maxWidth: $r('app.float.content_max_width') })
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
