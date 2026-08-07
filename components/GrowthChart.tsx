"use client";

import {
  Area, AreaChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis,
} from "recharts";
import type { GrowthPoint } from "@/lib/analytics";

export default function GrowthChart({ data }: { data: GrowthPoint[] }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <AreaChart data={data} margin={{ top: 10, right: 10, bottom: 0, left: -20 }}>
        <defs>
          <linearGradient id="gFollowers" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#9146FF" stopOpacity={0.6} />
            <stop offset="95%" stopColor="#9146FF" stopOpacity={0} />
          </linearGradient>
          <linearGradient id="gFollowing" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#22d3ee" stopOpacity={0.5} />
            <stop offset="95%" stopColor="#22d3ee" stopOpacity={0} />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
        <XAxis dataKey="label" stroke="#71717a" fontSize={12} />
        <YAxis stroke="#71717a" fontSize={12} allowDecimals={false} />
        <Tooltip
          contentStyle={{
            backgroundColor: "#18181b",
            border: "1px solid #3f3f46",
            borderRadius: 12,
            fontSize: 13,
          }}
        />
        <Legend />
        <Area type="monotone" dataKey="followers" name="Seguidores" stroke="#9146FF" fill="url(#gFollowers)" strokeWidth={2} />
        <Area type="monotone" dataKey="following" name="Siguiendo" stroke="#22d3ee" fill="url(#gFollowing)" strokeWidth={2} />
      </AreaChart>
    </ResponsiveContainer>
  );
}
