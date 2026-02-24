import 'package:arch_sherpa/config/config_model.dart';
import 'package:arch_sherpa/config/config_validator.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigValidator', () {
    final validator = ConfigValidator();

    test('accepts defaults', () {
      expect(() => validator.validate(ArchSherpaConfig.defaults()),
          returnsNormally);
    });

    test('rejects invalid state management', () {
      final invalid = ArchSherpaConfig.defaults().copyWith(
        stateManagement: StateManagementConfig(type: 'mobx'),
      );

      expect(
        () => validator.validate(invalid),
        throwsA(isA<ConfigValidationException>()),
      );
    });

    test('rejects path traversal in base path', () {
      final invalid = ArchSherpaConfig.defaults().copyWith(
        features: FeaturesConfig(
          basePath: 'lib/../evil',
          structure: ArchSherpaConfig.defaults().features.structure,
        ),
      );

      expect(
        () => validator.validate(invalid),
        throwsA(isA<ConfigValidationException>()),
      );
    });

    test('rejects invalid feature name', () {
      expect(
        () => validator.validateFeatureName('../oops'),
        throwsA(isA<ConfigValidationException>()),
      );
    });

    test('rejects invalid deprecations policy', () {
      final invalid = ArchSherpaConfig.defaults().copyWith(
        deprecations: DeprecationsConfig(policy: 'strict'),
      );
      expect(
        () => validator.validate(invalid),
        throwsA(isA<ConfigValidationException>()),
      );
    });
  });
}
