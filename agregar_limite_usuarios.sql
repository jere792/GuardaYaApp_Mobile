ALTER TABLE public.empresas
ADD COLUMN IF NOT EXISTS limite_usuarios integer NOT NULL DEFAULT 0;
