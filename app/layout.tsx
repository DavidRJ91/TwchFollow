import type { Metadata } from "next";
import Link from "next/link";
import Sidebar from "@/components/Sidebar";
import "./globals.css";

export const metadata: Metadata = {
  title: "Twitch Follows Analyzer",
  description: "Analiza tus seguidores de Twitch: unfollows, no-te-siguen, fans y crecimiento.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body className="flex">
        <Sidebar />
        <nav className="fixed bottom-0 inset-x-0 z-10 flex md:hidden border-t border-zinc-800 bg-zinc-900/95 backdrop-blur">
          {[
            ["/", "📊"],
            ["/unfollows", "📉"],
            ["/not-following-back", "🔁"],
            ["/fans", "🧠"],
            ["/growth", "📈"],
          ].map(([href, icon]) => (
            <Link key={href} href={href} className="flex-1 py-3 text-center text-lg">
              {icon}
            </Link>
          ))}
        </nav>
        <main className="flex-1 min-h-screen pb-16 md:pb-6 p-4 md:p-8 max-w-6xl mx-auto w-full">
          {children}
        </main>
      </body>
    </html>
  );
}
