# Sistema de Diseño UI (Design System)

## Filosofía de Diseño

GuardaYa usa un **sistema de diseño dual**:

| Contexto | Colores | Uso |
|----------|---------|-----|
| **Branding de Empresa** | `color_primario`, `color_secundario`, `color_acento` | Home, Dashboard, Ventas, Productos (vistas operativas) |
| **Neutrales de App** | `AppColors.primary` (naranja), grises, blancos | Login, Registro, Configuración, Perfil (vistas de sistema) |

**Regla de oro:** Las vistas de **sistema** (autenticación, configuración, perfil) usan colores neutrales de la app. Las vistas de **negocio** (dashboard, ventas, productos) usan colores de la empresa logueada.

---

## 1. Paleta de Colores

### 1.1 Colores Base de la App (Neutrales)

Estos colores se usan en **login, registro, configuración, error, éxito** — lugares donde no aplica branding de empresa.

| Token | Valor | Hex | Uso |
|-------|-------|-----|-----|
| `appPrimary` | Naranja | `#FF6B00` | Botones principales, acentos, indicadores |
| `appSecondary` | Gris oscuro | `#2D2D2D` | Textos, iconos, fondos de AppBar |
| `appAccent` | Cyan | `#00B4D8` | Links, badges, info |
| `background` | Gris claro | `#F8F9FA` | Fondo de pantallas |
| `surface` | Blanco | `#FFFFFF` | Cards, inputs, diálogos |
| `error` | Rojo | `#E63946` | Errores, validaciones, alertas |
| `success` | Verde | `#2A9D8F` | Éxito, completado, sync OK |
| `warning` | Amarillo | `#E9C46A` | Advertencias, pendiente |
| `textPrimary` | Negro suave | `#1A1A2E` | Títulos, textos principales |
| `textSecondary` | Gris medio | `#6C757D` | Subtítulos, hints, descripciones |
| `divider` | Gris claro | `#DEE2E6` | Separadores, líneas |

### 1.2 Colores de Branding por Empresa

Cada empresa define sus colores en `public.empresas`:

| Campo DB | Token | Default | Uso |
|----------|-------|---------|-----|
| `color_primario` | `brandPrimary` | `#FF6B00` | Botones principales, header, acentos |
| `color_secundario` | `brandSecondary` | `#2D2D2D` | AppBar, textos, iconos |
| `color_acento` | `brandAccent` | `#00B4D8` | Links, badges, highlights |

### 1.3 Colores de Estado (Funcionales)

| Estado | Color | Ejemplo |
|--------|-------|---------|
| `pendiente` | `warning` `#E9C46A` | Venta aún no procesada |
| `completado` | `success` `#2A9D8F` | Venta finalizada |
| `cancelado` | `error` `#E63946` | Venta anulada |
| `reembolsado` | `textSecondary` `#6C757D` | Dinero devuelto |
| `sync_pendiente` | `warning` `#E9C46A` | Venta guardada offline |
| `sync_completado` | `success` `#2A9D8F` | Venta sincronizada |
| `sync_fallido` | `error` `#E63946` | Error al sincronizar |

### 1.4 Colores de Fondo (Dark / Light)

| Modo | Fondo | Superficie | Elevación |
|------|-------|------------|-----------|
| **Light** | `#F8F9FA` | `#FFFFFF` | Sombra ligera |
| **Dark** | `#121212` | `#1E1E1E` | Elevación +2% blanco |

---

## 2. Tipografía

### 2.1 Familia

| Plataforma | Fuente |
|------------|--------|
| Android / iOS | `Roboto` (default Flutter) |
| iOS alternativa | `SF Pro` (si se personaliza) |

### 2.2 Escalas

