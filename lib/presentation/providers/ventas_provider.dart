import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/data/datasources/local/db/pending_ventas_dao.dart';
import 'package:guardaya_app/data/datasources/remote/ventas_datasource.dart';
import 'package:guardaya_app/data/repositories/implementations/ventas_repository_impl.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';
import 'package:guardaya_app/domain/usecases/ventas/buscar_venta_por_codigo.dart';
import 'package:guardaya_app/domain/usecases/ventas/buscar_venta_por_telefono.dart';
import 'package:guardaya_app/domain/usecases/ventas/cambiar_estado_venta.dart';
import 'package:guardaya_app/domain/usecases/ventas/obtener_venta_por_id.dart';
import 'package:guardaya_app/domain/usecases/ventas/obtener_ventas_por_fecha.dart';
import 'package:guardaya_app/domain/usecases/ventas/registrar_venta.dart';
import 'package:guardaya_app/services/connectivity_service.dart';

final ventasProvider = StateNotifierProvider<VentasNotifier, VentasState>((ref) {
  return VentasNotifier(
    registrar: ref.watch(registrarVentaProvider),
    obtenerPorFecha: ref.watch(obtenerVentasPorFechaProvider),
    buscarPorCodigo: ref.watch(buscarPorCodigoProvider),
    buscarPorTelefono: ref.watch(buscarPorTelefonoProvider),
    cambiarEstado: ref.watch(cambiarEstadoVentaProvider),
    obtenerPorId: ref.watch(obtenerVentaPorIdProvider),
  );
});

// Providers de dependencias
final ventasDatasourceProvider = Provider<VentasDatasource>((ref) => VentasDatasource());
final pendingVentasDaoProvider = Provider<PendingVentasDao>((ref) => PendingVentasDao());
final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());

final ventasRepositoryProvider = Provider<VentasRepository>((ref) {
  return VentasRepositoryImpl(
    ref.watch(ventasDatasourceProvider),
    ref.watch(pendingVentasDaoProvider),
    ref.watch(connectivityServiceProvider),
  );
});

// Providers de usecases
final registrarVentaProvider = Provider<RegistrarVenta>((ref) {
  return RegistrarVenta(ref.watch(ventasRepositoryProvider));
});

final obtenerVentasPorFechaProvider = Provider<ObtenerVentasPorFecha>((ref) {
  return ObtenerVentasPorFecha(ref.watch(ventasRepositoryProvider));
});

final buscarPorCodigoProvider = Provider<BuscarVentaPorCodigo>((ref) {
  return BuscarVentaPorCodigo(ref.watch(ventasRepositoryProvider));
});

final buscarPorTelefonoProvider = Provider<BuscarVentaPorTelefono>((ref) {
  return BuscarVentaPorTelefono(ref.watch(ventasRepositoryProvider));
});

final cambiarEstadoVentaProvider = Provider<CambiarEstadoVenta>((ref) {
  return CambiarEstadoVenta(ref.watch(ventasRepositoryProvider));
});

final obtenerVentaPorIdProvider = Provider<ObtenerVentaPorId>((ref) {
  return ObtenerVentaPorId(ref.watch(ventasRepositoryProvider));
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
  final CambiarEstadoVenta _cambiarEstado;
  final ObtenerVentaPorId _obtenerPorId;

  VentasNotifier({
    required RegistrarVenta registrar,
    required ObtenerVentasPorFecha obtenerPorFecha,
    required BuscarVentaPorCodigo buscarPorCodigo,
    required BuscarVentaPorTelefono buscarPorTelefono,
    required CambiarEstadoVenta cambiarEstado,
    required ObtenerVentaPorId obtenerPorId,
  })  : _registrar = registrar,
        _obtenerPorFecha = obtenerPorFecha,
        _buscarPorCodigo = buscarPorCodigo,
        _buscarPorTelefono = buscarPorTelefono,
        _cambiarEstado = cambiarEstado,
        _obtenerPorId = obtenerPorId,
        super(const VentasState());

  Future<void> obtenerVentaPorId(String ventaId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _obtenerPorId(ventaId);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (venta) => state = state.copyWith(isLoading: false, ventaSeleccionada: venta),
    );
  }

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
      (venta) {
        final list = venta != null ? [venta] : <Venta>[];
        state = state.copyWith(isLoading: false, ventas: list);
      },
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

  Future<void> buscarVentas({
    required String empresaId,
    String? codigo,
    String? telefono,
    String? nombre,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<Venta> resultados = [];

      if (codigo != null && codigo.isNotEmpty) {
        final result = await _buscarPorCodigo(BuscarVentaPorCodigoParams(empresaId: empresaId, codigo: codigo));
        result.fold(
          (failure) => state = state.copyWith(isLoading: false, error: 'Error al buscar por código: ${failure.message}'),
          (venta) {
            if (venta != null) resultados.add(venta);
          },
        );
        if (state.error != null) return;
      } else if (telefono != null && telefono.isNotEmpty) {
        final result = await _buscarPorTelefono(BuscarVentaPorTelefonoParams(empresaId: empresaId, telefono: telefono));
        result.fold(
          (failure) => state = state.copyWith(isLoading: false, error: 'Error al buscar por teléfono: ${failure.message}'),
          (ventas) => resultados = ventas,
        );
        if (state.error != null) return;
      } else {
        // Buscar por rango de fechas
        final inicio = fechaInicio ?? DateTime.now();
        final fin = fechaFin ?? inicio;
        for (var d = inicio; !d.isAfter(fin); d = d.add(const Duration(days: 1))) {
          final result = await _obtenerPorFecha(ObtenerVentasParams(empresaId: empresaId, fecha: d));
          result.fold(
            (failure) => {},
            (ventas) => resultados.addAll(ventas),
          );
        }
      }

      // Filtrar por nombre localmente si se especificó
      if (nombre != null && nombre.isNotEmpty) {
        resultados = resultados.where((v) =>
          v.clienteNombre?.toLowerCase().contains(nombre.toLowerCase()) ?? false
        ).toList();
      }

      state = state.copyWith(isLoading: false, ventas: resultados);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> cambiarEstado(String ventaId, String nuevoEstado) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _cambiarEstado(CambiarEstadoParams(ventaId: ventaId, nuevoEstado: nuevoEstado));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        // Actualizar la venta en la lista local
        final updatedVentas = state.ventas.map((v) {
          if (v.id == ventaId) {
            return Venta(
              id: v.id,
              empresaId: v.empresaId,
              usuarioId: v.usuarioId,
              clienteId: v.clienteId,
              codigoYape: v.codigoYape,
              monto: v.monto,
              clienteNombre: v.clienteNombre,
              clienteTelefono: v.clienteTelefono,
              fechaYape: v.fechaYape,
              descripcion: v.descripcion,
              estado: nuevoEstado,
              imagenYapeUrl: v.imagenYapeUrl,
              imagenEntregaUrl: v.imagenEntregaUrl,
              createdAt: v.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return v;
        }).toList();
        state = state.copyWith(isLoading: false, ventas: updatedVentas);
      },
    );
  }

  void resetError() {
    state = state.copyWith(error: null);
  }
}
