interface Props {
  label: string;
  value: string | number;
  delta?: number;
  icon?: string;
}

export default function StatCard({ label, value, delta, icon }: Props) {
  const positive = (delta ?? 0) >= 0;
  return (
    <div className="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-4">
      <div className="flex items-center justify-between text-sm text-zinc-500">
        <span>{label}</span>
        {icon && <span className="text-lg">{icon}</span>}
      </div>
      <p className="mt-2 text-2xl font-bold">{value}</p>
      {delta !== undefined && (
        <p className={`mt-1 text-xs font-medium ${positive ? "text-emerald-400" : "text-red-400"}`}>
          {positive ? "▲" : "▼"} {Math.abs(delta)}
        </p>
      )}
    </div>
  );
}
