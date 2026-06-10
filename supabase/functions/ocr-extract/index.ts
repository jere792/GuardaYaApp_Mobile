// Edge Function: ocr-extract
// Descripcion: Procesa imagenes de comprobantes Yape/Plin usando OCR
// Endpoint: POST /functions/v1/ocr-extract
// Body: { "image_url": "https://..." }

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

// Tesseract.js para OCR serverless
import { createWorker } from "https://esm.sh/tesseract.js@4.1.1/dist/tesseract.esm.min.js";

interface OcrRequest {
  image_url: string;
}

interface OcrResponse {
  success: boolean;
  data?: {
    codigo: string | null;
    monto: number | null;
    fecha: string | null;
    hora: string | null;
    nombre_destinatario: string | null;
    texto_completo: string;
    confianza: number;
  };
  error?: string;
}

serve(async (req) => {
  // 1. Validar metodo
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ success: false, error: "Method not allowed" }),
      { status: 405, headers: { "Content-Type": "application/json" } }
    );
  }

  try {
    // 2. Parsear body
    const { image_url }: OcrRequest = await req.json();

    if (!image_url) {
      return new Response(
        JSON.stringify({ success: false, error: "image_url is required" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // 3. Descargar imagen
    const imageResponse = await fetch(image_url);
    if (!imageResponse.ok) {
      throw new Error(`Failed to download image: ${imageResponse.status}`);
    }

    const imageBuffer = await imageResponse.arrayBuffer();
    const imageBlob = new Blob([imageBuffer]);

    // 4. OCR con Tesseract.js
    const worker = await createWorker("spa"); // Spanish language
    const result = await worker.recognize(imageBlob);
    await worker.terminate();

    const fullText = result.data.text;

    // 5. Post-procesar con regex especificos para Yape/Plin Peru
    const extractedData = extractComprobanteData(fullText);

    // 6. Calcular confianza
    const confidence = calculateConfidence(extractedData);

    const response: OcrResponse = {
      success: true,
      data: {
        codigo: extractedData.codigo,
        monto: extractedData.monto,
        fecha: extractedData.fecha,
        hora: extractedData.hora,
        nombre_destinatario: extractedData.nombreDestinatario,
        texto_completo: fullText,
        confianza: confidence,
      },
    };

    return new Response(
      JSON.stringify(response),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("OCR Error:", error);
    
    const response: OcrResponse = {
      success: false,
      error: error instanceof Error ? error.message : "Unknown error",
    };

    return new Response(
      JSON.stringify(response),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});

// Funcion para extraer datos de comprobantes peruanos
function extractComprobanteData(text: string) {
  // Normalizar texto
  const normalizedText = text.toLowerCase().replace(/\s+/g, " ");

  // Regex para codigo de operacion (Yape/Plin)
  const codigoRegex = /(?:codigo de operacion|n[°o] operacion|operacion|nro\.?)[^\d]*(\d{6,10})/i;
  const codigoMatch = codigoRegex.exec(text);

  // Regex para monto (S/ 150.00)
  const montoRegex = /s\/?\s*\.?\s*(\d+[\.,]?\d{0,2})/i;
  const montoMatch = montoRegex.exec(text);

  // Regex para fecha (dd/mm/yyyy o dd-mm-yyyy)
  const fechaRegex = /(\d{1,2}[\/-]\d{1,2}[\/-]\d{4})/;
  const fechaMatch = fechaRegex.exec(text);

  // Regex para hora (HH:MM:SS)
  const horaRegex = /(\d{1,2}:\d{2}:\d{2})/;
  const horaMatch = horaRegex.exec(text);

  // Regex para nombre destinatario
  const nombreRegex = /(?:para|a|pago a|destinatario)[:\s]+([a-záéíóúñ\s]{2,50})/i;
  const nombreMatch = nombreRegex.exec(text);

  let monto: number | null = null;
  if (montoMatch) {
    const raw = montoMatch[1].replace(",", ".");
    monto = parseFloat(raw);
  }

  return {
    codigo: codigoMatch ? codigoMatch[1].trim() : null,
    monto: monto,
    fecha: fechaMatch ? fechaMatch[1].trim() : null,
    hora: horaMatch ? horaMatch[1].trim() : null,
    nombreDestinatario: nombreMatch ? nombreMatch[1].trim() : null,
  };
}

// Calcular nivel de confianza (0-1)
function calculateConfidence(data: ReturnType<typeof extractComprobanteData>): number {
  let score = 0;
  let total = 4; // codigo, monto, fecha, nombre

  if (data.codigo) score++;
  if (data.monto && data.monto > 0) score++;
  if (data.fecha) score++;
  if (data.nombreDestinatario) score++;

  return score / total;
}
