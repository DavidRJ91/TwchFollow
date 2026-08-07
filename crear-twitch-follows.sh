#!/usr/bin/env bash
# ============================================================
#  Genera el proyecto "Twitch Follows Analyzer" y lo empaqueta
#  Uso:  chmod +x crear-twitch-follows.sh && ./crear-twitch-follows.sh
# ============================================================
set -euo pipefail

DIR="twitch-follows"
rm -rf "$DIR"
mkdir -p "$DIR"/{app/{search,login,callback,unfollows,not-following-back,fans,growth},components,lib,.github/workflows}

echo "📁 Creando archivos base..."
cat <<'EOF' > "$DIR/package.json"
{
  "name": "twitch-follows",
  "version": "0.1.0",
  "private": true,
  "scripts": { "dev": "next dev", "build": "next build", "start": "next start" },
  "dependencies": {
    "next": "^14.2.5",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "recharts": "^2.12.7"
  },
  "devDependencies": {
    "@types/node": "^20.14.0",
    "@types/react": "^18.3.3",
    "@types/react-dom": "^18.3.0",
    "autoprefixer": "^10.4.19",
    "postcss": "^8.4.39",
    "tailwindcss": "^3.4.6",
    "typescript": "^5.5.3"
  }
}
EOF

cat <<'EOF' > "$DIR/tsconfig.json"
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

cat <<'EOF' > "$DIR/next.config.mjs"
const basePath = process.env.NEXT_PUBLIC_BASE_PATH || "";

/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "export",
  basePath,
  trailingSlash: true,
  images: { unoptimized: true },
};

export default nextConfig;
EOF

cat <<'EOF' > "$DIR/postcss.config.mjs"
export default {
  plugins: { tailwindcss: {}, autoprefixer: {} },
};
EOF

cat <<'EOF' > "$DIR/tailwind.config.ts"
import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        twitch: { DEFAULT: "#9146FF", dark: "#772CE8", darker: "#5C16C5" },
      },
    },
  },
  plugins: [],
};

export default config;
EOF

cat <<'EOF' > "$DIR/.env.local.example"
# Client ID de tu app en dev.twitch.tv (es público, NO es secreto)
NEXT_PUBLIC_TWITCH_CLIENT_ID=tu_client_id
# Base path del repo para GitHub Pages (en local déjalo vacío)
NEXT_PUBLIC_BASE_PATH=
EOF

cat <<'EOF' > "$DIR/.gitignore"
node_modules/
.next/
out/
*.log
.env.local
.env*.local
EOF

echo "📁 Creando lib/ (lógica)..."
cat <<'EOF' > "$DIR/lib/types.ts"
export interface TwitchUser {
  id: string;
  login: string;
  displayName: string;
  profileImageUrl: string;
}

export interface FollowRecord {
  userId: string;
  followedAt: string;
}

export interface Snapshot {
  id: string;
  takenAt: string;
  followers: FollowRecord[];
  following: FollowRecord[];
}

export interface DemoData {
  users: Record<string, TwitchUser>;
  snapshots: Snapshot[];
}

export interface UserWithFollowDate extends TwitchUser {
  followedAt?: string;
  iFollowSince?: string;
}
EOF

cat <<'EOF' > "$DIR/lib/demo-data.ts"
import type { DemoData, FollowRecord, Snapshot, TwitchUser } from "./types";

const DAY = 86_400_000;

