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
