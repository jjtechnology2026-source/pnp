enum OrigenNumeroFactura {
  pfUltimo,
  comando9X,
  comandoAlterno,
  estatus,
  noDisponible,
}

class PnpResponse {
  const PnpResponse({
    required this.functionName,
    required this.raw,
  });

  final String functionName;
  final String raw;

  bool get isOk => raw.trim().toUpperCase() == 'OK';
  bool get isError => raw.trim().toUpperCase() == 'ER';
  bool get isNotProcessed => raw.trim().toUpperCase() == 'NP';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'functionName': functionName,
      'raw': raw,
      'isOk': isOk,
      'isError': isError,
      'isNotProcessed': isNotProcessed,
    };
  }

  @override
  String toString() => 'PnpResponse($functionName=$raw)';
}

class InvoiceLine {
  const InvoiceLine({
    required this.description,
    required this.quantity,
    required this.amount,
    required this.tax,
  });

  final String description;
  final String quantity;
  final String amount;
  final String tax;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'description': description,
      'quantity': quantity,
      'amount': amount,
      'tax': tax,
    };
  }
}

class NonFiscalLine {
  const NonFiscalLine({
    required this.description,
    this.quantity = '1',
    this.amount = '0',
    this.tax = '0',
  });

  final String description;
  final String quantity;
  final String amount;
  final String tax;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'description': description,
      'quantity': quantity,
      'amount': amount,
      'tax': tax,
    };
  }
}

class InvoiceRequest {
  const InvoiceRequest({
    required this.port,
    required this.customerName,
    required this.customerRif,
    required this.lines,
    this.paymentCommands = const <String>[],
    this.fiscalTexts = const <String>[],
    this.invoiceNumberProbeCommands = const <String>['9|X'],
  });

  final String port;
  final String customerName;
  final String customerRif;
  final List<InvoiceLine> lines;
  final List<String> paymentCommands;
  final List<String> fiscalTexts;
  final List<String> invoiceNumberProbeCommands;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'port': port,
      'customerName': customerName,
      'customerRif': customerRif,
      'lines': lines.map((e) => e.toJson()).toList(growable: false),
      'paymentCommands': paymentCommands,
      'fiscalTexts': fiscalTexts,
      'invoiceNumberProbeCommands': invoiceNumberProbeCommands,
    };
  }
}

class InvoiceResult {
  const InvoiceResult({
    required this.responses,
    required this.invoiceNumber,
    required this.invoiceNumberSource,
    required this.invoiceNumberProbes,
    required this.warnings,
  });

  final Map<String, PnpResponse> responses;
  final String? invoiceNumber;
  final OrigenNumeroFactura invoiceNumberSource;
  final List<PnpResponse> invoiceNumberProbes;
  final List<String> warnings;

  bool get hasInvoiceNumber =>
      invoiceNumber != null && invoiceNumber!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'responses': responses.map(
        (key, value) => MapEntry<String, dynamic>(key, value.toJson()),
      ),
      'invoiceNumber': invoiceNumber,
      'invoiceNumberSource': invoiceNumberSource.name,
      'invoiceNumberProbes':
          invoiceNumberProbes.map((e) => e.toJson()).toList(growable: false),
      'warnings': warnings,
    };
  }
}

class NonFiscalDocumentRequest {
  const NonFiscalDocumentRequest({
    required this.port,
    required this.customerName,
    required this.customerRif,
    required this.lines,
  });

  final String port;
  final String customerName;
  final String customerRif;
  final List<NonFiscalLine> lines;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'port': port,
      'customerName': customerName,
      'customerRif': customerRif,
      'lines': lines.map((e) => e.toJson()).toList(growable: false),
    };
  }
}

class NonFiscalDocumentResult {
  const NonFiscalDocumentResult({
    required this.responses,
    required this.warnings,
    required this.processedLines,
  });

  final Map<String, PnpResponse> responses;
  final List<String> warnings;
  final int processedLines;

  int get lineasProcesadas => processedLines;

  bool get ok => warnings.isEmpty;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'responses': responses.map(
        (key, value) => MapEntry<String, dynamic>(key, value.toJson()),
      ),
      'warnings': warnings,
      'processedLines': processedLines,
    };
  }
}

class ZReport {
  const ZReport({
    required this.raw,
    this.zNumber,
    this.date,
    this.time,
    this.serial,
    this.rif,
    this.firstInvoice,
    this.lastInvoice,
    this.firstCreditNote,
    this.lastCreditNote,
    this.totalSales,
    this.exemptSales,
    this.generalBase,
    this.generalTax,
    this.reducedBase,
    this.reducedTax,
    this.additionalBase,
    this.additionalTax,
    this.debitNoteAmount,
    this.creditNoteAmount,
    this.canceledDocuments,
    this.extra = const <String, String>{},
  });

  final String raw;
  final String? zNumber;
  final String? date;
  final String? time;
  final String? serial;
  final String? rif;
  final String? firstInvoice;
  final String? lastInvoice;
  final String? firstCreditNote;
  final String? lastCreditNote;
  final num? totalSales;
  final num? exemptSales;
  final num? generalBase;
  final num? generalTax;
  final num? reducedBase;
  final num? reducedTax;
  final num? additionalBase;
  final num? additionalTax;
  final num? debitNoteAmount;
  final num? creditNoteAmount;
  final num? canceledDocuments;
  final Map<String, String> extra;

  bool get hasStructuredData {
    return zNumber != null ||
        date != null ||
        firstInvoice != null ||
        lastInvoice != null ||
        totalSales != null;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'raw': raw,
      'zNumber': zNumber,
      'date': date,
      'time': time,
      'serial': serial,
      'rif': rif,
      'firstInvoice': firstInvoice,
      'lastInvoice': lastInvoice,
      'firstCreditNote': firstCreditNote,
      'lastCreditNote': lastCreditNote,
      'totalSales': totalSales,
      'exemptSales': exemptSales,
      'generalBase': generalBase,
      'generalTax': generalTax,
      'reducedBase': reducedBase,
      'reducedTax': reducedTax,
      'additionalBase': additionalBase,
      'additionalTax': additionalTax,
      'debitNoteAmount': debitNoteAmount,
      'creditNoteAmount': creditNoteAmount,
      'canceledDocuments': canceledDocuments,
      'extra': extra,
    };
  }
}

class ZReportResult {
  const ZReportResult({
    required this.trigger,
    required this.payload,
    required this.report,
    this.probes = const <PnpResponse>[],
  });

  final PnpResponse trigger;
  final PnpResponse payload;
  final ZReport report;
  final List<PnpResponse> probes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'trigger': trigger.toJson(),
      'payload': payload.toJson(),
      'report': report.toJson(),
      'probes': probes.map((e) => e.toJson()).toList(growable: false),
    };
  }
}