function rng(seed: number) {
  return function () {
    seed |= 0;
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const NAME_BASES = [
  "Pixel", "Shadow", "Neon", "Crimson", "Luna", "Byte", "Echo", "Frost", "Grim", "Halo",
  "Ivy", "Jade", "Karma", "Lynx", "Mirage", "Nova", "Onyx", "Phoenix", "Quartz", "Raven",
  "Sable", "Titan", "Umbra", "Vega", "Wraith", "Xeno", "Yuki", "Zephyr", "Astra", "Blaze",
  "Cobalt", "Dusk", "Ember", "Flare", "Ghost", "Hazel", "Iron", "Jinx", "Krypton", "Lazer",
  "Myth", "Nyx", "Obsidian", "Prism", "Quantum", "Rogue", "Storm", "Terra", "Ultra", "Viper",
];

const NAME_SUFFIX = ["Queen", "Wolf", "Fox", "Gamer", "Dev", "TV", "Live", "King", "Cat", "Bot",
  "Rider", "Knight", "Slayer", "Ninja", "Dragon", "Raven", "Shark", "Panda", "Owl", "Ghost"];

export function generateDemoData(): DemoData {
  const rand = rng(42);
  const now = Date.now();
  const snapshotTimes = [now - 21 * DAY, now - 14 * DAY, now - 7 * DAY, now];

  const users: Record<string, TwitchUser> = {};
  const userList: Array<{ user: TwitchUser; followStart: number | null; followEnd: number | null; iFollow: number | null }> = [];

  for (let i = 0; i < 72; i++) {
    const base = NAME_BASES[Math.floor(rand() * NAME_BASES.length)];
    const suffix = NAME_SUFFIX[Math.floor(rand() * NAME_SUFFIX.length)];
    const num = Math.floor(rand() * 999);
    const displayName = `${base}${suffix}`;
    const login = displayName.toLowerCase() + (rand() > 0.5 ? num.toString() : "");

    users[login] = {
      id: `u${i}`,
      login,
      displayName,
      profileImageUrl: `https://i.pravatar.cc/100?u=${login}`,
    };

    let followStart: number | null = null;
    let followEnd: number | null = null;
    if (rand() < 0.62) {
      followStart = now - Math.floor(rand() * 160) * DAY - Math.floor(rand() * DAY);
      const stillFollowing = rand() < 0.68;
      if (!stillFollowing) {
        followEnd = followStart + Math.floor(10 + rand() * 120) * DAY;
        if (followEnd > now) followEnd = now - Math.floor(rand() * 2) * DAY;
      }
    }

    let iFollow: number | null = null;
    if (rand() < 0.55) {
      iFollow = now - Math.floor(rand() * 200) * DAY;
    }

    userList.push({ user: users[login], followStart, followEnd, iFollow });
  }

  const snapshots: Snapshot[] = snapshotTimes.map((t, idx) => {
    const followers: FollowRecord[] = [];
    const following: FollowRecord[] = [];
    for (const entry of userList) {
      const isFollower = entry.followStart !== null && entry.followStart <= t && (entry.followEnd === null || entry.followEnd > t);
      const isFollowing = entry.iFollow !== null && entry.iFollow <= t;
      if (isFollower) followers.push({ userId: entry.user.id, followedAt: new Date(entry.followStart!).toISOString() });
      if (isFollowing) following.push({ userId: entry.user.id, followedAt: new Date(entry.iFollow!).toISOString() });
    }
    followers.sort((a, b) => b.followedAt.localeCompare(a.followedAt));
    following.sort((a, b) => b.followedAt.localeCompare(a.followedAt));
    return { id: `snap-${idx}`, takenAt: new Date(t).toISOString(), followers, following };
  });

  return { users, snapshots };
}
EOF

cat <<'EOF' > "$DIR/lib/analytics.ts"
import type { DemoData, FollowRecord, Snapshot, TwitchUser, UserWithFollowDate } from "./types";

const DAY_MS = 86_400_000;

export function resolveUsers(data: DemoData, records: FollowRecord[]): UserWithFollowDate[] {
  return records
    .map((r) => {
      const user = data.users[r.userId];
      if (!user) return null;
      return { ...user, followedAt: r.followedAt };
    })
    .filter(Boolean) as UserWithFollowDate[];
}

export function getFollowersSnapshot(data: DemoData, snapshot: Snapshot): UserWithFollowDate[] {
  return resolveUsers(data, snapshot.followers);
}

export function getFollowingSnapshot(data: DemoData, snapshot: Snapshot): UserWithFollowDate[] {
  return resolveUsers(data, snapshot.following);
}

export function getUnfollowsBetween(prev: Snapshot, curr: Snapshot): FollowRecord[] {
  const currIds = new Set(curr.followers.map((f) => f.userId));
  return prev.followers.filter((f) => !currIds.has(f.userId));
}

export function getNewFollowersBetween(prev: Snapshot, curr: Snapshot): FollowRecord[] {
  const prevIds = new Set(prev.followers.map((f) => f.userId));
  return curr.followers.filter((f) => !prevIds.has(f.userId));
}

export function getNotFollowingBack(data: DemoData, snapshot: Snapshot): UserWithFollowDate[] {
  const followerIds = new Set(snapshot.followers.map((f) => f.userId));
  return resolveUsers(
    data,
    snapshot.following.filter((f) => !followerIds.has(f.userId))
  ).map((u) => ({ ...u, iFollowSince: u.followedAt, followedAt: undefined }));
}

export function getFans(data: DemoData, snapshot: Snapshot): UserWithFollowDate[] {
  const followingIds = new Set(snapshot.following.map((f) => f.userId));
  return resolveUsers(data, snapshot.followers.filter((f) => !followingIds.has(f.userId)));
}

export function getMutuals(data: DemoData, snapshot: Snapshot): UserWithFollowDate[] {
  const followingIds = new Set(snapshot.following.map((f) => f.userId));
  return resolveUsers(data, snapshot.followers.filter((f) => followingIds.has(f.userId)));
}

export interface GrowthPoint {
  date: string;
  label: string;
  followers: number;
  following: number;
}

export function getGrowthSeries(snapshots: Snapshot[]): GrowthPoint[] {
  return snapshots.map((s) => {
    const d = new Date(s.takenAt);
    return {
      date: s.takenAt,
      label: d.toLocaleDateString("es-ES", { day: "2-digit", month: "short" }),
      followers: s.followers.length,
      following: s.following.length,
    };
  });
}

export function getLatestSnapshot(data: DemoData): Snapshot {
  return data.snapshots[data.snapshots.length - 1];
}

export function getPreviousSnapshot(data: DemoData, snapshot: Snapshot): Snapshot | null {
  const idx = data.snapshots.findIndex((s) => s.id === snapshot.id);
  return idx > 0 ? data.snapshots[idx - 1] : null;
}

export function formatDate(iso?: string): string {
  if (!iso) return "—";
  return new Date(iso).toLocaleDateString("es-ES", { day: "2-digit", month: "short", year: "numeric" });
}

export function timeAgo(iso?: string): string {
  if (!iso) return "—";
  const diff = Date.now() - new Date(iso).getTime();
  const days = Math.floor(diff / DAY_MS);
  if (days <= 0) return "hoy";
  if (days === 1) return "hace 1 día";
  return `hace ${days} días`;
}
EOF

cat <<'EOF' > "$DIR/lib/twitch-auth.ts"
const AUTH_URL = "https://id.twitch.tv/oauth2";
const SCOPES = ["user:read:follows"].join(" ");

export const CLIENT_ID = process.env.NEXT_PUBLIC_TWITCH_CLIENT_ID ?? "";

export function getRedirectUri(): string {
  const base = `${window.location.origin}${process.env.NEXT_PUBLIC_BASE_PATH ?? ""}`;
  return `${base}/callback`;
}

function base64UrlEncode(bytes: Uint8Array): string {
  let bin = "";
  bytes.forEach((b) => (bin += String.fromCharCode(b)));
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function sha256(plain: string): Promise<Uint8Array> {
  const encoder = new TextEncoder();
  return new Uint8Array(await crypto.subtle.digest("SHA-256", encoder.encode(plain)));
}

export async function startLogin() {
  const verifier = base64UrlEncode(crypto.getRandomValues(new Uint8Array(64)));
  const challenge = base64UrlEncode(await sha256(verifier));
  sessionStorage.setItem("twitch_pkce_verifier", verifier);

  const params = new URLSearchParams({
    client_id: CLIENT_ID,
    redirect_uri: getRedirectUri(),
    response_type: "code",
    scope: SCOPES,
    code_challenge: challenge,
    code_challenge_method: "S256",
    force_verify: "false",
  });
  window.location.href = `${AUTH_URL}/authorize?${params}`;
}

export async function exchangeCode(code: string): Promise<string> {
  const verifier = sessionStorage.getItem("twitch_pkce_verifier");
  sessionStorage.removeItem("twitch_pkce_verifier");
  if (!verifier) throw new Error("Falta el verifier de PKCE (sesión expirada). Vuelve a conectarte.");

  const res = await fetch(`${AUTH_URL}/token`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: CLIENT_ID,
      code,
      grant_type: "authorization_code",
      redirect_uri: getRedirectUri(),
      code_verifier: verifier,
    }),
  });
  if (!res.ok) throw new Error(`Error en el token: ${res.status}`);
  const data = await res.json();
  return data.access_token as string;
}