| Token | Tamaño | Peso | Uso | Line Height |
|-------|--------|------|-----|-------------|
| `displayLarge` | 28px | Bold (700) | Títulos de pantalla | 1.2 |
| `displayMedium` | 24px | Bold (700) | Títulos de sección | 1.2 |
| `displaySmall` | 20px | SemiBold (600) | Cards headers | 1.3 |
| `headlineMedium` | 18px | SemiBold (600) | Títulos de listas | 1.3 |
| `titleLarge` | 16px | Medium (500) | Nombres, productos | 1.4 |
| `bodyLarge` | 16px | Regular (400) | Texto principal | 1.5 |
| `bodyMedium` | 14px | Regular (400) | Descripciones, hints | 1.5 |
| `bodySmall` | 12px | Regular (400) | Fechas, metadata | 1.4 |
| `labelLarge` | 14px | Medium (500) | Botones, labels | 1.2 |
| `labelSmall` | 11px | Medium (500) | Badges, tags | 1.0 |

### 2.3 Colores de Texto por Contexto

| Contexto | Color Light | Color Dark |
|----------|-------------|------------|
| Título | `textPrimary` | `#FFFFFF` |
| Subtítulo | `textSecondary` | `#B0B0B0` |
| Hint / Placeholder | `textSecondary` 60% | `#B0B0B0` 60% |
| Link | `appAccent` | `appAccent` |
| Error | `error` | `error` |
| Precio / Monto | `appPrimary` | `appPrimary` |

---

## 3. Espaciado (Spacing System)

### 3.1 Base: 4px

Todo el espaciado es múltiplo de 4px:

| Token | Valor | Uso |
|-------|-------|-----|
| `space1` | 4px | Íconos pequeños, gaps mínimos |
| `space2` | 8px | Padding interno de badges, íconos |
| `space3` | 12px | Separación entre elementos compactos |
| `space4` | 16px | Padding estándar de cards, inputs |
| `space5` | 20px | Padding de pantalla, separación media |
| `space6` | 24px | Padding de cards grandes, secciones |
| `space7` | 32px | Separación entre secciones |
| `space8` | 48px | Separación grande, header-body |
| `space9` | 64px | Espaciado entre bloques principales |

### 3.2 Padding por Componente

| Componente | Padding |
|------------|---------|
| **Card** | `space4` (16px) horizontal, `space4` vertical |
| **Card compacta** | `space3` (12px) |
| **Input** | `space4` horizontal, `space3` vertical |
| **Button** | `space5` (20px) horizontal, `space3` (12px) vertical |
| **Screen** | `space5` (20px) horizontal |
| **List item** | `space4` (16px) vertical, `space5` horizontal |
| **Dialog** | `space6` (24px) |
| **Bottom sheet** | `space5` (20px) horizontal, `space6` (24px) top |

### 3.3 Espaciado entre Elementos

| Relación | Valor |
|----------|-------|
| Título → Subtítulo | `space2` (8px) |
| Subtítulo → Contenido | `space4` (16px) |
| Card → Card | `space3` (12px) |
| Input → Input | `space4` (16px) |
| Button → Button | `space3` (12px) |
| Sección → Sección | `space7` (32px) |
| Icono → Texto | `space2` (8px) |
| Avatar → Nombre | `space3` (12px) |

---

## 4. Bordes y Radios

### 4.1 Radio de Esquinas (Border Radius)

| Token | Valor | Uso |
|-------|-------|-----|
| `radiusNone` | 0px | Tablas, dividers |
| `radiusSmall` | 4px | Badges, chips, tags |
| `radiusMedium` | 8px | Inputs, botones pequeños |
| `radiusLarge` | 12px | Cards, diálogos, modales |
| `radiusXLarge` | 16px | Cards destacadas, hero sections |
| `radiusCircular` | 50% | Avatares, iconos redondos, FAB |

### 4.2 Grosor de Bordes (Border Width)

| Token | Valor | Uso |
|-------|-------|-----|
| `borderNone` | 0px | Sin borde, solo sombra |
| `borderThin` | 1px | Dividers, separadores, cards outlined |
| `borderMedium` | 1.5px | Inputs inactivos, tabs inactivos |
| `borderThick` | 2px | Inputs focused, botones outlined pressed |
| `borderBold` | 3px | Indicadores de selección, sliders |

### 4.3 Colores de Borde

