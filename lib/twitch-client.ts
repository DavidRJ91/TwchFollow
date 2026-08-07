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