const TOKEN_KEY = "twitch_access_token";

export function saveToken(token: string) { localStorage.setItem(TOKEN_KEY, token); }
export function getToken(): string | null { return localStorage.getItem(TOKEN_KEY); }
export function clearToken() { localStorage.removeItem(TOKEN_KEY); }
export function isLoggedIn(): boolean { return Boolean(getToken()); }
EOF

cat <<'EOF' > "$DIR/lib/twitch-client.ts"
import { CLIENT_ID, getToken } from "./twitch-auth";

const HELIX = "https://api.twitch.tv/helix";

async function helix(path: string) {
  const token = getToken();
  if (!token) throw new Error("No estás conectado a Twitch.");
  const res = await fetch(`${HELIX}${path}`, {
    headers: { "Client-ID": CLIENT_ID, Authorization: `Bearer ${token}` },
  });
  if (res.status === 401) throw new Error("Sesión expirada. Vuelve a conectarte.");
  if (!res.ok) throw new Error(`Twitch API ${res.status}`);
  return res.json();
}

export interface TwitchApiUser {
  id: string;
  login: string;
  display_name: string;
  profile_image_url: string;
}

export async function getMe(): Promise<TwitchApiUser | null> {
  const data = await helix("/users");
  return data.data?.[0] ?? null;
}

