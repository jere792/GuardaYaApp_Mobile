# Problemática que Resuelve GuardaYa

## El Problema

### Contexto: El Comercio Informal en Perú y Latinoamérica

En Perú, **más del 70% de las transacciones comerciales** ocurren en el sector informal (bodegas, mercados, vendedores ambulantes, pequeños negocios). Estos negocios:

- **No emiten facturas** ni usan sistemas de facturación electrónica
- **Reciben pagos digitales** (Yape, Plin, transferencias bancarias) a través de comprobantes de captura de pantalla
- **No tienen control** de sus ventas, inventario ni clientes
- **Operan 100% en papel o memoria**

### Problemas Específicos

#### 1. Caos de Comprobantes Digitales
Los negocios reciben cientos de capturas de pantalla de Yape/Plin al día:
- Las imágenes se pierden en el teléfono
- No hay forma de verificar si un comprobante ya fue usado (duplicados)
- No se sabe cuánto se vendió en el día
- No hay respaldo si se borra el chat

#### 2. Sin Control de Inventario
- No saben qué productos se venden más
- No saben cuándo reordenar stock
- No pueden calcular ganancias reales
- Inventario se hace "a ojo"

#### 3. Sin Historial de Clientes
- No saben quién compra más
- No pueden ofrecer promociones
- No pueden hacer seguimiento de deudas
- Un cliente que compra frecuentemente es invisible

#### 4. Dependencia del Teléfono del Dueño
- Si el dueño está ausente, nadie sabe los precios
- Si el teléfono se rompe, se pierde toda la información
- No hay múltiples usuarios (empleados)

#### 5. Zonas con Mala Internet
Muchos mercados y zonas populares tienen conectividad intermitente:
- Las apps web tradicionales no funcionan sin internet
- Las apps de escritorio requieren computadora (que no tienen)
- Las apps de facturación electrónica son ilegalmente complejas para negocios informales

---

## La Solución: GuardaYa

### Propuesta de Valor

**"GuardaYa es como un cajero inteligente en tu celular, que lee comprobantes Yape/Plin automáticamente y organiza tus ventas sin internet."**

### Cómo Resuelve Cada Problema

#### 1. OCR Automático de Comprobantes
- **Antes**: Captura de pantalla se pierde en WhatsApp
- **Después**: La app lee el comprobante con OCR, extrae código, monto, fecha y los guarda automáticamente

#### 2. Modo Offline (Sin Internet)
- **Antes**: App web no carga sin WiFi
- **Después**: Funciona sin internet, sincroniza cuando hay conexión
- Ideal para mercados y zonas con mala señal

#### 3. Multi-Usuario (Dueño + Empleados)
- **Antes**: Solo el dueño tiene el control
- **Después**: El dueño crea empleados, cada uno registra sus ventas desde su propio celular

#### 4. Control de Ventas y Productos
- **Antes**: Ventas en papel o memoria
- **Después**: Historial de ventas, filtros por fecha, búsqueda por código OCR
- Sabe cuánto se vendió hoy, ayer, esta semana

#### 5. SaaS Multi-Empresa
- **Antes**: Cada negocio usa Excel diferente
- **Después**: Un sistema centralizado, cada negocio tiene su cuenta, precios, colores y productos
- Un solo admin puede gestionar múltiples negocios

---

## Diferenciadores vs Competencia

| Característica | GuardaYa | Excel/WhatsApp | App Facturación | App Ventas Genérica |
|---------------|----------|----------------|-----------------|---------------------|
| **OCR Yape/Plin** | ✅ Automático | ❌ Manual | ❌ No aplica | ❌ No tiene |
| **Modo Offline** | ✅ Nativo | ❌ Necesita archivo | ❌ Online | ❌ Parcial |
| **Multi-Usuario** | ✅ Roles | ❌ Solo dueño | ✅ Pero complejo | ✅ Pero caro |
| **Para Informal** | ✅ Diseñado para bodegas | ✅ Usado | ❌ Para PYME formal | ❌ Genérica |
| **Sin Email** | ✅ Username solo | ❌ No tiene | ❌ Email obligatorio | ❌ Email obligatorio |
| **Precio** | ✅ Freemium | ✅ Gratis | ❌ Caro | ❌ Suscripción |
| **OCR Local** | ✅ Sin subir a internet | ❌ N/A | ❌ N/A | ❌ N/A |
| **Sin JWT** | ✅ Sesión simple | ✅ N/A | ❌ Tokens complejos | ❌ Tokens complejos |

---

## Casos de Uso

### Caso 1: Bodega de Barrio
**Doña María** tiene una bodega. Recibe Yapes de sus vecinos.
- Antes: Anotaba en un cuaderno. Se perdían los comprobantes.
- Ahora: Abre GuardaYa, toma foto al comprobante, la app lee el código y monto. Listo.

### Caso 2: Tienda de Ropa (Online/Instagram)
**Carlos** vende ropa por Instagram. Recibe Plin.
- Antes: Capturas de pantalla en WhatsApp. No sabía cuánto vendió.
- Ahora: Cada venta se registra con OCR. Ve su dashboard al final del día.

### Caso 3: Vendedor Ambulante
**Pedro** tiene un carrito de comida. No tiene internet fijo.
- Antes: Ventas en memoria. Si olvidaba, perdía la plata.
- Ahora: Usa GuardaYa en modo offline. Sincroniza cuando llega a casa.

### Caso 4: Cadena de 3 Bodegas
**Los hermanos García** tienen 3 bodegas.
- Antes: Cada bodega usaba un método diferente. No sabían cuánto vendían en total.
- Ahora: Super admin ve las 3 empresas. Cada bodega tiene su empleado. Todo unificado.

---

## Métricas de Éxito

| Métrica | Objetivo |
|---------|----------|
| Tiempo de registro de venta | < 30 segundos (vs 5 minutos en Excel) |
| Reducción de pérdida de comprobantes | 100% (cada comprobante queda digitalizado) |
| Disponibilidad sin internet | 100% (modo offline) |
| Tiempo de setup | < 5 minutos (vs días en sistemas de facturación) |

---

## Conclusión

GuardaYa no es un sistema de facturación. Es un **cajero digital para el comercio informal** que:
- Entiende que los comprobantes son capturas de pantalla
- Funciona sin internet
- No requiere correo electrónico
- Es tan simple como tomar una foto
- Pero tan potente como un sistema de gestión

**El problema real no es "no tener facturas", es "no tener control de las ventas que ya se hacen".**
