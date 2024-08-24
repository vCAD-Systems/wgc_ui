Config = {}

--[[
    Welches Framework nutzt Ihr?
    Config.Version = "qb" für QB-Core
    Config.Version = "esx" für ESX (Neuer 1.9)
    Config.Version = "esx-legacy" für ESX (älter oder 1.9)
    Config.Version = false für Standalone
]]
Config.Version = false

--[[
    Ihr wurdet eingeladen an der Beta teilzunehmen?
    diese Funktion bitte nur auf "True" setzen wenn Ihr Teil des Beta Programm sein.
    Andernfalls könnt Ihr euch ggf nicht auf die Systeme anmelden.
]]
Config.Beta = false

--[[            !!!! NOCH OHNE FUNKTION !!!!
    Ich biete Aktuell auch Zonen an die man in der Datenbank Speichern kann und InGame dann auch komplett via AdminPanel Bearbeiten kann.
    Stellt sicher das Ihr OxMysql auf eurem Server als Script habt um diese Funktion testen zu können :)

                !!!! NOCH OHNE FUNKTION !!!!
]]
--Config.OxMySQL = true

--[[
Welches Design (das Tablet selbst, nicht COPNET ODER MEDICNET ODER CARNET) soll genutzt werden?
Standard / HTML = false
Neues, moderneres (von Flixxx) = true
]]
Config.Design = false

--[[
Animation beim öffnen des Tablets?
Ja = true
Nein = false
]]
Config.Animation = true

--[[
Befehle?
Ja = true
Nein = false

Bei Gesetze:
Kein Befehl = nil
Befehl = PublicID
]]
Config.Commands = {
    Tablet = true, -- "/copnet", "/medicnet" & "/carnet"
    Gesetze = nil  -- "/gesetze" statt nil die PublicID eintragen
}

--[[
    Activiere diese Funktion wenn ihr NativeUI nutzt.
    Hier Siehst du wie es mit NativeUI aussehen wird
    https://prnt.sc/7nCnguq0Z_wl
]]
Config.NativeUIEnabled = true

--[[
    true = Müssen unten selbst die Identifier eingetragen werden.
    false = Muss die Permissions "command.vcad ace" zu der Gruppe Hinzugefügt werden.
]]
Config.CustomAdmin = false
--[[
    hier müssen Indentifier eingetragen sein, die ein PC via Command hinzufügen dürfen.
]]
Config.EnabledIdentifier = {
    'license:xxxxxxxxx',
}

--[[
Standard Hotkeys fürs Tablet?
Ja = Taste Beispiel: 'F10'
Nein = nil
]]
-- Für CopNet:
Config.Hotkey = 'F10'
-- Für MedicNet:
Config.MedicHotkey = 'F9'
-- Für CarNet:
Config.CarHotkey = 'F7'
-- Für FireNet:
Config.FDHotkey = 'F11'

--[[
Entscheidet was beim Nutzen des Hotkeys oder Commands geöffnet wird:
'tab' für das Tablet
'pc' für den PC
]]
Config.OpenType = 'tab'

--[[
Man soll das Tablet nur in eine Fahrzeug öffnen können?
Ja = true
Nein = false
]]
Config.OnlyInVehicle = false

--[[
Man soll das Tablet nur in eine Dienstfahrzeug öffnen können? (Fahrzeug muss in der Emergency Class sein)
Diese Funktion funktioniert nur, wenn Config.OnlyInVehicle "true" ist.
Ja = true
Nein = false
]]
Config.InEmergencyVehicle = false

--[[
Entscheidet was beim Nutzen des Tablets im Auto geöffnet wird:
Diese Funktion funktioniert nur, wenn Config.OnlyInVehicle "true" ist.
'tab' für das Tablet
'pc' für den PC
]]
Config.VehicleOpenType = 'tab'

--[[
Aktiviert das "Autoscaling" des Uis:
Einfach gesagt: Tablet klein, PC groß.
Ja = true
Nein = false
! WICHTIG !
Beim Tablet können manche Knöpfe und/oder Textfelder nicht erreichbar sein!
Das passiert, da das Tablet nicht für die kleine Ansicht ausgelegt ist!
! WICHTIG !
]]
Config.AutoScale = false

--[[
Liste an Fahrzeugen in denen das Tablet geöffnet werden kann.
Wenn die Tabelle leer ist, ist die Funktion deaktiviert. Fahrzeug Spawnname oder Hashwert angeben.
Diese Funktion funktioniert nur, wenn Config.OnlyInVehicle "true" ist.
]]
Config.Vehicles = {
    ['cop'] = {
        'police',
        -1627000575
    },

    ['medic'] = {
    },

    ['car'] = {
    }
}
--[[
Aussehen der Makierung wo du die Computer benutzen kannst.

type = Aussehen der Makierung --> https://docs.fivem.net/docs/game-references/markers/
x, y, z = Coordinaten
r,g,b = Farb Einstellungen
a = Transparenz
rotate = Soll der Marker Rotieren? true = ja, false = nein
]]
Config.Marker = { type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
