-- Crea macros de guerrero usando nombres de hechizo localizados.
--  * Set "G ..."  : guia de Phobyac (se crean una vez; las marcadas replace=true se reescriben en cada login).
--  * Set de tanque: guia de Cliptis (Protection, WoW Forever). Nombres cortos en ingles; se reescriben
--    en cada login y al subir al nivel 25 (Vanguard cambia la macro Opener).
local S = {
  BATTLE=2457, DEF=71, BERSERKER=2458, OVERPOWER=7384, CHARGE=100, HAMSTRING=1715,
  INTERCEPT=20252, BRAGE=18499, PUMMEL=6552, DISARM=676, ISHOUT=5246,
  MS=12294, EXECUTE=5308, REND=772, SWEEP=12292, WW=1680, HS=78,
  SWALL=871, SBASH=72, SBLOCK=2565, RETAL=20230, RECK=1719, REVENGE=6572, TAUNT=355,
  MOCK=694,
  VRUSH={402927, 34428},   -- 402927 = Victory Rush de WoW Forever (nivel 20); 34428 = el de TBC/retail, por si acaso
}
local EN = {
  BATTLE="Battle Stance", DEF="Defensive Stance", BERSERKER="Berserker Stance",
  OVERPOWER="Overpower", CHARGE="Charge", HAMSTRING="Hamstring", INTERCEPT="Intercept",
  BRAGE="Berserker Rage", PUMMEL="Pummel", DISARM="Disarm", ISHOUT="Intimidating Shout",
  MS="Mortal Strike", EXECUTE="Execute", REND="Rend", SWEEP="Sweeping Strikes",
  WW="Whirlwind", HS="Heroic Strike", SWALL="Shield Wall", SBASH="Shield Bash", SBLOCK="Shield Block", RETAL="Retaliation",
  RECK="Recklessness", REVENGE="Revenge", TAUNT="Taunt", MOCK="Mocking Blow", VRUSH="Victory Rush",
}
local VANGUARD_LEVEL = 25

local fallback = {}   -- hechizos sin traduccion en este cliente (se avisa al final)
local nameCache = {}  -- nombres ya resueltos en esta pasada (se vacia al empezar cada una)
local function N(key)
  if nameCache[key] then return nameCache[key] end
  local ids, name = S[key], nil
  if not ids then return "{"..key.."}" end
  if type(ids) ~= "table" then ids = {ids} end
  for _, id in ipairs(ids) do   -- el primer ID que exista en este cliente
    if C_Spell and C_Spell.GetSpellName then name = C_Spell.GetSpellName(id) end
    if not name and GetSpellInfo then name = GetSpellInfo(id) end
    if name then break end
  end
  if not name then fallback[key] = true end
  nameCache[key] = name or EN[key]
  return nameCache[key]
end
local function ShieldType()
  local n
  if C_Item and C_Item.GetItemSubClassInfo then n = C_Item.GetItemSubClassInfo(4, 6) end
  if not n and GetItemSubClassInfo then n = GetItemSubClassInfo(4, 6) end
  return n or "Shields"
end
local function F(body, shield)
  body = body:gsub("{SHIELDTYPE}", shield)
  return (body:gsub("{(%u+)}", N))
end
-- Barra 5 de Bartender4 (vertical izquierda): boton 1 = BT4Button49 (2 manos), 2 = BT4Button50 (1 mano), 3 = BT4Button51 (escudo)
local EQUIP_1H_SHIELD = "/click BT4Button50\n/click BT4Button51\n"
-- Igual, pero solo si no llevas escudo puesto (no vuelve a equipar en cada pulsacion)
local EQUIP_IF_NO_SHIELD = "/click [noworn:{SHIELDTYPE}] BT4Button50\n/click [noworn:{SHIELDTYPE}] BT4Button51\n"

-- Opener depende del nivel: antes de Vanguard hay que pasar por Battle Stance para cargar.
local function OpenerBody()
  if (UnitLevel("player") or 1) >= VANGUARD_LEVEL then
    return "#showtooltip\n/cast [nostance:2] {DEF}\n/cast [nocombat] {CHARGE}; {INTERCEPT}\n/startattack"
  end
  return "#showtooltip {CHARGE}\n/cast [nocombat,nostance:1] {BATTLE}\n/cast [nocombat] {CHARGE}\n/cast [combat,nostance:2] {DEF}\n/startattack"
