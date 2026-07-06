import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x1500;
const TAG = 'PermissionsHelper';

export const RUNTIME_PERMISSIONS: Permissions[] = [
  'ohos.permission.APPROXIMATELY_LOCATION',
  'ohos.permission.LOCATION',
  'ohos.permission.MICROPHONE'
];

export async function requestRuntimePermissions(
  context: common.UIAbilityContext
): Promise<Map<string, boolean>> {
  const result = new Map<string, boolean>();
  const atManager = abilityAccessCtrl.createAtManager();
  try {
    const data = await atManager.requestPermissionsFromUser(context, RUNTIME_PERMISSIONS);
    const perms = data.permissions;
    const authResults = data.authResults;
    for (let i = 0; i < perms.length; i++) {
      result.set(perms[i], authResults[i] === 0);
    }
  } catch (e) {
    const err = e as BusinessError;
    hilog.error(DOMAIN, TAG, 'requestPermissionsFromUser failed: %{public}s', JSON.stringify(err));
  }
  return result;
}
