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
