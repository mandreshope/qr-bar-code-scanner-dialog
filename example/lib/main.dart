import 'package:flutter/material.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? code;
  bool enableFlip = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(builder: (context) {
          return Material(
            child: Center(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Mirror mode"),
                    value: enableFlip,
                    onChanged: (v) {
                      enableFlip = v;
                      setState(() {});
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final qrBarCodeScannerDialogPlugin =
                          QrBarCodeScannerDialog();
                      final device = await qrBarCodeScannerDialogPlugin
                          .getOperatingSystemName();
                      debugPrint(device);
                      // ignore: use_build_context_synchronously
                      qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                        context: context,
                        onCode: (code) {
                          setState(() {
                            this.code = code;
                          });
                        },
                        enableFlip: enableFlip,
                      );
                    },
                    child: Text(code ?? "Click me"),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
