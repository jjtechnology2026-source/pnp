import 'package:pnpdll_dart/pnpdll_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InvoiceNumberParser', () {
    test('parsea numero con etiqueta FACTURA', () {
      final number = InvoiceNumberParser.parse('FACTURA=00001234');
      expect(number, '1234');
    });

    test('parsea numero en formato FAC|', () {
      final number = InvoiceNumberParser.parse('FAC|0000456');
      expect(number, '456');
    });

    test('ignora respuesta de error estructurada', () {
      final number = InvoiceNumberParser.parse(
        '0080,0600,EOB0000000,J-00000000-0',
      );
      expect(number, isNull);
    });
  });

  group('ZReportParser', () {
    test('parsea formato clave valor', () {
      final report = ZReportParser.parse(
        'Z=000089|FECHA=20260415|HORA=153455|FACINI=000120|'
        'FACFIN=000180|TOTALVENTAS=1234.50|BASEG=1000.00|IVAG=160.00',
      );

      expect(report.zNumber, '000089');
      expect(report.date, '20260415');
      expect(report.time, '153455');
      expect(report.firstInvoice, '000120');
      expect(report.lastInvoice, '000180');
      expect(report.totalSales, 1234.50);
      expect(report.generalBase, 1000.00);
      expect(report.generalTax, 160.00);
      expect(report.hasStructuredData, isTrue);
    });

    test('parsea formato posicional', () {
      final report = ZReportParser.parse(
        'Z|000090|20260416|101500|000181|000200|2500.00|2000.00|320.00',
      );

      expect(report.zNumber, '000090');
      expect(report.date, '20260416');
      expect(report.time, '101500');
      expect(report.firstInvoice, '000181');
      expect(report.lastInvoice, '000200');
      expect(report.totalSales, 2500.00);
      expect(report.generalBase, 2000.00);
      expect(report.generalTax, 320.00);
      expect(report.hasStructuredData, isTrue);
    });
  });
}
