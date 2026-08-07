const AUTH_URL = "https://id.twitch.tv/oauth2";
const SCOPES = ["user:read:follows"].join(" ");

export const CLIENT_ID = process.env.NEXT_PUBLIC_TWITCH_CLIENT_ID ?? "";

export function getRedirectUri(): string {
  const base = `${window.location.origin}${process.env.NEXT_PUBLIC_BASE_PATH ?? ""}`;
  return `${base}/callback`;
}

function base64UrlEncode(bytes: Uint8Array): string {
  let bin = "";
  bytes.forEach((b) => (bin += String.fromCharCode(b)));
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function sha256(plain: string): Promise<Uint8Array> {
  const encoder = new TextEncoder();
  return new Uint8Array(await crypto.subtle.digest("SHA-256", encoder.encode(plain)));
}

export async function startLogin() {
  const verifier = base64UrlEncode(crypto.getRandomValues(new Uint8Array(64)));
  const challenge = base64UrlEncode(await sha256(verifier));
  sessionStorage.setItem("twitch_pkce_verifier", verifier);

  const params = new URLSearchParams({
    client_id: CLIENT_ID,
    redirect_uri: getRedirectUri(),
    response_type: "code",
    scope: SCOPES,
    code_challenge: challenge,
    code_challenge_method: "S256",
    force_verify: "false",
  });
  window.location.href = `${AUTH_URL}/authorize?${params}`;
}

export async function exchangeCode(code: string): Promise<string> {
  const verifier = sessionStorage.getItem("twitch_pkce_verifier");
  sessionStorage.removeItem("twitch_pkce_verifier");
  if (!verifier) throw new Error("Falta el verifier de PKCE (sesión expirada). Vuelve a conectarte.");

  const res = await fetch(`${AUTH_URL}/token`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: CLIENT_ID,
      code,
      grant_type: "authorization_code",
      redirect_uri: getRedirectUri(),
      code_verifier: verifier,
    }),
  });
  if (!res.ok) throw new Error(`Error en el token: ${res.status}`);
  const data = await res.json();
  return data.access_token as string;
}

const TOKEN_KEY = "twitch_access_token";

export function saveToken(token: string) { localStorage.setItem(TOKEN_KEY, token); }
export function getToken(): string | null { return localStorage.getItem(TOKEN_KEY); }
export function clearToken() { localStorage.removeItem(TOKEN_KEY); }
export function isLoggedIn(): boolean { return Boolean(getToken()); }
