// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html
    show window, Element, ScriptElement, StyleElement, querySelector, Text;

import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'qr_bar_code_scanner_dialog_platform_interface.dart';
import 'dart:js' as js;

/// A web implementation of the QrBarCodeScannerDialogPlatform of the QrBarCodeScannerDialog plugin.
class QrBarCodeScannerDialogWeb extends QrBarCodeScannerDialogPlatform {
  QrBarCodeScannerDialogWeb() {
    _ensureInitialized();
  }
  static void registerWith(Registrar registrar) {
    QrBarCodeScannerDialogPlatform.instance = QrBarCodeScannerDialogWeb();
  }

  /// Initializes a DOM container where we can host input elements.
  html.Element _ensureInitialized() {
    var target = html.querySelector('#reader');
    if (target == null) {
      final html.Element targetElement = html.Element.div()
        ..id = "reader"
        ..className = "modal";

      final html.Element content = html.Element.div()
        ..className = "modal-content";

      final html.Element div = html.Element.div()..className = "container";

      final html.Element reader = html.Element.div()..id = "qr-reader";

      div.children.add(reader);

      content.children.add(div);
      targetElement.children.add(content);

      final body = html.querySelector('body')!;

      body.children.add(targetElement);

      final script = html.ScriptElement()
        ..src = "https://unpkg.com/html5-qrcode";
      body.children.add(script);

      final head = html.querySelector('head')!;
      final style = html.StyleElement();

      final styleContent = html.Text("""
        /* In order to place the tracking correctly */
        /* The Modal (background) */
        .modal {
          display: none; /* Hidden by default */
          position: fixed; /* Stay in place */
          z-index: 1; /* Sit on top */
          padding-top: 100px; /* Location of the box */
          left: 0;
          top: 0;
          width: 100%; /* Full width */
          height: 100%; /* Full height */
          overflow: auto; /* Enable scroll if needed */
          background-color: rgb(0,0,0); /* Fallback color */
          background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
        }
        
        /* Modal Content */
        .modal-content {
          margin: auto;
          max-width: 600px;
          border-radius: 10px;
        }
        
        #qr-reader {
          position: relative;
          background: white;
          border-radius: 10px;
          border: none;
          padding: 20px;
        }

        .container {
          width: 100% !important;
        }
        
        video {
          width: 100% !important;
          height: 100% !important;
        }

        #qr-shaded-region {
          margin: 20px !important;
        }
      
      """);

      final codeScript = html.ScriptElement();
      final scriptText = html.Text(r"""
        var html5QrCode;
        // Get the modal
        var modal = document.getElementById("reader");
        var qrReader = document.getElementById('qr-reader');
        
        // When the user clicks anywhere outside of the modal, close it
        window.onclick = function(event) {
          if (event.target == modal) {
            modal.style.display = "none";
              if(html5QrCode!=null)
                html5QrCode.stop();
          }
        }

        async function scanCode(message, enableFlip) {
          //refer doc here https://github.com/mebjas/html5-qrcode
          html5QrCode = new Html5Qrcode("qr-reader");
          console.log("Starting SCANNING CODE");
          if (enableFlip) {
            qrReader.style.transform = "rotateY(180deg)";
          } else {
            qrReader.style.transform = "rotateY(0deg)";
          }
          
          modal.style.display = "block";

          const qrCodeSuccessCallback = (decodedText, decodedResult) => {
              /* handle success for web */
              console.log(`${decodedText}`, decodedResult);
              message(`${decodedText}`);
              html5QrCode.stop();
              modal.style.display = "none";
          };
          const config = {
              fps: 10,
              qrbox: {
                  width: 250,
                  height: 250,
              }
          };

          // If you want to prefer back camera
          html5QrCode.start({
              facingMode: "environment"
          }, config, qrCodeSuccessCallback);
          //html5QrCode.start({ facingMode: "user" }, config, qrCodeSuccessCallback);

           //Window event listener
          if (window.chrome.webview != undefined) {
              window.chrome.webview.addEventListener('message', function(e) {
                  let data = JSON.parse(JSON.stringify(e.data));
                  if (data.event === "close") {
                      html5QrCode.stop();
                  }

              });
          }
        
        }
        
      """);
      codeScript.nodes.add(scriptText);

      style.nodes.add(styleContent);
      head.children.add(style);
      head.children.add(codeScript);

      target = targetElement;
    }
    return target;
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }

  /// Returns a [String] containing the operating system of the platform.
  @override
  Future<String?> getOperatingSystemName() async {
    final version = html.window.navigator.userAgent;
    var OSName = "Unknown OS";
    if (version.indexOf("Win") != -1) OSName = "Windows";
    if (version.indexOf("Mac") != -1) OSName = "Macintosh";
    if (version.indexOf("Linux") != -1) OSName = "Linux";
    if (version.indexOf("Android") != -1) OSName = "Android";
    if (version.indexOf("like Mac") != -1) OSName = "iOS";
    return OSName;
  }

  @override
  void scanBarOrQrCode(
      {BuildContext? context,
      required Function(String?) onScanSuccess,
      bool? enableFlip = true}) {
    js.context.callMethod("scanCode", [onScanSuccess, enableFlip]);
  }
}
