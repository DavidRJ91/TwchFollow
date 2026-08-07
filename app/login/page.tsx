"use client";

import { startLogin } from "@/lib/twitch-auth";

export default function LoginPage() {
  return (
    <div className="mx-auto max-w-md space-y-6 py-10 text-center">
      <span className="text-5xl">🎮</span>
      <h1 className="text-2xl font-bold">Conecta tu cuenta de Twitch</h1>
      <p className="text-sm text-zinc-500">
        Necesitamos tu token para consultar la API pública de Twitch desde tu navegador.
        Usamos OAuth PKCE: <strong>no hay secret</strong>, no guardamos tu contraseña,
        y el token se queda en tu dispositivo (localStorage).
      </p>
      <button
        onClick={startLogin}
        className="rounded-xl bg-twitch px-6 py-3 font-semibold text-white hover:bg-twitch-dark"
      >
        🔗 Conectar con Twitch
      </button>
      <p className="text-xs text-zinc-600">
        Al conectar se pedirá el scope <code>user:read:follows</code>.
      </p>
    </div>
  );
}
