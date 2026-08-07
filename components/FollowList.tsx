import FollowRow from "./FollowRow";
import type { UserWithFollowDate } from "@/lib/types";

interface Props {
  title: string;
  subtitle?: string;
  users: UserWithFollowDate[];
  emptyText?: string;
  badge?: { label: string; tone: "green" | "red" | "purple" | "gray" };
}

export default function FollowList({ title, subtitle, users, emptyText, badge }: Props) {
  return (
    <section className="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-4">
      <header className="mb-3 flex items-baseline justify-between">
        <div>
          <h2 className="font-bold">{title}</h2>
          {subtitle && <p className="text-xs text-zinc-500">{subtitle}</p>}
        </div>
        <span className="rounded-full bg-zinc-800 px-2 py-0.5 text-xs font-semibold text-zinc-300">
          {users.length}
        </span>
      </header>
      <div className="max-h-[28rem] divide-y divide-zinc-800/60 overflow-y-auto">
        {users.length === 0 ? (
          <p className="py-8 text-center text-sm text-zinc-500">{emptyText ?? "Sin resultados"}</p>
        ) : (
          users.map((u) => <FollowRow key={u.id} user={u} badge={badge} />)
        )}
      </div>
    </section>
  );
}
