import 'package:arch_sherpa/config/compatibility_checker.dart';
import 'package:arch_sherpa/config/config_model.dart';
import 'package:test/test.dart';

void main() {
  group('CompatibilityChecker', () {
    final checker = CompatibilityChecker();

    test('riverpod is compatible with controllers', () {
      final result = checker.check(ArchSherpaConfig.defaults());
      expect(result.isCompatible, isTrue);
    });

    test('bloc requires blocs capability', () {
      final config = ArchSherpaConfig.defaults().copyWith(
        stateManagement: StateManagementConfig(type: 'bloc'),
      );
      final result = checker.check(config);
      expect(result.isCompatible, isFalse);
    });

    test('none disallows state management capabilities', () {
      final config = ArchSherpaConfig.defaults().copyWith(
        stateManagement: StateManagementConfig(type: 'none'),
      );
      final result = checker.check(config);
      expect(result.isCompatible, isFalse);
    });
  });
}
