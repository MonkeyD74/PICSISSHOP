# AGENTS.md — PiscisShop

Reglas para agentes autónomos (Hermes u otros) que trabajen en este repo.
Estas reglas NO son opcionales. Si una tarea entra en conflicto con ellas,
detente y pregunta al dueño antes de continuar.

## 1. Seguridad y credenciales

- **NUNCA pidas tokens, contraseñas ni API keys por el chat.** Si falta
  autenticación (push rechazado, API 401), reporta el error exacto y detente.
  El dueño configura las credenciales en el entorno; tú las heredas.
- **NUNCA leas, imprimas, loguees ni commitees** el contenido de `.env.local`
  ni ningún secreto. El token de Loyverse vive ahí y jamás sale de ahí.
- No agregues secretos hardcodeados en el código bajo ninguna circunstancia.
- No modifiques `.gitignore` para des-ignorar archivos de entorno.

## 2. Flujo de Git

- **NUNCA hagas push directo a `main`.** Trabaja siempre en una branch:
  `feat/descripcion` o `fix/descripcion`.
- **NUNCA merges tu propio PR.** Abre el PR, describe qué hiciste y qué NO
  verificaste, y espera revisión del dueño.
- Un cambio = un commit con mensaje claro. Prefijos: `feat:`, `fix:`, `chore:`.
- Antes de empezar: `git fetch origin && git status`. Si el árbol no está
  limpio o la rama está desfasada, repórtalo y detente. No hagas `git pull`
  con merge automático ni resuelvas conflictos por tu cuenta.
- Nunca uses `push --force` en ninguna rama.

## 3. Verificación obligatoria antes de commitear

- **Corre `next build` y confirma que pasa sin errores.** Si el build falla,
  no commitees; reporta el error.
- Si tocaste lógica, corre los tests existentes (si los hay).
- **Valida claves contra la fuente de datos real.** Las categorías, nombres
  de producto e IDs vienen de Loyverse. Cualquier string usado como clave de
  lookup (ej. `CATEGORY_THEMES["Cosmeticos"]`) debe coincidir EXACTAMENTE
  (mayúsculas, acentos, espacios) con el valor que devuelve la API de
  Loyverse. Si no puedes consultar la API para verificar, dilo explícitamente
  en el PR: "claves NO verificadas contra Loyverse".

## 4. Alcance y honestidad

- **Declara los límites de tu cambio.** Si el resultado visible depende de
  algo fuera del código (ej. crear la categoría en el Back office de
  Loyverse, una variable de entorno en Vercel), dilo en el PR. No entregues
  un cambio como "completo" si requiere pasos externos.
- **No inventes datos.** Si necesitas datos que no tienes (nombres reales de
  categorías, precios, fixtures), pregunta o marca el hueco con un TODO
  visible. Nunca rellenes con datos plausibles pero no verificados.
- Si no estás seguro de cómo funciona algo, lee el código existente antes de
  asumir. No adivines contratos ni formatos.

## 5. Estilo de código

- **Diffs mínimos.** Extiende estructuras existentes; no crees estructuras
  paralelas ni reescribas archivos completos para cambios puntuales.
- Sigue los patrones ya presentes en el archivo que tocas (naming,
  formato de objetos, orden de propiedades).
- No agregues dependencias nuevas a `package.json` sin aprobación explícita.
- No hagas refactors "de paso". Si ves algo mejorable fuera del alcance de
  la tarea, menciónalo en el PR en vez de tocarlo.

## 6. Contexto del proyecto

- **Stack:** Next.js 14, React 18, deploy en Vercel (plan hobby — no
  introduzcas nada que genere cargos: cron jobs pesados, funciones de larga
  duración, etc.).
- **Datos:** catálogo y lealtad vienen de la API de Loyverse. La paginación
  de Loyverse se maneja client-side. El sistema de lealtad busca por número
  de teléfono, no por usuario/contraseña.
- **Categorías:** el catálogo renderiza dinámicamente las categorías que
  llegan de Loyverse. `CATEGORY_THEMES` y `CAT_PILL_COLORS_BY_NAME` en
  `Catalog.jsx` solo definen la apariencia; agregar una entrada ahí NO crea
  una categoría.
- **Producción:** https://piscisshop.com — cualquier cambio mergeado a
  `main` se despliega solo. Por eso la regla 2: nada llega a `main` sin
  revisión humana.

## 7. Al terminar cada tarea

Incluye en la descripción del PR:

1. Qué cambiaste (archivos y propósito).
2. Qué verificaste (build, tests, claves contra Loyverse).
3. Qué NO verificaste y por qué.
4. Pasos externos pendientes para que el cambio surta efecto (si los hay).
