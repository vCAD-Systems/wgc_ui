--[[
Welchen job braucht man für..?
Falls Feature nicht erwünscht:
Nein = nil
]]
-- Für CopNet:
Config.CopNetJob = { 'police' }
-- Für MedicNet:
Config.MedicNetJob = { 'ambulance' }
-- Für CarNet:
Config.CarNetJob = { 'cardealer', 'mechanic' }
-- Für FDNet:
Config.FireNetJob = { 'fire' }

--[[
Welche Items braucht man um das Tablet öffnen zu können..?
Falls Feature nicht erwünscht:
Nein = nil
]]
--Config.NeededItem = {'tablet'} oder Config.NeededItem = {'tablet', 'tablet2'}
Config.NeededItem = nil

--[[
Soll man das Tablet auch beim *Benutzen* des Items öffnen können?
Diese Funktion funktioniert nur, wenn Config.NeededItem NICHT "nil" ist.
Alle Items aus Config.NeededItem nutzbar = 'all'
bestimmtes Item nutzbar = 'itemname'
Nein = nil
]]
Config.CanUseItem = nil

--[[
Entscheidet welche Form beim *Benutzen* des Items geöffnet wird:
Diese Funktion funktioniert nur, wenn Config.CanUseItem "true" ist.
'tab' für das Tablet
'pc' für den PC
]]
Config.ItemOpenType = 'tab'
