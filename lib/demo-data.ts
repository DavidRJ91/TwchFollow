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
