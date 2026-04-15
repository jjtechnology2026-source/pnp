import 'package:pnpdll_dart/pnpdll_dart.dart';
import 'package:test/test.dart';

void main() {
  group('PnpDllClient.facturar', () {
    test('usa fallback por comando cuando PFultimo no trae numero', () {
      final native = _FakeNativeExecutor(<String, String>{
        'PFabrepuerto|13': 'OK',
        'PFabrefiscal|CLIENTE DEMO|J123456789': 'OK',
        'PFrenglon|ITEM|1|1000|1600': 'OK',
        'PFTfiscal|PAGO MOVIL': 'OK',
        'PFtotal': 'OK',
        'PFultimo': '',
        'PFComando|9|X': 'FACTURA=00001234',
      });

      final client = PnpDllClient(native);

      final result = client.facturar(
        const InvoiceRequest(
          port: '13',
          customerName: 'CLIENTE DEMO',
          customerRif: 'J123456789',
          lines: <InvoiceLine>[
            InvoiceLine(
              description: 'ITEM',
              quantity: '1',
              amount: '1000',
              tax: '1600',
            ),
          ],
          fiscalTexts: <String>['PAGO MOVIL'],
        ),
      );

      expect(result.invoiceNumber, '1234');
      expect(result.invoiceNumberSource, OrigenNumeroFactura.comando9X);
      expect(result.warnings, isEmpty);
    });

    test('marca advertencia cuando no puede obtener numero', () {
      final native = _FakeNativeExecutor(<String, String>{
        'PFabrepuerto|13': 'OK',
        'PFabrefiscal|CLIENTE DEMO|J123456789': 'OK',
        'PFrenglon|ITEM|1|1000|1600': 'OK',
        'PFtotal': 'OK',
        'PFultimo': '',
        'PFComando|9|X': 'OK',
        'PFestatus': 'OK',
      });

      final client = PnpDllClient(native);
      final result = client.facturar(
        const InvoiceRequest(
          port: '13',
          customerName: 'CLIENTE DEMO',
          customerRif: 'J123456789',
          lines: <InvoiceLine>[
            InvoiceLine(
              description: 'ITEM',
              quantity: '1',
              amount: '1000',
              tax: '1600',
            ),
          ],
        ),
      );

      expect(result.invoiceNumber, isNull);
      expect(result.warnings, isNotEmpty);
    });
  });

  group('PnpDllClient.obtenerReporteZEstructurado', () {
    test('parsea payload de PFultimo despues de reporte Z', () {
      final native = _FakeNativeExecutor(<String, String>{
        'PFrepz': 'OK',
        'PFultimo':
            'Z=000089|FECHA=20260415|HORA=153455|FACINI=000120|FACFIN=000180|TOTALVENTAS=1234.50',
      });

      final client = PnpDllClient(native);
      final result = client.obtenerReporteZEstructurado();

      expect(result.report.zNumber, '000089');
      expect(result.report.lastInvoice, '000180');
      expect(result.report.totalSales, 1234.50);
    });
  });

  group('PnpDllClient.notaCredito', () {
    test('expone alias explicito sobre PFDevolucion', () {
      final native = _FakeNativeExecutor(<String, String>{
        'PFDevolucion|0001|1500': 'OK',
      });

      final client = PnpDllClient(native);
      final response = client.notaCredito('0001', '1500');

      expect(response.functionName, 'PFDevolucion');
      expect(response.raw, 'OK');
    });
  });
}

class _FakeNativeExecutor implements NativeExecutor {
  _FakeNativeExecutor(this._responses);

  final Map<String, String> _responses;

  @override
  void close() {}

  @override
  String invoke0(String functionName) => _responses[functionName] ?? 'OK';

  @override
  String invoke1(String functionName, String arg1) =>
      _responses['$functionName|$arg1'] ?? 'OK';

  @override
  String invoke2(String functionName, String arg1, String arg2) =>
      _responses['$functionName|$arg1|$arg2'] ?? 'OK';

  @override
  String invoke3(String functionName, String arg1, String arg2, String arg3) =>
      _responses['$functionName|$arg1|$arg2|$arg3'] ?? 'OK';

  @override
  String invoke4(
    String functionName,
    String arg1,
    String arg2,
    String arg3,
    String arg4,
  ) =>
      _responses['$functionName|$arg1|$arg2|$arg3|$arg4'] ?? 'OK';
}
