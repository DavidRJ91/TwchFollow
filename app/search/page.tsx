"use client";

import { useEffect, useState } from "react";
import { fetchAllFollowers, searchUserByLogin, type FollowersResult, type TwitchApiUser } from "@/lib/twitch-client";
import { isLoggedIn } from "@/lib/twitch-auth";

interface SearchResult extends FollowersResult { channel: TwitchApiUser; }

export default function SearchPage() {
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<SearchResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loggedIn, setLoggedIn] = useState(false);
  const [checkedAuth, setCheckedAuth] = useState(false);

  useEffect(() => {
    setLoggedIn(isLoggedIn());
    setCheckedAuth(true);
  }, []);

  async function handleSearch(e: React.FormEvent) {
    e.preventDefault();
    if (!query.trim()) return;
    setLoading(true); setError(null); setResult(null);
    try {
      const channel = await searchUserByLogin(query.trim());
      if (!channel) { setError(`No se encontró el canal "${query.trim()}"`); return; }
      const followers = await fetchAllFollowers(channel.id);
      setResult({ ...followers, channel });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Error buscando el canal");
    } finally {
      setLoading(false);
    }
  }

  if (!checkedAuth) {
    return null;
  }

  if (!loggedIn) {
    return (
      <div className="space-y-6">
        <header>
          <h1 className="text-2xl font-bold">🔍 Buscar canal</h1>
          <p className="text-sm text-zinc-500">Mira quién sigue a cualquier canal de Twitch.</p>
        </header>
        <div className="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-8 text-center text-sm text-zinc-500">
          <p className="mb-3">Para consultar la API de Twitch primero tienes que conectar tu cuenta.</p>
          <a href="/login" className="rounded-xl bg-twitch px-5 py-2.5 font-semibold text-white hover:bg-twitch-dark">
            🔗 Conectar con Twitch
          </a>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-2xl font-bold">🔍 Buscar canal</h1>
        <p className="text-sm text-zinc-500">Quién sigue a cualquier canal · datos públicos de la API de Twitch.</p>
      </header>

      <form onSubmit={handleSearch} className="flex gap-2">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Ej: xqc, ibai, shroud..."
          className="flex-1 rounded-xl border border-zinc-800 bg-zinc-900 px-4 py-2.5 text-sm outline-none focus:border-twitch"
        />
        <button type="submit" disabled={loading || !query.trim()}
          className="rounded-xl bg-twitch px-5 py-2.5 text-sm font-semibold text-white hover:bg-twitch-dark disabled:opacity-50">
          {loading ? "Buscando…" : "Buscar"}
        </button>
      </form>

      {error && <p className="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-300">{error}</p>}

      {result && (
        <>
          <section className="flex items-center gap-4 rounded-2xl border border-zinc-800 bg-zinc-900/70 p-4">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={result.channel.profile_image_url} alt="" className="h-14 w-14 rounded-full bg-zinc-800" />
            <div>
              <p className="text-lg font-bold">{result.channel.display_name}</p>
              <p className="text-sm text-zinc-500">
                @{result.channel.login} · {result.total.toLocaleString("es-ES")} seguidores
                {result.truncated && " · mostrando los últimos 1000"}
              </p>
            </div>
          </section>

          <section className="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-4">
            <h2 className="mb-3 font-bold">Seguidores</h2>
            <div className="divide-y divide-zinc-800/60">
              {result.followers.map((f) => (
                <div key={f.userId} className="flex items-center gap-3 py-2">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={f.avatar} alt="" className="h-9 w-9 rounded-full bg-zinc-800" />
                  <div>
                    <p className="text-sm font-semibold">{f.displayName}</p>
                    <p className="text-xs text-zinc-500">@{f.login}</p>
                  </div>
                  <p className="ml-auto text-xs text-zinc-600">
                    Sigue desde {new Date(f.followedAt).toLocaleDateString("es-ES")}
                  </p>
                </div>
              ))}
            </div>
          </section>
        </>
      )}
    </div>
  );
}
