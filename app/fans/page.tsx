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
