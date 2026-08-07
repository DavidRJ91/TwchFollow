# 🎮 Twitch Follows Analyzer

Analizador de follows de Twitch: unfollows, quién no te sigue de vuelta, fans/mutuos,
crecimiento y buscador de seguidores de cualquier canal.

## ⚙️ Configuración (una vez)

1. Crea una app en [dev.twitch.tv/console/apps](https://dev.twitch.tv/console/apps):
   - **OAuth Redirect URL**: `https://TU_USUARIO.github.io/NOMBRE_REPO/callback`
2. Copia el **Client ID** y añádelo como variable en el repo:
   `Settings → Secrets and variables → Actions → Variables` → `TWITCH_CLIENT_ID`
3. Activa GitHub Pages en `Settings → Pages` → Source: **GitHub Actions**.
4. Sube el código a `main`: el workflow compila y despliega solo. 🎉

> 💡 También funciona en local: copia `.env.local.example` a `.env.local`,
> pon tu `NEXT_PUBLIC_TWITCH_CLIENT_ID` y `npm run dev`.

## 📄 Páginas

| Ruta | Función |
|---|---|
| `/` | Dashboard con resumen y evolución |
| `/search` | Buscar seguidores de cualquier canal |
| `/unfollows` | Quién te dejó de seguir |
| `/not-following-back` | Los sigues pero no te siguen |
| `/fans` | Fans, mutuos y silenciosos |
| `/growth` | Gráficas de crecimiento |
| `/login` · `/callback` | OAuth PKCE con Twitch |

## ⚠️ Notas técnicas

- **GitHub Pages es estático**: todo el acceso a la API de Twitch ocurre en el navegador
  con el token del usuario (OAuth PKCE, sin secret). El token vive en `localStorage`.
- **Límite de ~1000 seguidores por canal** en `GET /users/follows?to_id=` (Helix).
- La demo funciona sin login (datos de ejemplo deterministas).
