import 'qr_bar_code_scanner_dialog_platform_interface.dart';

import 'package:flutter/widgets.dart';

class QrBarCodeScannerDialog {
  Future<String?> getPlatformVersion() {
    return QrBarCodeScannerDialogPlatform.instance.getPlatformVersion();
  }

  Future<String?> getOperatingSystemName() {
    return QrBarCodeScannerDialogPlatform.instance.getOperatingSystemName();
  }

  ///- enableFlip : if true, it puts the camera in mirror mode
  void getScannedQrBarCode({
    BuildContext? context,
    required Function(String?) onCode,
    bool? enableFlip,
  }) {
    QrBarCodeScannerDialogPlatform.instance.scanBarOrQrCode(
      context: context,
      onScanSuccess: onCode,
      enableFlip: enableFlip,
    );
  }
}