end

-- Execute no se puede usar en Defensive. Guia de Cliptis: Battle Stance hasta el 29, Berserker desde el 30.
local BERSERKER_LEVEL = 30
local function ExecuteBody()
  local stance = (UnitLevel("player") or 1) >= BERSERKER_LEVEL and "{BERSERKER}" or "{BATTLE}"
  return "#showtooltip {EXECUTE}\n/startattack\n/cast [stance:2] "..stance.."; {EXECUTE}"
end

-- Las macros se agrupan con un prefijo, porque la ventana /macro las ordena alfabeticamente:
--   C = Comun (sirven a tanque y a DPS)  ·  D = DPS (Armas/Furia)  ·  P = Proteccion (tanque)
-- old = nombre anterior: si existe, se RENOMBRA (EditMacro) en vez de crear otra, asi sigue en tus barras.
local MACROS = {
  -- ===== P · PROTECCION (tanque, guia de Cliptis) =====
  {"P Opener",      OpenerBody, old="Opener"},
  {"P Main",        "#showtooltip {REVENGE}\n/cast [nostance:2] {DEF}\n/cast {SBLOCK}\n/cast {REVENGE}\n/startattack", old="Main"},
  {"P Block",       "#showtooltip {SBLOCK}\n"..EQUIP_IF_NO_SHIELD.."/cast [nostance:2] {DEF}\n/cast [worn:{SHIELDTYPE}] {SBLOCK}", old="Block"},
  {"P Kick",        "#showtooltip {SBASH}\n"..EQUIP_IF_NO_SHIELD.."/cast [stance:3] {DEF}; [@mouseover,harm,nodead][] {SBASH}\n/startattack", old="Kick"},
  {"P Provocar MO", "#showtooltip {TAUNT}\n/cast [nostance:2] {DEF}; [@mouseover,harm,nodead][] {TAUNT}", old="G Provocar MO"},
  {"P Mock",        "#showtooltip {MOCK}\n/cast [nostance:1] {BATTLE}; {MOCK}", old="Mock"},
  {"P MuroEscudo",  "#showtooltip {SWALL}\n"..EQUIP_IF_NO_SHIELD.."/cast [nostance:2] {DEF}\n/cast {SWALL}", old="G MuroEscudo"},
  {"P Desarmar",    "#showtooltip {DISARM}\n/cast [nostance:2] {DEF}\n/cast {DISARM}", old="G Desarmar"},

  -- ===== C · COMUN (las usan las dos specs) =====
  -- icon 132342 = icono de Victory Rush: se ve aunque aun no lo hayas aprendido (nivel 20)
  {"C Rush",        "#showtooltip {VRUSH}\n/targetenemy [noexists][dead]\n/cast {VRUSH}", old="Rush", icon=132342},
  {"C Desgarrar",   "#showtooltip {REND}\n/startattack\n/cast [stance:3] {DEF}; [@mouseover,harm,nodead] {REND}; {REND}", old="G Desgarrar"},
  {"C Ejecutar",    ExecuteBody, old="G Ejecutar"},
  {"C Seccionar",   "#showtooltip {HAMSTRING}\n/startattack\n/cast [nostance:1,nostance:3] {BATTLE}\n/cast {HAMSTRING}", old="G Seccionar"},
  {"C Torbellino",  "#showtooltip {WW}\n/startattack\n/cast [nostance:3] {BERSERKER}\n/cast {WW}", old="G Torbellino"},
  {"C GolpeHeroic", "#showtooltip {HS}\n/startattack\n/cast {HS}", old="G GolpeHeroic"},
  {"C Grito MO",    "#showtooltip {ISHOUT}\n/cast [@mouseover,harm,nodead][] {ISHOUT}", old="G Grito MO"},
  {"C Arma 2M",     "#showtooltip\n/click BT4Button49", old="G Arma 2M", icon="INV_Sword_04"},
  {"C 1M+Escudo",   "#showtooltip\n"..EQUIP_1H_SHIELD, old="G 1M+Escudo", icon="INV_Shield_06"},

  -- ===== D · DPS (Armas/Furia, guia de Phobyac) =====
  {"D Abrumar",     "#showtooltip {BATTLE}\n/cast [nostance:1] {BATTLE}\n/cast {OVERPOWER}\n/cast {CHARGE}\n/startattack", old="G Abrumar"},
  {"D GolpeMortal", "#showtooltip {MS}\n/startattack\n/cast {MS}", old="G GolpeMortal"},
  {"D Barrido",     "#showtooltip {SWEEP}\n/startattack\n/cast {SWEEP}", old="G Barrido"},
  {"D IraRabiosa",  "#showtooltip {BRAGE}\n/cast [nostance:3] {BERSERKER}\n/cast {BRAGE}", old="G IraRabiosa"},
  {"D Zurrar",      "#showtooltip {PUMMEL}\n/cast [nostance:3] {BERSERKER}\n/cast {PUMMEL}", old="G Zurrar"},
  {"D Represalia",  "#showtooltip {RETAL}\n/cast [nostance:1] {BATTLE}\n/cast {RETAL}", old="G Represalia"},
  {"D Temeridad",   "#showtooltip {RECK}\n/cast [nostance:3] {BERSERKER}\n/cast {RECK}", old="G Temeridad"},
}

