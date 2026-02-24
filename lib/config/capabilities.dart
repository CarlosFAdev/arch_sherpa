/// Capability markers inferred from presentation-layer folder structure.
enum Capability {
  /// Presence of controller-style presentation state.
  presentationControllers,

  /// Presence of provider-style presentation state.
  presentationProviders,

  /// Presence of bloc/cubit presentation state.
  presentationBlocs,
}

/// Human-readable labels for capability diagnostics.
extension CapabilityLabel on Capability {
  /// Canonical serialized label used in compatibility messages.
  String get label {
    switch (this) {
      case Capability.presentationControllers:
        return 'presentationControllers';
      case Capability.presentationProviders:
        return 'presentationProviders';
      case Capability.presentationBlocs:
        return 'presentationBlocs';
    }
  }
}
