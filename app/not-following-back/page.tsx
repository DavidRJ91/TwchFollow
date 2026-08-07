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