export async function searchUserByLogin(login: string): Promise<TwitchApiUser | null> {
  const data = await helix(`/users?login=${encodeURIComponent(login)}`);
  return data.data?.[0] ?? null;
}

export interface FollowerEntry {
  userId: string;
  login: string;
  displayName: string;
  followedAt: string;
  avatar: string;
}

export interface FollowersResult {
  total: number;
  followers: FollowerEntry[];
  truncated: boolean;
}

const MAX_FOLLOWERS = 1000;

export async function fetchAllFollowers(channelId: string): Promise<FollowersResult> {
  const followers: FollowerEntry[] = [];
  let cursor: string | undefined;
  let total = 0;

  do {
    const q = new URLSearchParams({ to_id: channelId, first: "100" });
    if (cursor) q.set("after", cursor);

    const data = await helix(`/users/follows?${q}`);
    total = data.total ?? total;

    for (const f of data.data ?? []) {
      followers.push({
        userId: f.from_id,
        login: f.from_login,
        displayName: f.from_name,
        followedAt: f.followed_at,
        avatar: "",
      });
    }
    cursor = data.pagination?.cursor;
  } while (cursor && followers.length < MAX_FOLLOWERS);

  const logins = followers.map((f) => f.login);
  for (let i = 0; i < logins.length; i += 100) {
    const chunk = logins.slice(i, i + 100).map(encodeURIComponent).join("&login=");
    const usersData = await helix(`/users?login=${chunk}`);
    const byLogin = new Map<string, string>(
      (usersData.data ?? []).map((u: TwitchApiUser): [string, string] => [u.login, u.profile_image_url])
    );
    for (const f of followers) f.avatar = byLogin.get(f.login) ?? f.avatar;
  }

  return { total, followers, truncated: followers.length < total };
}
EOF

echo "📁 Creando componentes..."
cat <<'EOF' > "$DIR/components/ConnectButton.tsx"
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
EOF

cat <<'EOF' > "$DIR/components/Sidebar.tsx"
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
EOF

cat <<'EOF' > "$DIR/components/StatCard.tsx"
interface Props {
  label: string;
  value: string | number;
  delta?: number;
  icon?: string;
}

export default function StatCard({ label, value, delta, icon }: Props) {
  const positive = (delta ?? 0) >= 0;
  return (
    <div className="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-4">
      <div className="flex items-center justify-between text-sm text-zinc-500">
        <span>{label}</span>
        {icon && <span className="text-lg">{icon}</span>}
      </div>
      <p className="mt-2 text-2xl font-bold">{value}</p>
      {delta !== undefined && (
        <p className={`mt-1 text-xs font-medium ${positive ? "text-emerald-400" : "text-red-400"}`}>
          {positive ? "▲" : "▼"} {Math.abs(delta)}
        </p>
      )}
    </div>
  );
}
EOF

cat <<'EOF' > "$DIR/components/FollowRow.tsx"
import { formatDate, timeAgo } from "@/lib/analytics";
import type { UserWithFollowDate } from "@/lib/types";

interface Props {
  user: UserWithFollowDate;
  sub?: string;
  badge?: { label: string; tone: "green" | "red" | "purple" | "gray" };
}

const tones: Record<string, string> = {
  green: "bg-emerald-500/15 text-emerald-300",
  red: "bg-red-500/15 text-red-300",
  purple: "bg-twitch/20 text-purple-300",
  gray: "bg-zinc-700/30 text-zinc-400",
};

