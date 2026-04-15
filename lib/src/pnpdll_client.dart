import 'models.dart';
import 'native_executor.dart';
import 'parsers.dart';

class PnpDllClient {
  PnpDllClient(
    this._native, {
    bool ownsExecutor = false,
  }) : _ownsExecutor = ownsExecutor;

  factory PnpDllClient.ffi({
    String? dllPath,
    bool preferTestDll = false,
    bool prefer32BitDll = false,
  }) {
    final executor = FfiNativeExecutor.open(
      dllPath: dllPath,
      preferTestDll: preferTestDll,
      prefer32BitDll: prefer32BitDll,
    );
    return PnpDllClient(executor, ownsExecutor: true);
  }

  final NativeExecutor _native;
  final bool _ownsExecutor;

  void close() {
    if (_ownsExecutor) {
      _native.close();
    }
  }

  // Funciones principales validadas con la DLL del proyecto.
  PnpResponse abrirPuerto(String puerto) => _call1('PFabrepuerto', puerto);
  PnpResponse cerrarPuerto() => _call0('PFcierrapuerto');
  PnpResponse abrirFacturaFiscal(String razon, String rif) =>
      _call2('PFabrefiscal', razon, rif);
  PnpResponse agregarRenglon(
    String descripcion,
    String cantidad,
    String monto,
    String iva,
  ) =>
      _call4('PFrenglon', descripcion, cantidad, monto, iva);
  PnpResponse textoFiscal(String texto) => _call1('PFTfiscal', texto);
  PnpResponse ejecutarComando(String comando) => _call1('PFComando', comando);
  PnpResponse total() => _call0('PFtotal');
  PnpResponse ultimoMensaje() => _call0('PFultimo');
  PnpResponse reporteZ() => _call0('PFrepz');
  PnpResponse reporteX() => _call0('PFrepx');
  PnpResponse estatus() => _call0('PFestatus');
  PnpResponse serial() => _call0('PFSerial');

  // Wrappers adicionales de la API exportada.
  PnpResponse abrirNotaNoFiscal(String razon, String rif) =>
      _call2('PFAbreNF', razon, rif);
  PnpResponse lineaNotaNoFiscal(
    String descripcion,
    String cantidad,
    String monto,
    String iva,
  ) =>
      _call4('PFLineaNF', descripcion, cantidad, monto, iva);
  PnpResponse cerrarNotaNoFiscal() => _call0('PFCierraNF');
  PnpResponse parcial() => _call0('PFparcial');
  PnpResponse subtotal() => _call0('PFsubtotal');
  PnpResponse totalEconomico() => _call0('PFtoteconomico');
  PnpResponse gaveta() => _call0('PFGaveta');
  PnpResponse cortar() => _call0('PFCortar');
  PnpResponse reset() => _call0('PFreset');
  PnpResponse slipOn() => _call0('PFSlipON');
  PnpResponse slipOff() => _call0('PFSLIPOFF');
  PnpResponse leerReloj() => _call0('PFLeereloj');
  PnpResponse voltea() => _call0('PFVoltea');
  PnpResponse tipoImpresora(String modelo) => _call1('PFTipoImp', modelo);
  PnpResponse cambiarFecha(String fechaAammdd, String horaHhmmss) =>
      _call2('PFcambiofecha', fechaAammdd, horaHhmmss);
  PnpResponse cambiarTasa(String tasa) => _call1('PFcambiatasa', tasa);
  PnpResponse valida675(String valor) => _call1('PFvalida675', valor);
  PnpResponse barra(String codigo) => _call1('PFBarra', codigo);
  PnpResponse promocion(String data) => _call1('PFPromocion', data);
  PnpResponse cheque(String data) => _call1('PFCheque', data);
  PnpResponse cheque2(String data) => _call1('PFCheque2', data);
  PnpResponse debito(String data) => _call1('PFDebito', data);
  PnpResponse descuento(String data) => _call1('PFDescuento', data);
  PnpResponse pago(String data) => _call1('PFPago', data);
  PnpResponse devolucion(String linea, String monto) =>
      _call2('PFDevolucion', linea, monto);
  PnpResponse notaCredito(String linea, String monto) =>
      devolucion(linea, monto);
  PnpResponse cancelarDocumento(String linea, String monto) =>
      _call2('PFCancelaDoc', linea, monto);
  PnpResponse endoso(String texto) => _call1('PFendoso', texto);
  PnpResponse display950(String texto) => _call1('PFDisplay950', texto);
  PnpResponse logoClick(String parametro) => _call1('PFLogoClick', parametro);
  PnpResponse cambiarTipoContribuyente(String data) =>
      _call1('PFCambtipoContrib', data);
  PnpResponse repMemNF(String desdeAammdd, String hastaAammdd, String modo) =>
      _call3('PFrepMemNF', desdeAammdd, hastaAammdd, modo);
  PnpResponse repMemoriaNumero(String desde, String hasta, String modo) =>
      _call3('PFRepMemoriaNumero', desde, hasta, modo);