| Estado | Color | Ancho |
|--------|-------|-------|
| Default | `divider` | `borderThin` |
| Hover / Pressed | `textSecondary` 40% | `borderThin` |
| Focused | `appPrimary` | `borderThick` |
| Error | `error` | `borderThick` |
| Success | `success` | `borderThick` |
| Disabled | `divider` | `borderThin` |

---

## 5. Sombras y Elevación

### 5.1 Sombras (Box Shadow)

| Token | Sombra | Uso |
|-------|--------|-----|
| `shadowNone` | Sin sombra | Superficies planas |
| `shadowSmall` | `0px 1px 3px rgba(0,0,0,0.08)` | Cards pequeñas, badges |
| `shadowMedium` | `0px 2px 8px rgba(0,0,0,0.10)` | Cards estándar, botones |
| `shadowLarge` | `0px 4px 16px rgba(0,0,0,0.12)` | Cards destacadas, diálogos |
| `shadowXLarge` | `0px 8px 32px rgba(0,0,0,0.14)` | Modales, bottom sheets, FAB |
| `shadowPrimary` | `0px 4px 12px rgba(255,107,0,0.25)` | Botones primarios, CTA |

### 5.2 Elevación (Elevation)

| Nivel | Valor | Uso |
|-------|-------|-----|
| `elevation0` | 0dp | Fondo, superficies base |
| `elevation1` | 1dp | Cards, chips |
| `elevation2` | 2dp | Cards con hover, botones |
| `elevation4` | 4dp | FAB, speed dial |
| `elevation8` | 8dp | Diálogos, bottom sheets |
| `elevation16` | 16dp | Modales, drawers |

---

## 6. Dimensiones de Componentes

### 6.1 Anchos Fijos

| Token | Valor | Uso |
|-------|-------|-----|
| `widthFull` | 100% | Botones full-width, inputs |
| `widthButton` | 200px | Botones estándar |
| `widthButtonSmall` | 120px | Botones compactos |
| `widthButtonLarge` | 280px | Botones CTA |
| `widthCard` | 100% | Cards (ocupan todo) |
| `widthCardSmall` | 160px | Cards de producto (grid) |
| `widthAvatar` | 40px | Avatar estándar |
| `widthAvatarLarge` | 64px | Avatar de perfil |
| `widthIcon` | 24px | Icono estándar |
| `widthIconLarge` | 32px | Icono de acción |
| `widthIconSmall` | 16px | Icono de badge, chip |

### 6.2 Altos Fijos

| Token | Valor | Uso |
|-------|-------|-----|
| `heightButton` | 48px | Botón estándar |
| `heightButtonSmall` | 36px | Botón compacto |
| `heightButtonLarge` | 56px | Botón CTA |
| `heightInput` | 48px | Input estándar |
| `heightListItem` | 72px | Item de lista (con avatar) |
| `heightListItemCompact` | 56px | Item de lista (sin avatar) |
| `heightAppBar` | 56px | AppBar móvil |
| `heightBottomBar` | 64px | Bottom navigation bar |
| `heightChip` | 32px | Chip, tag, badge |
| `heightCardSmall` | 100px | Card compacta |
| `heightCardMedium` | 160px | Card media (con imagen) |
| `heightCardLarge` | 240px | Card grande (hero) |

### 6.3 Tamaños de Touch Target

| Componente | Mínimo | Óptimo |
|------------|--------|--------|
| Botón | 44px | 48px |
| Icono (tap) | 44px | 48px |
| Checkbox | 44px | 44px |
| Input | 48px | 48px |
| List item | 56px | 72px |
| Card (tap) | 100px | 160px |

---

## 7. Componentes Reutilizables

### 7.1 Botones

**Primary Button (CTA)**
```
- Fondo: brandPrimary / appPrimary
- Texto: white
- Padding: space5 horizontal, space3 vertical
- Radius: radiusMedium
- Altura: heightButton
- Sombra: shadowPrimary
- Font: labelLarge, weight 500
- Disabled: background 30% opacity
```

