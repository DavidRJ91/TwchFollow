"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import ConnectButton from "./ConnectButton";

const links = [
  { href: "/", label: "Dashboard", icon: "📊" },
  { href: "/search", label: "Buscar canal", icon: "🔍" },
  { href: "/unfollows", label: "Unfollows", icon: "📉" },
  { href: "/not-following-back", label: "No te siguen", icon: "🔁" },
  { href: "/fans", label: "Fans · Mutuos", icon: "🧠" },
  { href: "/growth", label: "Crecimiento", icon: "📈" },
];

export default function Sidebar() {
  const pathname = usePathname();
  return (
    <aside className="w-60 shrink-0 border-r border-zinc-800 bg-zinc-900/60 p-4 hidden md:flex flex-col gap-1 sticky top-0 h-screen">
      <div className="flex items-center gap-2 px-2 py-3 mb-4">
        <span className="text-2xl">🎮</span>
        <div>
          <p className="font-bold leading-tight">Twitch Follows</p>
          <p className="text-xs text-zinc-500">Analytics</p>
        </div>
      </div>
      {links.map((l) => {
        const active = pathname === l.href;
        return (
          <Link
            key={l.href}
            href={l.href}
            className={`flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition ${
              active ? "bg-twitch text-white font-semibold" : "text-zinc-400 hover:bg-zinc-800 hover:text-zinc-100"
            }`}
          >
            <span>{l.icon}</span>
            {l.label}
          </Link>
        );
      })}
      <div className="mt-4"><ConnectButton /></div>
      <div className="mt-auto rounded-lg border border-zinc-800 bg-zinc-900 p-3 text-xs text-zinc-500">
        Datos demo sin conectar · Conecta Twitch para datos reales.
      </div>
    </aside>
  );
}
