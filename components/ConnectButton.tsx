"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { clearToken, getToken, startLogin } from "@/lib/twitch-auth";

export default function ConnectButton() {
  const [logged, setLogged] = useState(false);

  useEffect(() => setLogged(Boolean(getToken())), []);

  if (logged) {
    return (
      <div className="flex gap-2">
        <Link href="/search" className="rounded-lg bg-zinc-800 px-3 py-1.5 text-xs font-medium hover:bg-zinc-700">
          🔍 Buscar canal
        </Link>
        <button
          onClick={() => { clearToken(); setLogged(false); }}
          className="rounded-lg bg-zinc-800 px-3 py-1.5 text-xs font-medium text-zinc-400 hover:bg-zinc-700"
        >
          Desconectar
        </button>
      </div>
    );
  }

  return (
    <button
      onClick={startLogin}
      className="rounded-lg bg-twitch px-3 py-1.5 text-xs font-semibold text-white hover:bg-twitch-dark"
    >
      🔗 Conectar con Twitch
    </button>
  );
}
