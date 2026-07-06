import { WebNetErrorList } from '@ohos.web.netErrorList';

export type NetErrorCategory =
  | 'ok'
  | 'dns'
  | 'connection'
  | 'timeout'
  | 'tls'
  | 'protocol'
  | 'unknown';

export interface NetErrorInfo {
  code: number;
  name: string;
  category: NetErrorCategory;
  advice: string;
}

interface NetErrorRule {
  code: number;
  name: string;
  category: NetErrorCategory;
  advice: string;
}

export class NetErrorClassifier {
  private static readonly RULES: NetErrorRule[] = [
    {
      code: WebNetErrorList.NET_OK,
      name: 'NET_OK',
      category: 'ok',
      advice: 'Request completed successfully.'
    },
    {
      code: WebNetErrorList.ERR_FAILED,
      name: 'ERR_FAILED',
      category: 'unknown',
      advice: 'A generic failure occurred. Inspect the page and retry.'
    },
    {
      code: WebNetErrorList.ERR_TIMED_OUT,
      name: 'ERR_TIMED_OUT',
      category: 'timeout',
      advice: 'The server took too long. Check the connection and retry.'
    },
    {
      code: WebNetErrorList.ERR_CONNECTION_REFUSED,
      name: 'ERR_CONNECTION_REFUSED',
      category: 'connection',
      advice: 'The host refused the connection. The service may be down.'
    },
    {
      code: WebNetErrorList.ERR_CONNECTION_RESET,
      name: 'ERR_CONNECTION_RESET',
      category: 'connection',
      advice: 'The connection was reset mid-flight. Retry the request.'
    },
    {
      code: WebNetErrorList.ERR_CONNECTION_CLOSED,
      name: 'ERR_CONNECTION_CLOSED',
      category: 'connection',
      advice: 'The connection closed unexpectedly. Retry the request.'
    },
    {
      code: WebNetErrorList.ERR_NAME_NOT_RESOLVED,
      name: 'ERR_NAME_NOT_RESOLVED',
      category: 'dns',
      advice: 'The host name could not be resolved. Check the URL / DNS.'
    },
    {
      code: WebNetErrorList.ERR_INTERNET_DISCONNECTED,
      name: 'ERR_INTERNET_DISCONNECTED',
      category: 'connection',
      advice: 'The device is offline. Restore network connectivity.'
    },
    {
      code: WebNetErrorList.ERR_SSL_PROTOCOL_ERROR,
      name: 'ERR_SSL_PROTOCOL_ERROR',
      category: 'tls',
      advice: 'TLS handshake failed. The certificate or protocol is invalid.'
    },
    {
      code: WebNetErrorList.ERR_CERT_AUTHORITY_INVALID,
      name: 'ERR_CERT_AUTHORITY_INVALID',
      category: 'tls',
      advice: 'The certificate authority is not trusted.'
    },
    {
      code: WebNetErrorList.ERR_UNKNOWN_URL_SCHEME,
      name: 'ERR_UNKNOWN_URL_SCHEME',
      category: 'protocol',
      advice: 'The URL scheme is not supported by the web engine.'
    }
  ];

 static classify(code: number): NetErrorInfo {
    for (const rule of NetErrorClassifier.RULES) {
      if (rule.code === code) {
        return { code, name: rule.name, category: rule.category, advice: rule.advice };
      }
    }
    return {
      code,
      name: `ERR_UNKNOWN(${code})`,
      category: 'unknown',
      advice: 'Unrecognised network error code. See the ArkWeb netErrorList docs.'
    };
  }

  static categoryColor(category: NetErrorCategory): Resource {
    switch (category) {
      case 'ok':
        return $r('app.color.net_cat_ok');
      case 'dns':
        return $r('app.color.net_cat_dns');
      case 'timeout':
        return $r('app.color.net_cat_timeout');
      case 'connection':
        return $r('app.color.net_cat_connection');
      case 'tls':
        return $r('app.color.net_cat_tls');
      case 'protocol':
        return $r('app.color.net_cat_protocol');
      default:
        return $r('app.color.net_cat_unknown');
    }
  }
}
