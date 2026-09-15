scriptTitle = "Xefu Auto"
scriptAuthor = "XefuAuto"
scriptVersion = 4
scriptDescription = "Turn automatic per-game xefu switching on or off."
scriptIcon = "icon.png"
scriptPermissions = { "filesystem" }

local COMPAT = "Hddx:\\Compatibility\\"
local BACKUP = COMPAT .. "XefuBackup\\"
local OFF = COMPAT .. "xefu_auto_off.txt"

-- ---------------------------------------------------------------- idioma
local STRINGS = {
	["en"] = {
		on      = "Automatic xefu switching is ON.",
		off     = "Automatic xefu switching is OFF.",
		current = "Current xefu:",
		none    = "none yet",
		turnOn  = "Turn On",
		turnOff = "Turn Off",
		cancel  = "Cancel",
		nowOn   = "Xefu Auto: ON",
		nowOff  = "Xefu Auto: OFF",
	},
	["pt"] = {
		on      = "A troca automatica de xefu esta LIGADA.",
		off     = "A troca automatica de xefu esta DESLIGADA.",
		current = "Xefu atual:",
		none    = "nenhuma ainda",
		turnOn  = "Ligar",
		turnOff = "Desligar",
		cancel  = "Cancelar",
		nowOn   = "Xefu Auto: ligado",
		nowOff  = "Xefu Auto: desligado",
	},
	["es"] = {
		on      = "El cambio automatico de xefu esta ACTIVADO.",
		off     = "El cambio automatico de xefu esta DESACTIVADO.",
		current = "Xefu actual:",
		none    = "ninguna todavia",
		turnOn  = "Activar",
		turnOff = "Desactivar",
		cancel  = "Cancelar",
		nowOn   = "Xefu Auto: activado",
		nowOff  = "Xefu Auto: desactivado",
	},
}

-- le o idioma do Aurora e devolve "en", "pt" ou "es".
-- Aurora/Settings podem nao existir dependendo do contexto, entao tudo
-- passa por pcall e o padrao e ingles.
local function detectLanguage()
	local code = ""

	local function colher(valor)
		if type(valor) == "string" and #valor > 0 then
			return valor
		elseif type(valor) == "table" then
			for _, v in pairs(valor) do
				if type(v) == "string" and #v > 0 then return v end
			end
		end
		return nil
	end

	if code == "" and type(Aurora) == "table" and Aurora.GetCurrentLanguage then
		local ok, info = pcall(Aurora.GetCurrentLanguage)
		if ok then code = colher(info) or "" end
	end

	if code == "" and type(Settings) == "table" and Settings.GetLanguage then
		local ok, info = pcall(Settings.GetLanguage)
		if ok then code = colher(info) or "" end
	end

	code = string.lower(code)
	if string.find(code, "pt", 1, true) then return "pt" end
	if string.find(code, "es", 1, true) then return "es" end
	return "en"
end

local L = STRINGS["en"]
do
	local ok, idioma = pcall(detectLanguage)
	if ok and STRINGS[idioma] then L = STRINGS[idioma] end
end

-- Descobre qual xefu esta REALMENTE carregado, comparando o tamanho de
-- Hddx:\Compatibility\xefu.xex com os originais do XefuBackup.
local CANDIDATOS = {"xefu.xex", "xefu1_1.xex", "xefu2.xex", "xefu3.xex",
                    "xefu5.xex", "xefu6.xex", "xefu7.xex", "xefu7b.xex",
                    "xefu2019.xex", "xefu2021a.xex", "xefu2021b.xex",
                    "xefu2021c.xex"}

local function currentXefu()
	local alvo = COMPAT .. "xefu.xex"
	if not FileSystem.FileExists(alvo) then return L.none end

	local ok, tam = pcall(FileSystem.GetFileSize, alvo)
	if not ok or not tam or tam == 0 then return L.none end

	-- procura no XefuBackup qual original tem exatamente esse tamanho
	local achados = {}
	for i = 1, #CANDIDATOS do
		local orig = BACKUP .. CANDIDATOS[i]
		if FileSystem.FileExists(orig) then
			local ok2, t2 = pcall(FileSystem.GetFileSize, orig)
			if ok2 and t2 == tam then
				achados[#achados + 1] = CANDIDATOS[i]:gsub("%.xex$", "")
			end
		end
	end

	if #achados == 0 then return "? (" .. tostring(tam) .. " bytes)" end
	return table.concat(achados, " / ")
end

-- ----------------------------------------------------------------- toggle
-- Usamos ShowPopupList (e nao ShowMessageBox) porque so a lista devolve
-- ret.Canceled quando o usuario aperta B para voltar.
function main()
	while true do
		local enabled = not FileSystem.FileExists(OFF)

		local opcoes = {
			(enabled and L.on or L.off),
			L.current .. " " .. currentXefu(),
			enabled and L.turnOff or L.turnOn,
		}

		local ret = Script.ShowPopupList("Xefu Auto", L.none, opcoes)

		-- B apertado: volta
		if ret == nil or ret.Canceled == true then return end
		if ret.Selected == nil then return end

		-- so a terceira linha age; as duas primeiras sao informativas
		if ret.Selected.Key == 3 then
			if enabled then
				FileSystem.WriteFile(OFF, "1")
				Script.ShowNotification(L.nowOff)
			else
				FileSystem.DeleteFile(OFF)
				Script.ShowNotification(L.nowOn)
			end
		end
	end
end