**Secondary Button (Outlined)**
```
- Fondo: transparent
- Borde: borderThick, brandPrimary / appPrimary
- Texto: brandPrimary / appPrimary
- Padding: space5 horizontal, space3 vertical
- Radius: radiusMedium
- Altura: heightButton
- Pressed: fondo 10% opacity
```

**Text Button (Link)**
```
- Fondo: transparent
- Texto: appAccent / brandAccent
- Padding: space3 horizontal
- Underline: none (underline en hover)
- Font: labelLarge
```

### 7.2 Cards

**Card Estándar**
```
- Fondo: surface
- Padding: space4
- Radius: radiusLarge
- Sombra: shadowMedium
- Border: borderThin, divider (opcional)
```

**Card Destacada (Featured)**
```
- Fondo: surface
- Padding: space6
- Radius: radiusXLarge
- Sombra: shadowLarge
- Border: borderThick, brandPrimary (top o left)
```

**Card Compacta (Grid)**
```
- Fondo: surface
- Padding: space3
- Radius: radiusLarge
- Sombra: shadowSmall
- Altura: heightCardSmall
```

### 7.3 Inputs

**Text Input**
```
- Fondo: surface
- Border: borderMedium, divider
- Focus: borderThick, brandPrimary / appPrimary
- Radius: radiusMedium
- Padding: space4 horizontal, space3 vertical
- Altura: heightInput
- Hint: textSecondary 60%
- Label: labelLarge, textSecondary
- Error: borderThick, error + icon
```

**Search Input**
```
- Igual que Text Input
- Prefix: icon search (widthIcon)
- Suffix: icon clear (si hay texto)
- Background: divider 30% opacity
- Border: none (solo en focus)
- Radius: radiusCircular (pill shape)
```

### 7.4 Badges / Chips

**Status Badge**
```
- Fondo: color del estado 10% opacity
- Texto: color del estado
- Padding: space2 horizontal, space1 vertical
- Radius: radiusSmall
- Font: labelSmall
```

**Tag Badge**
```
- Fondo: divider
- Texto: textSecondary
- Padding: space2 horizontal, space1 vertical
- Radius: radiusSmall
- Font: labelSmall
```

### 7.5 Avatares

**Avatar Estándar**
```
- Tamaño: widthAvatar
- Forma: radiusCircular
- Background: divider
- Icono: person, textSecondary
- Borde: borderThin, surface
```

**Avatar Grande (Perfil)**
```
- Tamaño: widthAvatarLarge
- Forma: radiusCircular
- Border: borderThick, surface
- Sombra: shadowMedium
```

### 7.6 Dividers

**Horizontal**
```
- Altura: 1px
- Color: divider
- Padding: space4 vertical
```

**Vertical**
```
- Ancho: 1px
- Color: divider
- Padding: space4 horizontal
```

---

## 8. Iconografía

### 8.1 Tamaños

| Token | Tamaño | Uso |
|-------|--------|-----|
| `iconSmall` | 16px | Badges, chips, inline |
| `iconMedium` | 24px | Botones, list items, inputs |
| `iconLarge` | 32px | Cards, header actions |
| `iconXLarge` | 48px | Empty states, onboarding |
| `iconHuge` | 64px | Hero, splash, logo |

### 8.2 Colores por Contexto

| Contexto | Color |
|----------|-------|
| Default | textSecondary |
| Primary | brandPrimary / appPrimary |
| Error | error |
| Success | success |
| Warning | warning |
| Info | appAccent |
| Disabled | divider |
| Inverse | white (sobre fondos oscuros) |

### 8.3 Estilo

- Material Icons (Outlined)
- Stroke: 2px (uniforme)
- Rellenos: solo para íconos de estado (success, error, warning)

---

## 9. Vistas Específicas

### 9.1 Login / Autenticación (Neutro — No aplica Branding)

```
- Fondo: gradiente [background → surface]
- Logo: appPrimary
- Inputs: surface, borderThick en focus (appPrimary)
- Botón: appPrimary, shadowPrimary
- Links: appAccent
- Texto: textPrimary
- Footer: textSecondary
- No aplica color_primario de empresa
```

**Razón:** El login es anterior a la selección de empresa. El usuario aún no ha iniciado sesión, por lo tanto no conocemos su empresa.

