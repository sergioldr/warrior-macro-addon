# warrior-macro-addon

Addon de World of Warcraft: Forever que crea y mantiene las macros del guerrero, con los nombres de hechizo en el idioma de tu cliente.

## Qué hace

- Crea 24 macros agrupadas con un prefijo, para que salgan juntas en `/macro` (que las ordena alfabéticamente):
  - **P** · Protección (tanque, basadas en la guía de leveling de Cliptis): `P Opener`, `P Main`, `P Block`, `P Kick`, `P Provocar MO`, `P Mock`, `P MuroEscudo`, `P Desarmar`
  - **C** · Comunes a tanque y DPS: `C Rush`, `C Desgarrar`, `C Ejecutar`, `C Seccionar`, `C Torbellino`, `C GolpeHeroic`, `C Grito MO`, `C Arma 2M`, `C 1M+Escudo`
  - **D** · DPS (Armas/Furia): `D Abrumar`, `D GolpeMortal`, `D Barrido`, `D IraRabiosa`, `D Zurrar`, `D Represalia`, `D Temeridad`
- Traduce los nombres a partir del ID de cada hechizo, así que funciona en cualquier idioma del cliente. Si un hechizo no existe en tu cliente, lo avisa en el chat.
- Solo toca una macro si falta o si su contenido ha cambiado. Si todo está al día, no escribe nada en el chat.
- Cambia dos macros al subir de nivel:
  - **Nivel 25** (Vanguard): `P Opener` deja de pasar por Battle Stance; carga desde Defensive y en combate lanza Intercept.
  - **Nivel 30**: `C Ejecutar` pasa a usar Berserker Stance en vez de Battle Stance.
- No toca las macros en combate ni dentro de mazmorras o bandas: lo deja pendiente y lo hace al salir. Los cambios se aplican de uno en uno, repartidos en varios frames, para no provocar picos de rendimiento.
- Si encuentra macros con el nombre antiguo, las renombra en lugar de crear otras nuevas, así que se quedan en tus barras de acción.

## Instalación

1. Copia esta carpeta en `World of Warcraft/_forever_/Interface/AddOns/` con el nombre `WarriorMacroAddon`.
2. Entra al juego. Las macros se crean solas unos segundos después de cargar.
3. Si quieres forzar la comprobación, escribe `/warriormacros`.

Si no caben todas en las macros del personaje (18 como máximo), el resto se guarda en las generales.

## Requisitos

Las macros de escudo y de cambio de arma pulsan botones de **Bartender4**, en la barra 5:

| Botón | Contenido |
|---|---|
| `BT4Button49` | arma a dos manos |
| `BT4Button50` | arma de una mano |
| `BT4Button51` | escudo |

Si usas otra barra u otros botones, cambia `EQUIP_1H_SHIELD`, `EQUIP_IF_NO_SHIELD` y la macro `C Arma 2M` en `WarriorMacroAddon.lua`.
