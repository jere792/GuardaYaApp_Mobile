# GuardaYaApp - Supabase Backend

Este directorio contiene todo el backend de GuardaYaApp (Edge Functions, migraciones, etc.)

## Estructura

```
supabase/
├── functions/          # Edge Functions
│   └── ocr-extract/    # OCR para comprobantes Yape/Plin
│       └── index.ts
└── migrations/         # SQL de la base de datos
```

## Despliegue

### 1. Instalar Supabase CLI
```bash
npm install -g supabase
```

### 2. Login
```bash
supabase login
```

### 3. Link al proyecto
```bash
supabase link --project-ref gfnfgmangzlhttytlgbg
```

### 4. Desplegar Edge Function
```bash
supabase functions deploy ocr-extract
```

## Variables de Entorno (Edge Functions)

Configurar en Supabase Dashboard > Settings > Edge Functions:
- `GOOGLE_VISION_API_KEY` (opcional, para OCR mejorado)

**Nota:** La `SUPABASE_SERVICE_ROLE_KEY` ya está disponible automáticamente en el entorno de las Edge Functions.