### 9.2 Home / Dashboard (Aplica Branding)

```
- Fondo: background
- AppBar: brandPrimary
- Cards: surface, shadowMedium
- Botón flotante (FAB): brandPrimary
- Indicadores: brandAccent
- Stats: brandPrimary
- Texto: textPrimary
- Sí aplica color_primario de empresa
```

### 9.3 Registrar Venta (Aplica Branding)

```
- AppBar: brandPrimary
- Steps: brandPrimary (active), textSecondary (inactive)
- Inputs: surface, borderThick en focus (brandPrimary)
- Botón CTA: brandPrimary, shadowPrimary
- Cámara: brandPrimary icon
- Total: brandPrimary, bold
- Sí aplica color_primario de empresa
```

### 9.4 Perfil (Aplica Branding)

```
- Header: brandPrimary (con degradado)
- Card de datos: surface
- Inputs: surface, borderThick en focus (brandPrimary)
- Botón guardar: brandPrimary
- Botón cerrar sesión: error
- Sí aplica color_primario de empresa
```

### 9.5 Configuración (Aplica Branding)

```
- Fondo: background
- AppBar: brandPrimary
- Cards: surface
- Switches: brandPrimary
- Botones: brandPrimary
- Sí aplica color_primario de empresa
```

### 9.6 Modo Offline

```
- Banner: warning 10% background, warning border
- Icono: warning
- Texto: textPrimary
- Sin branding especial
```

### 9.7 Listar Ventas / Buscar / Detalle (Aplica Branding)

```
- AppBar: brandPrimary
- Cards: surface, borderThick left (brandPrimary)
- Botón filtrar: brandPrimary
- Estado pendiente: warning
- Estado completado: success
- Sí aplica color_primario de empresa
```

### 9.8 Productos / Clientes / Empleados (Aplica Branding)

```
- AppBar: brandPrimary
- FAB: brandPrimary
- Cards: surface, shadowMedium
- Botón crear: brandPrimary
- Sí aplica color_primario de empresa
```

---

## 10. Animaciones

### 10.1 Duraciones

| Token | Valor | Uso |
|-------|-------|-----|
| `durationFast` | 150ms | Hover, micro-interacciones |
| `durationNormal` | 300ms | Transiciones, cambios de estado |
| `durationSlow` | 500ms | Page transitions, modales |
| `durationSnappy` | 100ms | Ripples, botones |

### 10.2 Curvas

| Token | Curva | Uso |
|-------|-------|-----|
| `easeDefault` | `easeInOut` | Transiciones generales |
| `easeEnter` | `easeOut` | Elementos entrando |
| `easeExit` | `easeIn` | Elementos saliendo |
| `easeBounce` | `easeOutBack` | Notificaciones, toasts |

### 10.3 Transiciones Comunes

| Transición | Duración | Curva |
|------------|----------|-------|
| Cambio de página | `durationSlow` | `easeDefault` |
| Apertura de modal | `durationNormal` | `easeEnter` |
| Cierre de modal | `durationNormal` | `easeExit` |
| Aparecer card | `durationNormal` | `easeEnter` |
| Hover botón | `durationFast` | `easeDefault` |
| Ripple | `durationSnappy` | `easeDefault` |
| Toast | `durationNormal` | `easeBounce` |
| Skeleton | `durationSlow` | `easeDefault` (loop) |

---

## 11. Tokens Resumen (Quick Reference)

### Colores
```
appPrimary: #FF6B00
appSecondary: #2D2D2D
appAccent: #00B4D8
background: #F8F9FA
surface: #FFFFFF
error: #E63946
success: #2A9D8F
warning: #E9C46A
textPrimary: #1A1A2E
textSecondary: #6C757D
divider: #DEE2E6
```

### Espaciado
```
space1: 4px, space2: 8px, space3: 12px, space4: 16px
space5: 20px, space6: 24px, space7: 32px
space8: 48px, space9: 64px
```

