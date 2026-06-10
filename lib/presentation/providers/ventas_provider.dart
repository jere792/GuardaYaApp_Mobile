import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/usecases/ventas/buscar_venta_por_codigo.dart';
import 'package:guardaya_app/domain/usecases/ventas/buscar_venta_por_telefono.dart';
import 'package:guardaya_app/domain/usecases/ventas/obtener_ventas_por_fecha.dart';
import 'package:guardaya_app/domain/usecases/ventas/registrar_venta.dart';

final ventasProvider = StateNotifierProvider<VentasNotifier, VentasState>((ref) {
  return VentasNotifier(
    registrar: ref.watch(registrarVentaProvider),
    obtenerPorFecha: ref.watch(obtenerVentasPorFechaProvider),
    buscarPorCodigo: ref.watch(buscarPorCodigoProvider),
    buscarPorTelefono: ref.watch(buscarPorTelefonoProvider),
  );
});

final registrarVentaProvider = Provider<RegistrarVenta>((ref) {
  throw UnimplementedError();
});

final obtenerVentasPorFechaProvider = Provider<ObtenerVentasPorFecha>((ref) {
  throw UnimplementedError();
});

final buscarPorCodigoProvider = Provider<BuscarVentaPorCodigo>((ref) {
  throw UnimplementedError();
});

final buscarPorTelefonoProvider = Provider<BuscarVentaPorTelefono>((ref) {
  throw UnimplementedError();
});

class VentasState {
  final List<Venta> ventas;
  final Venta? ventaSeleccionada;
  final bool isLoading;
  final String? error;

  const VentasState({
    this.ventas = const [],
    this.ventaSeleccionada,
    this.isLoading = false,
    this.error,
  });

  VentasState copyWith({
    List<Venta>? ventas,
    Venta? ventaSeleccionada,
    bool? isLoading,
    String? error,
  }) {
    return VentasState(
      ventas: ventas ?? this.ventas,
      ventaSeleccionada: ventaSeleccionada ?? this.ventaSeleccionada,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class VentasNotifier extends StateNotifier<VentasState> {
  final RegistrarVenta _registrar;
  final ObtenerVentasPorFecha _obtenerPorFecha;
  final BuscarVentaPorCodigo _buscarPorCodigo;
  final BuscarVentaPorTelefono _buscarPorTelefono;

  VentasNotifier({
    required RegistrarVenta registrar,
    required ObtenerVentasPorFecha obtenerPorFecha,
    required BuscarVentaPorCodigo buscarPorCodigo,
    required BuscarVentaPorTelefono buscarPorTelefono,
  })  : _registrar = registrar,
        _obtenerPorFecha = obtenerPorFecha,
        _buscarPorCodigo = buscarPorCodigo,
        _buscarPorTelefono = buscarPorTelefono,
        super(const VentasState());

  Future<void> registrarVenta(Venta venta) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _registrar(venta);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (venta) => state = state.copyWith(isLoading: false, ventas: [...state.ventas, venta]),
    );
  }

  Future<void> obtenerVentasDelDia(String empresaId, DateTime fecha) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _obtenerPorFecha(ObtenerVentasParams(empresaId: empresaId, fecha: fecha));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (ventas) => state = state.copyWith(isLoading: false, ventas: ventas),
    );
  }

  Future<void> buscarPorCodigo(String empresaId, String codigo) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _buscarPorCodigo(BuscarVentaPorCodigoParams(empresaId: empresaId, codigo: codigo));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (venta) => state = state.copyWith(isLoading: false, ventaSeleccionada: venta),
    );
  }

  Future<void> buscarPorTelefono(String empresaId, String telefono) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _buscarPorTelefono(BuscarVentaPorTelefonoParams(empresaId: empresaId, telefono: telefono));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (ventas) => state = state.copyWith(isLoading: false, ventas: ventas),
    );
  }
}