import 'models.dart';

class InvoiceNumberParser {
  static String? parse(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return null;
    }

    final upper = value.toUpperCase();
    if (upper == 'OK' || upper == 'ER' || upper == 'NP') {
      return null;
    }

    final labeledPatterns = <RegExp>[
      RegExp(
        r'(?:NRO\s*FACTURA|NUMERO\s*FACTURA|FACTURA|NROFAC|NUMFAC|FAC)\s*[:=#\- ]\s*0*([0-9]{1,12})',
        caseSensitive: false,
      ),
      RegExp(r'FAC\s*[|]\s*0*([0-9]{1,12})', caseSensitive: false),
      RegExp(r'N\s*[|]\s*0*([0-9]{1,12})', caseSensitive: false),
    ];

    for (final pattern in labeledPatterns) {
      final match = pattern.firstMatch(value);
      if (match != null) {
        return _normalizeNumber(match.group(1));
      }
    }

    final keyValueCandidates = value.split(RegExp(r'[|,;]'));
    for (var i = 0; i < keyValueCandidates.length; i++) {
      final token = keyValueCandidates[i].trim();
      if (token.contains('=') || token.contains(':')) {
        final parts = token.split(RegExp(r'[:=]'));
        if (parts.length < 2) {
          continue;
        }

        final key = parts.first.trim().toUpperCase();
        final data = parts.sublist(1).join(':').trim();
        if (_isInvoiceKey(key)) {
          final parsed = _normalizeNumber(data);
          if (parsed != null) {
            return parsed;
          }
        }
      }
    }

    final numericTokens = RegExp(r'\b0*[0-9]{1,12}\b')
        .allMatches(value)
        .map((e) => e.group(0) ?? '')
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    if (numericTokens.length == 1) {
      return _normalizeNumber(numericTokens.single);
    }

    return null;
  }

  static bool _isInvoiceKey(String key) {
    final normalized = key.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return normalized.contains('FACTURA') ||
        normalized == 'FAC' ||
        normalized == 'NROFAC' ||
        normalized == 'NUMFAC';
  }

  static String? _normalizeNumber(String? data) {
    if (data == null) {
      return null;
    }

    final digits = data.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return null;
    }

    final normalized = digits.replaceFirst(RegExp(r'^0+(?!$)'), '');
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}

class ZReportParser {
  static ZReport parse(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return ZReport(raw: raw);
    }

    if (value.toUpperCase() == 'OK') {
      return ZReport(raw: raw);
    }

    final keyValues = _extractKeyValues(value);
    if (keyValues.isNotEmpty) {
      return _fromKeyValues(value, keyValues);
    }

    return _fromPositional(value);
  }

  static Map<String, String> _extractKeyValues(String value) {
    final map = <String, String>{};
    final matches = RegExp(r'([A-Za-z_][A-Za-z0-9_ ]{0,30})\s*[:=]\s*([^|,;]+)')
        .allMatches(value);

    for (final match in matches) {
      final key = match.group(1)?.trim();
      final data = match.group(2)?.trim();
      if (key == null || data == null || key.isEmpty || data.isEmpty) {
        continue;
      }
      map[_normalizeKey(key)] = data;
    }

    return map;
  }

  static ZReport _fromKeyValues(String raw, Map<String, String> values) {
    String? pick(List<String> keys) {
      for (final key in keys) {
        final data = values[key];
        if (data != null && data.trim().isNotEmpty) {
          return data.trim();
        }
      }
      return null;
    }

    final extra = Map<String, String>.from(values);

    String? takeString(List<String> keys) {
      final result = pick(keys);
      if (result != null) {
        for (final key in keys) {
          extra.remove(key);
        }
      }
      return result;
    }

    num? takeNumber(List<String> keys) {
      final data = pick(keys);
      if (data == null) {
        return null;
      }
      for (final key in keys) {
        extra.remove(key);
      }
      return _parseNum(data);
    }

    return ZReport(
      raw: raw,
      zNumber: takeString(<String>['Z', 'NUMEROZ', 'NROZ', 'REPORTEZ']),
      date: takeString(<String>['FECHA', 'FEC']),
      time: takeString(<String>['HORA']),
      serial: takeString(<String>['SERIAL']),
      rif: takeString(<String>['RIF']),
      firstInvoice: takeString(
        <String>['FACTURAINI', 'FACINI', 'PRIMERAFACTURA', 'FACDESDE'],
      ),
      lastInvoice: takeString(
        <String>['FACTURAFIN', 'FACFIN', 'ULTIMAFACTURA', 'FACHASTA'],
      ),
      firstCreditNote: takeString(<String>['NCINI', 'NOTACREDITOINI']),
      lastCreditNote: takeString(<String>['NCFIN', 'NOTACREDITOFIN']),
      totalSales:
          takeNumber(<String>['TOTALVENTAS', 'VENTASTOTALES', 'VENTAS']),
      exemptSales: takeNumber(<String>['EXENTO', 'VENTASEXENTAS']),
      generalBase: takeNumber(<String>['BASEGENERAL', 'BASEG']),
      generalTax: takeNumber(<String>['IVAGENERAL', 'IVAG']),
      reducedBase: takeNumber(<String>['BASEREDUCIDA', 'BASER']),
      reducedTax: takeNumber(<String>['IVAREDUCIDO', 'IVAR']),
      additionalBase: takeNumber(<String>['BASEADICIONAL', 'BASEA']),
      additionalTax: takeNumber(<String>['IVAADICIONAL', 'IVAA']),
      debitNoteAmount: takeNumber(<String>['NOTADEBITO', 'TOTALND']),
      creditNoteAmount: takeNumber(<String>['NOTACREDITO', 'TOTALNC']),
      canceledDocuments: takeNumber(<String>['ANULADAS', 'DOCANULADOS']),
      extra: extra,
    );
  }

  static ZReport _fromPositional(String raw) {
    final tokens = raw
        .split(RegExp(r'[|,;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    if (tokens.isEmpty) {
      return ZReport(raw: raw);
    }

    String? token(int index) => index < tokens.length ? tokens[index] : null;

    final startsWithZ = tokens.first.toUpperCase() == 'Z';
    final base = startsWithZ ? 1 : 0;

    return ZReport(
      raw: raw,
      zNumber: token(base),
      date: token(base + 1),
      time: token(base + 2),
      firstInvoice: token(base + 3),
      lastInvoice: token(base + 4),
      totalSales: _parseNum(token(base + 5)),
      generalBase: _parseNum(token(base + 6)),
      generalTax: _parseNum(token(base + 7)),
      reducedBase: _parseNum(token(base + 8)),
      reducedTax: _parseNum(token(base + 9)),
      additionalBase: _parseNum(token(base + 10)),
      additionalTax: _parseNum(token(base + 11)),
    );
  }

  static String _normalizeKey(String key) {
    return key.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  static num? _parseNum(String? raw) {
    if (raw == null) {
      return null;
    }

    final value = raw.trim();
    if (value.isEmpty) {
      return null;
    }

    if (value.contains(',') && value.contains('.')) {
      return num.tryParse(value.replaceAll('.', '').replaceAll(',', '.'));
    }

    if (value.contains(',') && !value.contains('.')) {
      return num.tryParse(value.replaceAll(',', '.'));
    }

    return num.tryParse(value);
  }
}