### Bordes
```
radiusNone: 0px, radiusSmall: 4px, radiusMedium: 8px
radiusLarge: 12px, radiusXLarge: 16px, radiusCircular: 50%

borderNone: 0px, borderThin: 1px, borderMedium: 1.5px
borderThick: 2px, borderBold: 3px
```

### Sombras
```
shadowSmall: 0px 1px 3px rgba(0,0,0,0.08)
shadowMedium: 0px 2px 8px rgba(0,0,0,0.10)
shadowLarge: 0px 4px 16px rgba(0,0,0,0.12)
shadowXLarge: 0px 8px 32px rgba(0,0,0,0.14)
shadowPrimary: 0px 4px 12px rgba(255,107,0,0.25)
```

### Dimensiones
```
heightButton: 48px, heightButtonSmall: 36px, heightButtonLarge: 56px
heightInput: 48px, heightListItem: 72px, heightChip: 32px
widthIcon: 24px, widthIconLarge: 32px, widthAvatar: 40px
```

---

## 12. Implementación en Flutter

### Uso de `EmpresaColors`

```dart
// En main.dart, cargar colores de empresa al iniciar sesión
final empresaColors = await SecureStorage.getEmpresaColors();
final theme = AppTheme.lightTheme(empresaColors: empresaColors);

// En vistas que NO aplican branding (login, config)
final neutralTheme = AppTheme.lightTheme(); // Sin empresaColors

// En vistas que SÍ aplican branding (dashboard, ventas)
final brandTheme = AppTheme.lightTheme(empresaColors: empresaColors);
```

### Uso de Tokens

```dart
// Colores
Color primary = AppColors.primary;
// o
Color primary = empresaColors?.primary ?? AppColors.primary;

// Espaciado
const padding = EdgeInsets.all(16); // space4
const gap = SizedBox(height: 12); // space3

// Sombras
BoxShadow cardShadow = AppShadows.medium;

// Bordes
BorderRadius cardRadius = AppRadius.large;
```

---

## 13. Reglas de Consistencia

1. **Siempre usar tokens**, nunca valores hardcodeados
2. **Login y autenticación** = colores neutrales (`AppColors`)
3. **Todo el resto de la app** = colores de empresa (`EmpresaColors`)
4. **Espaciado** = múltiplos de 4px
5. **Bordes** = radios consistentes por tipo de componente
6. **Sombras** = usar `shadowMedium` para cards, no inventar nuevas
7. **Texto** = usar `textPrimary` para títulos, `textSecondary` para hints
8. **Estados** = usar colores semánticos (error, success, warning)
9. **Touch targets** = mínimo 44px
10. **Animaciones** = usar `durationNormal` (300ms) por defecto

---

## 14. Notas de Diseño

### Regla Simple: Dos Modos

| Modo | Vistas | Colores |
|------|--------|---------|
| **Neutro** | Login, Registro, Recuperar Password | `AppColors` (naranja `#FF6B00`) |
| **Branding** | Home, Dashboard, Ventas, Productos, Clientes, Perfil, Configuración, Reportes | `EmpresaColors` (de la DB) |

### Por qué Login es Neutro

El login **no puede** usar colores de empresa porque:
- El usuario aún no ha iniciado sesión
- No sabemos qué empresa es hasta después del login
- Usar branding de empresa requeriría un login previo, lo cual es imposible
- Los colores neutrales (`AppColors`) crean identidad de la propia app

### Por qué Todo lo Demás usa Branding

Una vez que el usuario inicia sesión:
- La empresa ya está identificada
- El dueño quiere ver su marca en toda la app
- Crea sentido de pertenencia y profesionalismo
- Unifica la experiencia visual del negocio

### No hay Casos Mixtos

Para simplificar el diseño y evitar confusiones:
- **Autenticación** = 100% neutro
- **Todo lo demás** = 100% branding de empresa
- No hay vistas parcialmente branding, parcialmente neutra

Esta regla hace que el sistema sea:
- **Simple** de entender para desarrolladores
- **Consistente** para usuarios
- **Fácil** de mantener

---

**Documento mantenido por el equipo de diseño de GuardaYa.**
**Última actualización:** 2026-06-13