-- Macros antiguas que hacen casi lo mismo que una del set de tanque: se borran del juego.
local REMOVE = {
  "G Revancha",     -- = Main
  "G BloqEscudo",   -- = Block
  "G AzoteEscudo",  -- = Kick
  "G Intercept",    -- = Opener (nivel 30+ lanza Intercept sin salir de Defensive)
}

-- Compara ignorando \r, espacios al final de cada linea y saltos de linea finales
local function norm(s)
  s = (s or ""):gsub("\r", ""):gsub("[ \t]+\n", "\n"):gsub("%s+$", "")
  return s
end
local function same(a, b)
  return norm(a) == norm(b)
end

local PREFIX = "|cffc79c6eWarriorMacroAddon|r: "

-- Pasada de SOLO LECTURA: calcula que hay que cambiar sin tocar ninguna macro.
local function Plan(verbose)
  wipe(fallback)
  wipe(nameCache)
  local shield = ShieldType()   -- una vez por pasada
  local ops = {}
  for _, name in ipairs(REMOVE) do
    if GetMacroIndexByName(name) ~= 0 then ops[#ops+1] = {kind="remove", name=name} end
  end
  -- Solo se toca una macro si falta, tiene nombre antiguo o su contenido es distinto al de este archivo.
  for _, m in ipairs(MACROS) do
    local name = m[1]:sub(1, 16)
    local raw = type(m[2]) == "function" and m[2]() or m[2]
    local body = F(raw, shield)
    local icon = m.icon or 134400
    local idx = GetMacroIndexByName(name)
    if idx ~= 0 then
      local _, _, curBody = GetMacroInfo(idx)
      if not same(curBody, body) then
        ops[#ops+1] = {kind="edit", name=name, icon=icon, body=body}
        if verbose then print(PREFIX.."se actualizara '"..name.."'") end
      end
    elseif m.old and GetMacroIndexByName(m.old) ~= 0 then
      ops[#ops+1] = {kind="rename", old=m.old, name=name, icon=icon, body=body}
    else
      ops[#ops+1] = {kind="create", name=name, icon=icon, body=body}
    end
  end
  return ops
end

local pending, running = false, false
local queue, count, verboseRun = {}, nil, false
local f = CreateFrame("Frame")

-- Mientras haya algo pendiente se escuchan estos eventos; si no, ninguno (nada se ejecuta en combate ni en mazmorras).
local function SetPending()
  pending = true
  -- Dentro de una instancia no sirve esperar al fin de combate: solo al cambio de zona.
  if IsInInstance() then f:UnregisterEvent("PLAYER_REGEN_ENABLED") else f:RegisterEvent("PLAYER_REGEN_ENABLED") end
  f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  f:RegisterEvent("PLAYER_ENTERING_WORLD")
end
local function ClearPending()
  pending = false
  f:UnregisterEvent("PLAYER_REGEN_ENABLED")
  f:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
  f:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

local function Finish()
  running = false
  local c = count
  local changed = c.made + c.updated + c.renamed + c.removed + c.skipped > 0
  if changed then
    print((PREFIX.."%d creadas, %d actualizadas, %d renombradas, %d repetidas borradas%s."):format(c.made, c.updated, c.renamed, c.removed,
      c.skipped > 0 and (", |cffff5555"..c.skipped.." fallaron (sin hueco de macro)|r") or ""))
  elseif verboseRun then
    print(PREFIX.."las macros ya estan al dia, no hay nada que cambiar.")
  end
  local loc = GetLocale and GetLocale() or "enUS"
  if (changed or verboseRun) and loc ~= "enUS" and loc ~= "enGB" and next(fallback) then
    local list = {}
    for k in pairs(fallback) do list[#list+1] = EN[k] end
    table.sort(list)
    print(PREFIX.."|cffffaa00sin traduccion en este cliente:|r "..table.concat(list, ", ")
      ..". Si aun no tienes ese hechizo es normal; si ya lo tienes, edita la macro y escribe su nombre en espanol.")
  end
end

local function Apply(op)
  if op.kind == "remove" then
    local idx = GetMacroIndexByName(op.name)
    if idx ~= 0 and pcall(DeleteMacro, idx) then count.removed = count.removed + 1 end
  elseif op.kind == "edit" then
    local idx = GetMacroIndexByName(op.name)
    if idx ~= 0 and pcall(EditMacro, idx, op.name, op.icon, op.body) then count.updated = count.updated + 1 end
  elseif op.kind == "rename" then
    -- Renombrar conserva la macro en las barras de accion
    local idx = GetMacroIndexByName(op.old)
    if idx ~= 0 and pcall(EditMacro, idx, op.name, op.icon, op.body) then count.renamed = count.renamed + 1 end
  else
    local ok = pcall(CreateMacro, op.name, op.icon, op.body, true)   -- true = macro del personaje
    if not ok then ok = pcall(CreateMacro, op.name, op.icon, op.body, nil) end -- si no cabe, general
    if ok then count.made = count.made + 1 else count.skipped = count.skipped + 1 end
  end
end

-- Una escritura por tick: cada una dispara UPDATE_MACROS y las barras (Bartender4...) se refrescan;
-- repartirlas evita un pico de CPU en un solo frame.
local function Step()
  if InCombatLockdown() or IsInInstance() then
    -- Se interrumpe; la siguiente pasada recalcula lo que falte.
    running = false
    wipe(queue)
    SetPending()
    return
  end
  Apply(table.remove(queue, 1))
  if #queue > 0 then C_Timer.After(0.05, Step) else Finish() end
end

-- Devuelve true si se ha lanzado (o no habia nada que hacer), o el motivo por el que no: "combat", "instance", "busy".
local function Run(verbose)
  if running then return "busy" end
  if InCombatLockdown() then SetPending() return "combat" end
  if IsInInstance() then SetPending() return "instance" end
  count = {made=0, updated=0, renamed=0, skipped=0, removed=0}
  verboseRun = verbose and true or false
  local ops = Plan(verbose)
  if #ops == 0 then Finish() return true end
  queue, running = ops, true
  Step()
  return true
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LEVEL_UP")
local firstLoad = true
f:SetScript("OnEvent", function(self, event, arg1)
  if event == "PLAYER_LEVEL_UP" then
    -- 25: Opener pasa a la version con Vanguard. 30: C Ejecutar pasa a Berserker Stance.
    if arg1 == VANGUARD_LEVEL or arg1 == BERSERKER_LEVEL then C_Timer.After(1, function() Run() end) end
  elseif event == "PLAYER_ENTERING_WORLD" and firstLoad then
    firstLoad = false
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    C_Timer.After(5, function() Run() end)
  elseif pending then
    -- Fin de combate o cambio de zona: se reintenta con un margen para no coincidir con la carga.
    ClearPending()
    C_Timer.After(event == "PLAYER_REGEN_ENABLED" and 1 or 5, function() Run() end)
  end
end)
SLASH_WARRIORMACROS1 = "/warriormacros"
SlashCmdList.WARRIORMACROS = function()
  local r = Run(true)
  if r == "combat" then print(PREFIX.."estas en combate; lo hare al salir.")
  elseif r == "instance" then print(PREFIX.."estas en una mazmorra o banda; lo hare al salir.")
  elseif r == "busy" then print(PREFIX.."ya estoy actualizando las macros.") end
end
