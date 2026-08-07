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
