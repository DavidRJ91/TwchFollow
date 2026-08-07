"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { exchangeCode, saveToken, CLIENT_ID } from "@/lib/twitch-auth";

export default function CallbackPage() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const params = new URLSearchParams(window.location.search);
        const code = params.get("code");
        const err = params.get("error");
        if (err) throw new Error(`Twitch denegó el acceso: ${err}`);
        if (!code) throw new Error("No se recibió el código de autorización.");
        if (!CLIENT_ID) throw new Error("Falta NEXT_PUBLIC_TWITCH_CLIENT_ID en el build.");
        const token = await exchangeCode(code);
        saveToken(token);
        router.replace("/");
      } catch (e) {
        setError(e instanceof Error ? e.message : "Error al conectar");
      }
    })();
  }, [router]);

  if (error) {
    return (
      <div className="mx-auto max-w-md space-y-4 py-10 text-center">
        <p className="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-300">{error}</p>
        <a href="/login" className="text-sm text-twitch hover:underline">Volver a intentarlo</a>
      </div>
    );
  }

  return <p className="py-16 text-center text-zinc-500">Conectando con Twitch…</p>;
}
