import localUnitTest from './LocalUnit.test';
import netErrorClassifierTest from './NetErrorClassifier.test';

export default function testsuite() {
  localUnitTest();
  netErrorClassifierTest();
}