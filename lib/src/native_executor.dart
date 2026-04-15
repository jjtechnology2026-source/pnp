import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

typedef _Native0 = Pointer<Utf8> Function();
typedef _Dart0 = Pointer<Utf8> Function();

typedef _Native1 = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _Dart1 = Pointer<Utf8> Function(Pointer<Utf8>);

typedef _Native2 = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _Dart2 = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);

typedef _Native3 = Pointer<Utf8> Function(
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
);
typedef _Dart3 = Pointer<Utf8> Function(
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
);

typedef _Native4 = Pointer<Utf8> Function(
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
);
typedef _Dart4 = Pointer<Utf8> Function(
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
);

abstract class NativeExecutor {
  String invoke0(String functionName);
  String invoke1(String functionName, String arg1);
  String invoke2(String functionName, String arg1, String arg2);
  String invoke3(String functionName, String arg1, String arg2, String arg3);
  String invoke4(
    String functionName,
    String arg1,
    String arg2,
    String arg3,
    String arg4,
  );

  void close();
}

class FfiNativeExecutor implements NativeExecutor {
  FfiNativeExecutor._(this._dynamicLibrary);

  factory FfiNativeExecutor.open({
    String? dllPath,
    bool preferTestDll = false,
    bool prefer32BitDll = false,
  }) {
    final resolvedPath = resolveDllPath(
      explicitPath: dllPath,
      preferTestDll: preferTestDll,
      prefer32BitDll: prefer32BitDll,
    );
    final dynamicLibrary = DynamicLibrary.open(resolvedPath);
    return FfiNativeExecutor._(dynamicLibrary);
  }

  static String resolveDllPath({
    String? explicitPath,
    bool preferTestDll = false,
    bool prefer32BitDll = false,
  }) {
    if (explicitPath != null && explicitPath.trim().isNotEmpty) {
      if (!File(explicitPath).existsSync()) {
        throw ArgumentError.value(
          explicitPath,
          'explicitPath',
          'No existe el DLL indicado.',
        );
      }
      return explicitPath;
    }

    final fromEnv = Platform.environment['PNPDLL_DLL_PATH'];
    if (fromEnv != null &&
        fromEnv.trim().isNotEmpty &&
        File(fromEnv).existsSync()) {
      return fromEnv;
    }

    final is64Process = sizeOf<IntPtr>() == 8;
    final dllNames = <String>[
      if (preferTestDll && is64Process && !prefer32BitDll) 'pnpdlltest64.dll',
      if (preferTestDll && (!is64Process || prefer32BitDll)) 'pnpdlltest.dll',
      if (is64Process && !prefer32BitDll) 'pnpdll64.dll',
      if (!is64Process || prefer32BitDll) 'pnpdll.dll',
      if (!preferTestDll && is64Process && !prefer32BitDll) 'pnpdlltest64.dll',
      if (!preferTestDll && (!is64Process || prefer32BitDll)) 'pnpdlltest.dll',
    ];

    final searchDirs = <String>{
      Directory.current.path,
      Directory(Platform.resolvedExecutable).parent.path,
    };

    for (final dir in searchDirs) {
      for (final dllName in dllNames) {
        final candidate = File(_joinPath(dir, dllName));
        if (candidate.existsSync()) {
          return candidate.path;
        }
      }
    }

    throw StateError(
      'No se pudo ubicar pnpdll. Coloque el DLL en el directorio actual '
      'o configure PNPDLL_DLL_PATH.',
    );
  }

  final DynamicLibrary _dynamicLibrary;
  final Map<String, _Dart0> _cache0 = <String, _Dart0>{};
  final Map<String, _Dart1> _cache1 = <String, _Dart1>{};
  final Map<String, _Dart2> _cache2 = <String, _Dart2>{};
  final Map<String, _Dart3> _cache3 = <String, _Dart3>{};
  final Map<String, _Dart4> _cache4 = <String, _Dart4>{};

  @override
  String invoke0(String functionName) {
    final fn = _cache0.putIfAbsent(
      functionName,
      () => _dynamicLibrary.lookupFunction<_Native0, _Dart0>(functionName),
    );
    return _ptrToString(fn());
  }

  @override
  String invoke1(String functionName, String arg1) {
    final fn = _cache1.putIfAbsent(
      functionName,
      () => _dynamicLibrary.lookupFunction<_Native1, _Dart1>(functionName),
    );

    final p1 = arg1.toNativeUtf8(allocator: calloc);
    try {
      return _ptrToString(fn(p1));
    } finally {
      calloc.free(p1);
    }
  }

  @override
  String invoke2(String functionName, String arg1, String arg2) {
    final fn = _cache2.putIfAbsent(
      functionName,
      () => _dynamicLibrary.lookupFunction<_Native2, _Dart2>(functionName),
    );

    final p1 = arg1.toNativeUtf8(allocator: calloc);
    final p2 = arg2.toNativeUtf8(allocator: calloc);
    try {
      return _ptrToString(fn(p1, p2));
    } finally {
      calloc.free(p1);
      calloc.free(p2);
    }
  }

  @override
  String invoke3(String functionName, String arg1, String arg2, String arg3) {
    final fn = _cache3.putIfAbsent(
      functionName,
      () => _dynamicLibrary.lookupFunction<_Native3, _Dart3>(functionName),
    );

    final p1 = arg1.toNativeUtf8(allocator: calloc);
    final p2 = arg2.toNativeUtf8(allocator: calloc);
    final p3 = arg3.toNativeUtf8(allocator: calloc);
    try {
      return _ptrToString(fn(p1, p2, p3));
    } finally {
      calloc.free(p1);
      calloc.free(p2);
      calloc.free(p3);
    }
  }

  @override
  String invoke4(
    String functionName,
    String arg1,
    String arg2,
    String arg3,
    String arg4,
  ) {
    final fn = _cache4.putIfAbsent(
      functionName,
      () => _dynamicLibrary.lookupFunction<_Native4, _Dart4>(functionName),
    );

    final p1 = arg1.toNativeUtf8(allocator: calloc);
    final p2 = arg2.toNativeUtf8(allocator: calloc);
    final p3 = arg3.toNativeUtf8(allocator: calloc);
    final p4 = arg4.toNativeUtf8(allocator: calloc);
    try {
      return _ptrToString(fn(p1, p2, p3, p4));
    } finally {
      calloc.free(p1);
      calloc.free(p2);
      calloc.free(p3);
      calloc.free(p4);
    }
  }

  @override
  void close() {
    // No-op: DynamicLibrary se libera con el GC del proceso.
  }

  String _ptrToString(Pointer<Utf8> pointer) {
    if (pointer.address == 0) {
      return '';
    }
    return pointer.toDartString();
  }

  static String _joinPath(String left, String right) {
    final separator = Platform.pathSeparator;
    if (left.endsWith(separator)) {
      return '$left$right';
    }
    return '$left$separator$right';
  }
}
