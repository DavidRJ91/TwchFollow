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