export default function FollowRow({ user, sub, badge }: Props) {
  return (
    <div className="flex items-center gap-3 rounded-xl px-3 py-2 hover:bg-zinc-800/60 transition">
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img src={user.profileImageUrl} alt={user.displayName} className="h-9 w-9 rounded-full bg-zinc-800" />
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-semibold">{user.displayName}</p>
        <p className="truncate text-xs text-zinc-500">
          {sub ?? (user.followedAt ? `Te sigue desde ${formatDate(user.followedAt)}` : `Siguiendo desde ${formatDate(user.iFollowSince)}`)}
        </p>
      </div>
      {user.followedAt && (
        <span className="hidden sm:block text-xs text-zinc-600">{timeAgo(user.followedAt)}</span>
      )}
      {badge && (
        <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${tones[badge.tone]}`}>
          {badge.label}
        </span>
      )}
    </div>
  );
}
EOF

cat <<'EOF' > "$DIR/components/FollowList.tsx"
import FollowRow from "./FollowRow";
import type { UserWithFollowDate } from "@/lib/types";

interface Props {
  title: string;
  subtitle?: string;
  users: UserWithFollowDate[];
  emptyText?: string;
  badge?: { label: string; tone: "green" | "red" | "purple" | "gray" };
}

export default function FollowList({ title, subtitle, users, emptyText, badge }: Props) {
  return (
    <section className="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-4">
      <header className="mb-3 flex items-baseline justify-between">
        <div>
          <h2 className="font-bold">{title}</h2>
          {subtitle && <p className="text-xs text-zinc-500">{subtitle}</p>}
        </div>
        <span className="rounded-full bg-zinc-800 px-2 py-0.5 text-xs font-semibold text-zinc-300">
          {users.length}
        </span>
      </header>
      <div className="max-h-[28rem] divide-y divide-zinc-800/60 overflow-y-auto">
        {users.length === 0 ? (
          <p className="py-8 text-center text-sm text-zinc-500">{emptyText ?? "Sin resultados"}</p>
        ) : (
          users.map((u) => <FollowRow key={u.id} user={u} badge={badge} />)
        )}
      </div>
    </section>
  );
}
EOF

cat <<'EOF' > "$DIR/components/GrowthChart.tsx"
"use client";

import {
  Area, AreaChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis,
} from "recharts";
import type { GrowthPoint } from "@/lib/analytics";

export default function GrowthChart({ data }: { data: GrowthPoint[] }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <AreaChart data={data} margin={{ top: 10, right: 10, bottom: 0, left: -20 }}>
        <defs>
          <linearGradient id="gFollowers" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#9146FF" stopOpacity={0.6} />
            <stop offset="95%" stopColor="#9146FF" stopOpacity={0} />
          </linearGradient>
          <linearGradient id="gFollowing" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#22d3ee" stopOpacity={0.5} />
            <stop offset="95%" stopColor="#22d3ee" stopOpacity={0} />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
        <XAxis dataKey="label" stroke="#71717a" fontSize={12} />
        <YAxis stroke="#71717a" fontSize={12} allowDecimals={false} />
        <Tooltip
          contentStyle={{
            backgroundColor: "#18181b",
            border: "1px solid #3f3f46",
            borderRadius: 12,
            fontSize: 13,
          }}
        />
        <Legend />
        <Area type="monotone" dataKey="followers" name="Seguidores" stroke="#9146FF" fill="url(#gFollowers)" strokeWidth={2} />
        <Area type="monotone" dataKey="following" name="Siguiendo" stroke="#22d3ee" fill="url(#gFollowing)" strokeWidth={2} />
      </AreaChart>
    </ResponsiveContainer>
  );
}
EOF

echo "📁 Creando app/ (páginas)..."
cat <<'EOF' > "$DIR/app/globals.css"
@tailwind base;
@tailwind components;
@tailwind utilities;

:root { color-scheme: dark; }

body {
  @apply bg-zinc-950 text-zinc-100 antialiased;
}

::-webkit-scrollbar { width: 8px; height: 8px; }
::-webkit-scrollbar-thumb { @apply bg-zinc-700 rounded-full; }
::-webkit-scrollbar-track { @apply bg-transparent; }
EOF

cat <<'EOF' > "$DIR/app/layout.tsx"
import type { Metadata } from "next";
import Sidebar from "@/components/Sidebar";
import "./globals.css";

export const metadata: Metadata = {
  title: "Twitch Follows Analyzer",
  description: "Analiza tus seguidores de Twitch: unfollows, no-te-siguen, fans y crecimiento.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body className="flex">
        <Sidebar />
        <nav className="fixed bottom-0 inset-x-0 z-10 flex md:hidden border-t border-zinc-800 bg-zinc-900/95 backdrop-blur">
          {[
            ["/", "📊"],
            ["/unfollows", "📉"],
            ["/not-following-back", "🔁"],
            ["/fans", "🧠"],
            ["/growth", "📈"],
          ].map(([href, icon]) => (
            <a key={href} href={href} className="flex-1 py-3 text-center text-lg">
              {icon}
            </a>
          ))}
        </nav>
        <main className="flex-1 min-h-screen pb-16 md:pb-6 p-4 md:p-8 max-w-6xl mx-auto w-full">
          {children}
        </main>
      </body>
    </html>
  );
}
EOF

cat <<'EOF' > "$DIR/app/page.tsx"
import StatCard from "@/components/StatCard";
import FollowList from "@/components/FollowList";
import GrowthChart from "@/components/GrowthChart";
import {
  getFans, getGrowthSeries, getLatestSnapshot, getMutuals, getNewFollowersBetween,
  getNotFollowingBack, getPreviousSnapshot, getUnfollowsBetween,
} from "@/lib/analytics";
import { generateDemoData } from "@/lib/demo-data";

const data = generateDemoData();
const latest = getLatestSnapshot(data);
const prev = getPreviousSnapshot(data, latest);

export default function Dashboard() {
  const unfollows = prev ? getUnfollowsBetween(prev, latest) : [];
  const newFollowers = prev ? getNewFollowersBetween(prev, latest) : [];
  const fans = getFans(data, latest);
  const mutuals = getMutuals(data, latest);
  const notFollowingBack = getNotFollowingBack(data, latest);
  const growth = getGrowthSeries(data.snapshots);

  const net = newFollowers.length - unfollows.length;
  const prevCount = prev?.followers.length ?? latest.followers.length;

  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <p className="text-sm text-zinc-500">
          Snapshot actual: {new Date(latest.takenAt).toLocaleDateString("es-ES", { dateStyle: "long" })}
        </p>
      </header>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard label="Seguidores" value={latest.followers.length} delta={latest.followers.length - prevCount} icon="👥" />
        <StatCard label="Siguiendo" value={latest.following.length} icon="➡️" />
        <StatCard label="Te dejaron" value={unfollows.length} icon="📉" />
        <StatCard label="Nuevos" value={newFollowers.length} delta={net} icon="✨" />
      </div>

      <section className="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-4">
        <h2 className="font-bold mb-4">Evolución</h2>
        <GrowthChart data={growth} />
      </section>

      <div className="grid lg:grid-cols-2 gap-4">
        <FollowList
          title="⚠️ Unfollows recientes"
          subtitle="Te dejaron de seguir esta semana"
          users={unfollows.map((f) => ({ ...data.users[f.userId], followedAt: f.followedAt }))}
          badge={{ label: "Unfollow", tone: "red" }}
          emptyText="¡Nadie te dejó! 🎉"
        />
        <FollowList
          title="🆕 Nuevos seguidores"
          subtitle="Te siguieron esta semana"
          users={newFollowers.map((f) => ({ ...data.users[f.userId], followedAt: f.followedAt }))}
          badge={{ label: "Nuevo", tone: "green" }}
        />
      </div>

      <div className="grid lg:grid-cols-3 gap-4">
        <FollowList title="🧠 Fans" subtitle="Te siguen sin que les sigas" users={fans.slice(0, 12)} badge={{ label: "Fan", tone: "purple" }} />
        <FollowList title="🤝 Mutuos" subtitle="Os seguís mutuamente" users={mutuals.slice(0, 12)} badge={{ label: "Mutuos", tone: "green" }} />
        <FollowList title="🔁 No te siguen" subtitle="Los sigues sin que te sigan" users={notFollowingBack.slice(0, 12)} badge={{ label: "Ojo", tone: "red" }} />
      </div>
    </div>
  );
}
EOF

cat <<'EOF' > "$DIR/app/search/page.tsx"
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
EOF

cat <<'EOF' > "$DIR/app/login/page.tsx"
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
EOF

cat <<'EOF' > "$DIR/app/callback/page.tsx"
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
EOF

cat <<'EOF' > "$DIR/app/unfollows/page.tsx"
import FollowList from "@/components/FollowList";
import { getLatestSnapshot, getPreviousSnapshot, getUnfollowsBetween } from "@/lib/analytics";
import { generateDemoData } from "@/lib/demo-data";

const data = generateDemoData();
const latest = getLatestSnapshot(data);
const prev = getPreviousSnapshot(data, latest);
const unfollows = prev ? getUnfollowsBetween(prev, latest) : [];

export default function UnfollowsPage() {
  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-2xl font-bold">📉 Unfollows</h1>
        <p className="text-sm text-zinc-500">
          Quién te dejó de seguir entre {prev ? new Date(prev.takenAt).toLocaleDateString("es-ES") : "—"} y{" "}
          {new Date(latest.takenAt).toLocaleDateString("es-ES")}
        </p>
      </header>
      <FollowList
        title="Te dejaron de seguir"
        subtitle={`${unfollows.length} unfollow(s) en el último periodo`}
        users={unfollows.map((f) => ({ ...data.users[f.userId], followedAt: f.followedAt }))}
        badge={{ label: "Unfollow", tone: "red" }}
        emptyText="¡Nadie te dejó! 🎉"
      />
    </div>
  );
}
EOF

cat <<'EOF' > "$DIR/app/not-following-back/page.tsx"
import FollowList from "@/components/FollowList";
import { getLatestSnapshot, getNotFollowingBack } from "@/lib/analytics";
import { generateDemoData } from "@/lib/demo-data";

const data = generateDemoData();
const latest = getLatestSnapshot(data);
const notFollowingBack = getNotFollowingBack(data, latest);

export default function NotFollowingBackPage() {
  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-2xl font-bold">🔁 No te siguen de vuelta</h1>
        <p className="text-sm text-zinc-500">
          Cuentas a las que sigues y que no te siguen. ¿Seguro que quieres seguir siguiéndolas?
        </p>
      </header>
      <FollowList
        title="Los sigues tú, ellos no a ti"
        subtitle={`${notFollowingBack.length} cuentas de ${latest.following.length} a las que sigues`}
        users={notFollowingBack}
        badge={{ label: "No devuelven", tone: "red" }}
        emptyText="¡Genial! Todos a los que sigues te siguen. 🤝"
      />
    </div>
  );
}
EOF

cat <<'EOF' > "$DIR/app/fans/page.tsx"
import FollowList from "@/components/FollowList";
import { getFans, getLatestSnapshot, getMutuals } from "@/lib/analytics";
import { generateDemoData } from "@/lib/demo-data";

const data = generateDemoData();
const latest = getLatestSnapshot(data);
const fans = getFans(data, latest);
const mutuals = getMutuals(data, latest);

export default function FansPage() {
  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-2xl font-bold">🧠 Fans, mutuos y silenciosos</h1>
        <p className="text-sm text-zinc-500">Clasificación de tu audiencia según la relación de follows.</p>
      </header>
      <div className="grid lg:grid-cols-2 gap-4">
        <FollowList
          title="💜 Fans"
          subtitle="Te siguen sin que les sigas: son tu audiencia real"
          users={fans}
          badge={{ label: "Fan", tone: "purple" }}
        />
        <FollowList
          title="🤝 Mutuos"
          subtitle="Os seguís mutuamente: tu comunidad más cercana"
          users={mutuals}
          badge={{ label: "Mutuos", tone: "green" }}
        />
      </div>
      <div className="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-4 text-sm text-zinc-400">
        <p className="font-semibold text-zinc-300 mb-1">🔇 Silenciosos</p>
        <p>
          En Twitch no hay métricas públicas de interacción, así que definimos <strong>silenciosos</strong> como los que{" "}
          <strong>sigues pero no te siguen</strong>: están en la pestaña{" "}
          <a href="/not-following-back" className="text-twitch hover:underline">No te siguen de vuelta</a>.
        </p>
      </div>
    </div>
  );
}
EOF

cat <<'EOF' > "$DIR/app/growth/page.tsx"
import StatCard from "@/components/StatCard";
import GrowthChart from "@/components/GrowthChart";
import {
  getGrowthSeries, getLatestSnapshot, getNewFollowersBetween, getPreviousSnapshot, getUnfollowsBetween,
} from "@/lib/analytics";
import { generateDemoData } from "@/lib/demo-data";

const data = generateDemoData();
const latest = getLatestSnapshot(data);
const prev = getPreviousSnapshot(data, latest);
const growth = getGrowthSeries(data.snapshots);

export default function GrowthPage() {
  const unfollows = prev ? getUnfollowsBetween(prev, latest) : [];
  const newFollowers = prev ? getNewFollowersBetween(prev, latest) : [];
  const totalDelta = latest.followers.length - (data.snapshots[0]?.followers.length ?? latest.followers.length);

  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-2xl font-bold">📈 Crecimiento</h1>
        <p className="text-sm text-zinc-500">Evolución de seguidores y seguidos a lo largo del tiempo.</p>
      </header>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard label="Neto total" value={`${totalDelta >= 0 ? "+" : ""}${totalDelta}`} delta={totalDelta} icon="🧮" />
        <StatCard label="Nuevos (últ. periodo)" value={newFollowers.length} icon="✨" />
        <StatCard label="Unfollows (últ. periodo)" value={unfollows.length} icon="📉" />
        <StatCard label="Ratio retención" value={`${latest.followers.length ? Math.round((latest.followers.length / (latest.followers.length + unfollows.length)) * 100) : 0}%`} icon="🛡️" />
      </div>

      <section className="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-4">
        <h2 className="font-bold mb-4">Seguidores vs Siguiendo</h2>
        <GrowthChart data={growth} />
        <div className="mt-4 flex flex-wrap gap-2 text-xs text-zinc-500">
          {growth.map((g) => (
            <span key={g.date} className="rounded-full bg-zinc-800 px-3 py-1">
              {g.label}: <strong className="text-zinc-200">{g.followers}</strong> seg.
            </span>
          ))}
        </div>
      </section>
    </div>
  );
}
EOF

echo "📁 Creando GitHub Actions y README..."
cat <<'EOF' > "$DIR/.github/workflows/deploy.yml"
name: Deploy a GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run build
        env:
          NEXT_PUBLIC_TWITCH_CLIENT_ID: ${{ vars.TWITCH_CLIENT_ID }}
          NEXT_PUBLIC_BASE_PATH: /${{ github.event.repository.name }}
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with:
          path: ./out
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
EOF

cat <<'EOF' > "$DIR/README.md"
# 🎮 Twitch Follows Analyzer

Analizador de follows de Twitch: unfollows, quién no te sigue de vuelta, fans/mutuos,
crecimiento y buscador de seguidores de cualquier canal. Estilo tools.2807.eu/follows.

## ⚙️ Configuración (una vez)

1. Crea una app en [dev.twitch.tv/console/apps](https://dev.twitch.tv/console/apps):
   - **OAuth Redirect URL**: `https://TU_USUARIO.github.io/NOMBRE_REPO/callback`
2. Copia el **Client ID** y añádelo como variable en el repo:
   `Settings → Secrets and variables → Actions → Variables` → `TWITCH_CLIENT_ID`
3. Activa GitHub Pages en `Settings → Pages` → Source: **GitHub Actions**.
4. Sube el código a `main`: el workflow compila y despliega solo. 🎉

> 💡 También funciona en local: copia `.env.local.example` a `.env.local`,
> pon tu `NEXT_PUBLIC_TWITCH_CLIENT_ID` y `npm run dev`.

## 📄 Páginas

| Ruta | Función |
|---|---|
| `/` | Dashboard con resumen y evolución |
| `/search` | Buscar seguidores de cualquier canal |
| `/unfollows` | Quién te dejó de seguir |
| `/not-following-back` | Los sigues pero no te siguen |
| `/fans` | Fans, mutuos y silenciosos |
| `/growth` | Gráficas de crecimiento |
| `/login` · `/callback` | OAuth PKCE con Twitch |

## ⚠️ Notas técnicas

- **GitHub Pages es estático**: todo el acceso a la API de Twitch ocurre en el navegador
  con el token del usuario (OAuth PKCE, sin secret). El token vive en `localStorage`.
- **Límite de ~1000 seguidores por canal** en `GET /users/follows?to_id=` (Helix).
- La demo funciona sin login (datos de ejemplo deterministas).
EOF

echo "📦 Empaquetando..."
if command -v zip >/dev/null 2>&1; then
  zip -r twitch-follows.zip "$DIR" >/dev/null
  echo "✅ Creado: twitch-follows.zip"
else
  tar -czf twitch-follows.tar.gz "$DIR"
  echo "✅ zip no disponible, se creó: twitch-follows.tar.gz"
fi

echo ""
echo "🎉 Listo. Sube el contenido de la carpeta '$DIR' a tu repo de GitHub."
