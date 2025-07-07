enum FNOItemType {
  nifty50,
  bankNiftyCall,
  bankNiftyPut,
  niftyCall,
  niftyPut,
}

extension FNOItemTypeExtension on FNOItemType {
  String get displayName {
    switch (this) {
      case FNOItemType.nifty50:
        return 'Nifty 50 Stock';
      case FNOItemType.bankNiftyCall:
        return 'Bank Nifty Call';
      case FNOItemType.bankNiftyPut:
        return 'Bank Nifty Put';
      case FNOItemType.niftyCall:
        return 'Nifty Call';
      case FNOItemType.niftyPut:
        return 'Nifty Put';
    }
  }

  String get shortName {
    switch (this) {
      case FNOItemType.nifty50:
        return 'N50';
      case FNOItemType.bankNiftyCall:
        return 'BN CE';
      case FNOItemType.bankNiftyPut:
        return 'BN PE';
      case FNOItemType.niftyCall:
        return 'N CE';
      case FNOItemType.niftyPut:
        return 'N PE';
    }
  }

  bool get isOption {
    return this != FNOItemType.nifty50;
  }

  bool get isStock {
    return this == FNOItemType.nifty50;
  }

  bool get isCall {
    return this == FNOItemType.bankNiftyCall || this == FNOItemType.niftyCall;
  }

  bool get isPut {
    return this == FNOItemType.bankNiftyPut || this == FNOItemType.niftyPut;
  }

  bool get isBankNifty {
    return this == FNOItemType.bankNiftyCall ||
        this == FNOItemType.bankNiftyPut;
  }

  bool get isNifty {
    return this == FNOItemType.niftyCall || this == FNOItemType.niftyPut;
  }
}
