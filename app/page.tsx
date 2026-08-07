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
