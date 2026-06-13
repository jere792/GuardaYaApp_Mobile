# GuardaYa - Documentación del Proyecto

## Visión General

**GuardaYa** es una aplicación móvil de gestión de ventas para pequeños y medianos negocios, con énfasis en comprobantes de pago digital (Yape/Plin) mediante **OCR (Reconocimiento Óptico de Caracteres)**.

El proyecto sigue una arquitectura **Clean Architecture** con **Domain-Driven Design (DDD)** y está desarrollado en **Flutter**.

## Índice

- [Arquitectura](./arquitectura.md) - Clean Architecture y capas del proyecto
- [Autenticación](./autenticacion.md) - Sistema de login con bcrypt (sin Supabase Auth)
- [Base de Datos](./database.md) - Estructura de Supabase y esquema SQL
- [Despliegue](./deployment.md) - Guía paso a paso para deploy
- [Diseño UI](./design_system.md) - Sistema de diseño, colores, espaciado, tokens
- [Estructura del Proyecto](./estructura.md) - Organización de carpetas y archivos
- [Enfoque](./enfoque.md) - Visión y principios del proyecto
- [Problemática](./problematica.md) - Problemas que resuelve GuardaYa
- [Roadmap](./roadmap.md) - Estado actual y plan de desarrollo
- [Supabase Functions](./supabase_functions.md) - Funciones RPC, RLS y acceso a datos
- [Versiones](./versiones.md) - Versiones de dependencias y tecnologías

## Tecnologías Principales

| Tecnología | Uso |
|-----------|-----|
| **Flutter** | Framework UI multiplataforma |
| **Dart** | Lenguaje de programación |
| **Supabase** | Backend as a Service (PostgreSQL + Edge Functions) |
| **PostgreSQL** | Base de datos principal |
| **bcrypt** | Hashing de contraseñas |
| **Riverpod** | State management |
| **Go Router** | Navegación |
| **Google ML Kit** | OCR para comprobantes |
| **SQFlite** | Base de datos local (offline) |

## Características Principales

- **Gestión de Ventas**: Registro, seguimiento y reporte de ventas
- **OCR Inteligente**: Lectura automática de comprobantes Yape/Plin
- **Modo Offline**: Funciona sin conexión a internet con sincronización posterior
- **Multi-empresa**: Soporte para múltiples negocios/empresas
- **Roles y Permisos**: super_admin, admin, empleado
- **Sincronización en Segundo Plano**: Usando WorkManager

## Filosofía del Proyecto

### Control Total sobre la Autenticación
A diferencia de la implementación tradicional con Supabase Auth, GuardaYa usa:
- **bcrypt** en PostgreSQL para hashing de contraseñas
- **Tabla propia** (`public.usuarios`) como fuente de verdad
- **Sin dependencia de JWT** ni sesiones de Supabase Auth
- **Edge Functions** para validación de login

### Offline-First
La app está diseñada para funcionar en zonas con conectividad limitada:
- SQLite local para ventas pendientes
- Sincronización automática cuando hay internet
- Caché de datos de usuario en almacenamiento seguro

## Estado Actual

- ✅ Login con bcrypt implementado
- ✅ Creación de usuarios con roles (super_admin, admin, empleado)
- ✅ Edge Function `login-custom` desplegada
- ✅ Modo offline funcional
- 🔄 OCR en desarrollo

## Contacto y Desarrollo

Proyecto en desarrollo activo por **Jeremy Yazid**.
