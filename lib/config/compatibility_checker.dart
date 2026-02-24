import 'capabilities.dart';
import 'config_model.dart';

class CompatibilityResult {
  CompatibilityResult({
    required this.isCompatible,
    required this.detectedCapabilities,
    required this.requiredCapabilities,
    required this.message,
    required this.suggestion,
  });

  final bool isCompatible;
  final Set<Capability> detectedCapabilities;
  final Set<Capability> requiredCapabilities;
  final String message;
  final String suggestion;
}

class CompatibilityChecker {
  CompatibilityResult check(ArchSherpaConfig config) {
    final detected = _detectCapabilities(config.features.structure);
    final required = _requiredCapabilities(config.stateManagement.type);

    final isCompatible = _isSatisfied(
      stateType: config.stateManagement.type,
      detected: detected,
      required: required,
    );

    if (isCompatible) {
      return CompatibilityResult(
        isCompatible: true,
        detectedCapabilities: detected,
        requiredCapabilities: required,
        message: 'Configuration is compatible.',
        suggestion: '',
      );
    }

    final detectedLabels = _labelsForMessage(detected);
    final requiredLabels = _labelsForMessage(required);

    final suggestion = _suggestion(config.stateManagement.type);
    return CompatibilityResult(
      isCompatible: false,
      detectedCapabilities: detected,
      requiredCapabilities: required,
      message:
          'Incompatible config for state_management.type="${config.stateManagement.type}". '
          'Detected capabilities: $detectedLabels. Required: $requiredLabels.',
      suggestion: suggestion,
    );
  }

  String _labelsForMessage(Set<Capability> capabilities) {
    if (capabilities.isEmpty) {
      return 'none';
    }
    final labels = capabilities.map((c) => c.label).toList()..sort();
    return labels.join(', ');
  }

  Set<Capability> _detectCapabilities(Map<String, List<String>> structure) {
    final capabilities = <Capability>{};

    for (final entry in structure.entries) {
      final key = entry.key.toLowerCase();
      final folders = entry.value.map((folder) => folder.toLowerCase()).toSet();

      if (key == 'presentation' || key.startsWith('presentation/')) {
        if (folders.contains('controllers') || key.contains('controllers')) {
          capabilities.add(Capability.presentationControllers);
        }
        if (folders.contains('providers') || key.contains('providers')) {
          capabilities.add(Capability.presentationProviders);
        }
        if (folders.contains('blocs') ||
            folders.contains('bloc') ||
            key.contains('blocs') ||
            key.contains('bloc')) {
          capabilities.add(Capability.presentationBlocs);
        }
      }
    }

    return capabilities;
  }

  Set<Capability> _requiredCapabilities(String stateType) {
    switch (stateType) {
      case 'riverpod':
        return {
          Capability.presentationControllers,
          Capability.presentationProviders,
        };
      case 'bloc':
      case 'cubit':
        return {Capability.presentationBlocs};
      case 'none':
        return {};
      default:
        return {};
    }
  }

  bool _isSatisfied({
    required String stateType,
    required Set<Capability> detected,
    required Set<Capability> required,
  }) {
    switch (stateType) {
      case 'riverpod':
        return detected.contains(Capability.presentationControllers) ||
            detected.contains(Capability.presentationProviders);
      case 'bloc':
      case 'cubit':
        return detected.contains(Capability.presentationBlocs);
      case 'none':
        return !detected.contains(Capability.presentationControllers) &&
            !detected.contains(Capability.presentationProviders) &&
            !detected.contains(Capability.presentationBlocs);
      default:
        return false;
    }
  }

  String _suggestion(String stateType) {
    switch (stateType) {
      case 'riverpod':
        return 'Add "controllers" or "providers" under a "presentation" section in features.structure, '
            'or change state_management.type to bloc/cubit/none.';
      case 'bloc':
      case 'cubit':
        return 'Add "blocs" under a "presentation" section in features.structure, '
            'or change state_management.type to riverpod/none.';
      case 'none':
        return 'Remove presentation state folders (controllers/providers/blocs) from features.structure, '
            'or change state_management.type.';
      default:
        return 'Review state_management.type and features.structure.';
    }
  }
}
