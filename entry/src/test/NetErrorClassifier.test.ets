import { describe, it, expect } from '@ohos/hypium';
import { WebNetErrorList } from '@ohos.web.netErrorList';
import { NetErrorClassifier } from '../main/ets/model/NetErrorClassifier';

export default function netErrorClassifierTest() {
  describe('NetErrorClassifierTest', () => {
    it('classifies DNS failures', 0, () => {
      const info = NetErrorClassifier.classify(WebNetErrorList.ERR_NAME_NOT_RESOLVED);
      expect(info.name).assertEqual('ERR_NAME_NOT_RESOLVED');
      expect(info.category).assertEqual('dns');
      expect(info.code).assertEqual(-105);
    });

    it('classifies offline as connection', 0, () => {
      const info = NetErrorClassifier.classify(WebNetErrorList.ERR_INTERNET_DISCONNECTED);
      expect(info.category).assertEqual('connection');
    });

    it('classifies timeout', 0, () => {
      const info = NetErrorClassifier.classify(WebNetErrorList.ERR_TIMED_OUT);
      expect(info.category).assertEqual('timeout');
    });

    it('classifies TLS errors', 0, () => {
      const info = NetErrorClassifier.classify(WebNetErrorList.ERR_SSL_PROTOCOL_ERROR);
      expect(info.category).assertEqual('tls');
    });

    it('maps NET_OK to ok', 0, () => {
      const info = NetErrorClassifier.classify(WebNetErrorList.NET_OK);
      expect(info.category).assertEqual('ok');
    });

    it('falls back to unknown for unmapped codes', 0, () => {
      const info = NetErrorClassifier.classify(-99999);
      expect(info.category).assertEqual('unknown');
      expect(info.code).assertEqual(-99999);
    });

    it('provides a color resource per category', 0, () => {
      expect(NetErrorClassifier.categoryColor('dns')).not().assertUndefined();
      expect(NetErrorClassifier.categoryColor('unknown')).not().assertUndefined();
    });
  });
}
