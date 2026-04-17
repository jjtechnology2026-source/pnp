import 'package:pnpdll_dart/pnpdll_dart.dart';

void main() {
  final client = PnpDllClient.ffi(
    dllPath: r'C:\ruta\a\pnpdll64.dll',
  );

  try {
    final result = client.imprimirDocumentoNoFiscal(
      const NonFiscalDocumentRequest(
        port: '13',
        customerName: 'CLIENTE DEMO',
        customerRif: 'J123456789',
        lines: <NonFiscalLine>[
          NonFiscalLine(description: 'DOCUMENTO NO FISCAL'),
          NonFiscalLine(description: 'SEGUNDA LINEA'),
        ],
      ),
    );

    print(result.toJson());
  } finally {
    client.close();
  }
}
