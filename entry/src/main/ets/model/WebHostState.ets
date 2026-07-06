import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { NetErrorClassifier, NetErrorInfo } from './NetErrorClassifier';

const DOMAIN = 0x1500;
const TAG = 'WebHostState';

export type DialogKind = 'alert' | 'confirm' | 'prompt';

export interface PendingDialog {
  kind: DialogKind;
  message: string;
  defaultValue: string;
  result: JsResult;
}

export interface PendingPermission {
  origin: string;
  resources: string[];
  request: PermissionRequest;
}

export interface PendingGeolocation {
  origin: string;
  geolocation: JsGeolocation;
}

@ObservedV2
export class WebHostState {
  @Trace currentOrigin: string = '';
  @Trace lastGeoDecision: string = 'No request yet';
  @Trace storedOrigins: string[] = [];
  @Trace accessResult: string = '';
  @Trace pendingGeo: PendingGeolocation | null = null;

  @Trace pendingPermission: PendingPermission | null = null;
  @Trace lastPermissionDecision: string = '';

  @Trace pendingDialog: PendingDialog | null = null;
  @Trace lastDialogDecision: string = '';

  @Trace lastNetError: NetErrorInfo | null = null;

  noteGeolocationRequest(origin: string, geolocation: JsGeolocation): void {
    this.currentOrigin = origin;
    this.lastGeoDecision = `Requested by ${origin}`;
    this.pendingGeo = { origin: origin, geolocation: geolocation };
  }

  resolveGeolocation(allow: boolean, retain: boolean): void {
    const pending = this.pendingGeo;
    if (!pending) {
      return;
    }
    if (allow) {
      pending.geolocation.invoke(pending.origin, true, retain);
      this.lastGeoDecision = `Allowed${retain ? ' (retained)' : ''} for ${pending.origin}`;
    } else {
      pending.geolocation.invoke(pending.origin, false, false);
      this.lastGeoDecision = `Denied for ${pending.origin}`;
    }
    this.pendingGeo = null;
    if (retain) {
      this.refreshStoredOrigins();
    }
  }

  allowOrigin(origin: string): void {
    if (!origin) {
      return;
    }
    try {
      webview.GeolocationPermissions.allowGeolocation(origin);
      this.lastGeoDecision = `Stored allow for ${origin}`;
      this.refreshStoredOrigins();
    } catch (e) {
      this.logError('allowGeolocation', e);
    }
  }

  deleteOrigin(origin: string): void {
    if (!origin) {
      return;
    }
    try {
      webview.GeolocationPermissions.deleteGeolocation(origin);
      this.lastGeoDecision = `Deleted permission for ${origin}`;
      this.refreshStoredOrigins();
    } catch (e) {
      this.logError('deleteGeolocation', e);
    }
  }

  deleteAll(): void {
    try {
      webview.GeolocationPermissions.deleteAllGeolocation();
      this.lastGeoDecision = 'Deleted all stored permissions';
      this.refreshStoredOrigins();
    } catch (e) {
      this.logError('deleteAllGeolocation', e);
    }
  }

  checkAccess(origin: string): void {
    if (!origin) {
      this.accessResult = 'No origin captured yet';
      return;
    }
    webview.GeolocationPermissions.getAccessibleGeolocation(origin)
      .then((allowed: boolean) => {
        this.accessResult = `${origin} → ${allowed ? 'accessible' : 'not accessible'}`;
      })
      .catch((e: BusinessError) => {
        this.accessResult = `lookup failed (${e.code})`;
        this.logError('getAccessibleGeolocation', e);
      });
  }

  refreshStoredOrigins(): void {
    webview.GeolocationPermissions.getStoredGeolocation()
      .then((origins: string[]) => {
        this.storedOrigins = origins;
      })
      .catch((e: BusinessError) => {
        this.logError('getStoredGeolocation', e);
      });
  }

  private logError(api: string, e: Object): void {
    const err = e as BusinessError;
    hilog.error(DOMAIN, TAG, '%{public}s failed: %{public}s', api, JSON.stringify(err));
  }

  resolvePermission(grant: boolean): void {
    const pending = this.pendingPermission;
    if (!pending) {
      return;
    }
    if (grant) {
      pending.request.grant(pending.resources);
      this.lastPermissionDecision = `Granted ${pending.resources.join(', ')} to ${pending.origin}`;
    } else {
      pending.request.deny();
      this.lastPermissionDecision = `Denied request from ${pending.origin}`;
    }
    this.pendingPermission = null;
  }

  resolveDialog(confirm: boolean, promptValue: string): void {
    const pending = this.pendingDialog;
    if (!pending) {
      return;
    }
    if (pending.kind === 'prompt') {
      if (confirm) {
        pending.result.handlePromptConfirm(promptValue);
        this.lastDialogDecision = `Prompt replied "${promptValue}"`;
      } else {
        pending.result.handleCancel();
        this.lastDialogDecision = 'Prompt cancelled';
      }
    } else if (pending.kind === 'confirm') {
      if (confirm) {
        pending.result.handleConfirm();
        this.lastDialogDecision = 'Confirm accepted';
      } else {
        pending.result.handleCancel();
        this.lastDialogDecision = 'Confirm rejected';
      }
    } else {
      pending.result.handleConfirm();
      this.lastDialogDecision = 'Alert dismissed';
    }
    this.pendingDialog = null;
  }

  noteNetError(code: number): void {
    this.lastNetError = NetErrorClassifier.classify(code);
  }
}