  InvoiceResult facturar(InvoiceRequest request) {
    final responses = <String, PnpResponse>{};
    final warnings = <String>[];

    responses['PFabrepuerto'] = abrirPuerto(request.port);
    if (_isHardError(responses['PFabrepuerto']!)) {
      warnings.add('No fue posible abrir el puerto.');
      return InvoiceResult(
        responses: responses,
        invoiceNumber: null,
        invoiceNumberSource: OrigenNumeroFactura.noDisponible,
        invoiceNumberProbes: const <PnpResponse>[],
        warnings: warnings,
      );
    }

    responses['PFabrefiscal'] =
        abrirFacturaFiscal(request.customerName, request.customerRif);
    if (_isHardError(responses['PFabrefiscal']!)) {
      warnings.add('No fue posible abrir la factura fiscal.');
    }

    for (var i = 0; i < request.lines.length; i++) {
      final line = request.lines[i];
      responses['PFrenglon[$i]'] = agregarRenglon(
          line.description, line.quantity, line.amount, line.tax);
      if (_isHardError(responses['PFrenglon[$i]']!)) {
        warnings.add('Error agregando renglon $i.');
      }
    }

    for (var i = 0; i < request.paymentCommands.length; i++) {
      final command = request.paymentCommands[i];
      responses['PFComando[$i]'] = ejecutarComando(command);
      if (_isHardError(responses['PFComando[$i]']!)) {
        warnings.add('Error en comando de pago $i: $command');
      }
    }

    for (var i = 0; i < request.fiscalTexts.length; i++) {
      final text = request.fiscalTexts[i];
      responses['PFTfiscal[$i]'] = textoFiscal(text);
      if (_isHardError(responses['PFTfiscal[$i]']!)) {
        warnings.add('Error escribiendo texto fiscal $i.');
      }
    }

    responses['PFtotal'] = total();
    if (_isHardError(responses['PFtotal']!)) {
      warnings.add('No fue posible cerrar la factura con total.');
    }

    final probe = _obtenerNumeroFactura(request.invoiceNumberProbeCommands);
    if (probe.$1 == null) {
      warnings.add(
        'No se pudo determinar el numero de factura. '
        'Con la DLL de prueba del proyecto, PFultimo retorna vacio en exito.',
      );
    }

    return InvoiceResult(
      responses: responses,
      invoiceNumber: probe.$1,
      invoiceNumberSource: probe.$2,
      invoiceNumberProbes: probe.$3,
      warnings: warnings,
    );
  }

  ZReportResult obtenerReporteZEstructurado({
    List<String> payloadProbeCommands = const <String>['9|X'],
  }) {
    final trigger = reporteZ();
    final payload = ultimoMensaje();
    final probes = <PnpResponse>[];

    var report = ZReportParser.parse(payload.raw);

    if (!report.hasStructuredData) {
      report = ZReportParser.parse(trigger.raw);
    }

    if (!report.hasStructuredData) {
      for (var i = 0; i < payloadProbeCommands.length; i++) {
        final command = payloadProbeCommands[i];
        final response = ejecutarComando(command);
        probes.add(response);
        final parsed = ZReportParser.parse(response.raw);
        if (parsed.hasStructuredData) {
          report = parsed;
          break;
        }
      }
    }

    return ZReportResult(
      trigger: trigger,
      payload: payload,
      report: report,
      probes: probes,
    );
  }

  (String?, OrigenNumeroFactura, List<PnpResponse>) _obtenerNumeroFactura(
    List<String> commands,
  ) {
    final probes = <PnpResponse>[];

    final pfUltimo = ultimoMensaje();
    probes.add(pfUltimo);
    final byUltimo = InvoiceNumberParser.parse(pfUltimo.raw);
    if (byUltimo != null) {
      return (byUltimo, OrigenNumeroFactura.pfUltimo, probes);
    }

    for (var i = 0; i < commands.length; i++) {
      final cmd = commands[i];
      final response = ejecutarComando(cmd);
      probes.add(response);

      final parsed = InvoiceNumberParser.parse(response.raw);
      if (parsed != null) {
        final source = cmd == '9|X'
            ? OrigenNumeroFactura.comando9X
            : OrigenNumeroFactura.comandoAlterno;
        return (parsed, source, probes);
      }
    }

    final pfEstatus = estatus();
    probes.add(pfEstatus);
    final byStatus = InvoiceNumberParser.parse(pfEstatus.raw);
    if (byStatus != null) {
      return (byStatus, OrigenNumeroFactura.estatus, probes);
    }

    return (null, OrigenNumeroFactura.noDisponible, probes);
  }

  bool _isHardError(PnpResponse response) {
    return response.isError || response.isNotProcessed;
  }

  PnpResponse _call0(String functionName) {
    return PnpResponse(
      functionName: functionName,
      raw: _native.invoke0(functionName),
    );
  }

  PnpResponse _call1(String functionName, String arg1) {
    return PnpResponse(
      functionName: functionName,
      raw: _native.invoke1(functionName, arg1),
    );
  }

  PnpResponse _call2(String functionName, String arg1, String arg2) {
    return PnpResponse(
      functionName: functionName,
      raw: _native.invoke2(functionName, arg1, arg2),
    );
  }

  PnpResponse _call3(
      String functionName, String arg1, String arg2, String arg3) {
    return PnpResponse(
      functionName: functionName,
      raw: _native.invoke3(functionName, arg1, arg2, arg3),
    );
  }

  PnpResponse _call4(
    String functionName,
    String arg1,
    String arg2,
    String arg3,
    String arg4,
  ) {
    return PnpResponse(
      functionName: functionName,
      raw: _native.invoke4(functionName, arg1, arg2, arg3, arg4),
    );
  }
}
