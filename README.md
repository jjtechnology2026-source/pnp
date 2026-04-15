# pnpdll_dart

Paquete Dart para integrar la DLL pnpdll de impresoras fiscales PNP via FFI.

## Que incluye

- Wrapper FFI para funciones exportadas de pnpdll.
- Cliente de alto nivel para emitir factura fiscal.
- Deteccion de numero de factura al cerrar una factura.
- Parser estructurado de reporte Z.
- Tests unitarios para parser y flujo.

## Requisitos

- Windows
- Dart SDK 3.3+
- DLL en el directorio de trabajo o variable de entorno PNPDLL_DLL_PATH.

## Uso rapido

```dart
import 'package:pnpdll_dart/pnpdll_dart.dart';

void main() {
  final client = PnpDllClient.ffi(
    dllPath: r'C:\ruta\a\pnpdll64.dll',
  );

  try {
    final result = client.facturar(
      const InvoiceRequest(
        port: '13',
        customerName: 'CLIENTE DEMO',
        customerRif: 'J123456789',
        lines: <InvoiceLine>[
          InvoiceLine(
            description: 'Producto A',
            quantity: '1',
            amount: '1000',
            tax: '1600',
          ),
        ],
        paymentCommands: <String>['E|B|1000'],
        fiscalTexts: <String>['PAGO MOVIL'],
      ),
    );

    print(result.toJson());

    final reporteZ = client.obtenerReporteZEstructurado();
    print(reporteZ.report.toJson());
  } finally {
    client.close();
  }
}
```

## Verificacion de numero de factura

El flujo facturar intenta obtener el numero en este orden:

1. PFultimo
2. PFComando con probes (por defecto 9|X)
3. PFestatus

En la DLL de prueba de este proyecto, un flujo exitoso retorna OK pero PFultimo puede quedar vacio. Por eso se agrega fallback con comandos de sondeo.

## Estructura del reporte Z

El modelo ZReport entrega:

- zNumber
- date
- time
- serial
- rif
- firstInvoice
- lastInvoice
- firstCreditNote
- lastCreditNote
- totalSales
- exemptSales
- generalBase
- generalTax
- reducedBase
- reducedTax
- additionalBase
- additionalTax
- debitNoteAmount
- creditNoteAmount
- canceledDocuments
- extra

Cuando la salida del equipo no llega en formato clave=valor, el parser intenta modo posicional.

## Nota de compatibilidad

Algunas firmas menos usadas fueron inferidas por nombres y pistas del ejecutable de prueba. Si una funcion especifica de tu manual usa otra firma, puedes ajustar la llamada o utilizar ejecutarComando.
