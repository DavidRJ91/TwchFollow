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
