enum Capability {
  presentationControllers,
  presentationProviders,
  presentationBlocs,
}

extension CapabilityLabel on Capability {
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
