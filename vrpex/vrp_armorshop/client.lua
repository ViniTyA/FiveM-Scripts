vRPas = {}
local Tunnel = module("vrp", "lib/Tunnel")
Tunnel.bindInterface("vrp_armorshop",vRPas)
ASserver = Tunnel.getInterface("vrp_armorshop")

timeout = 0
state_ready = false

function vRPas.getArmour()
  return GetPedArmour(GetPlayerPed(-1))
end

function vRPas.setArmour(armour,vest)
  Citizen.CreateThread(function()
	local player = GetPlayerPed(-1)
	while not state_ready do
	  Citizen.Wait(1)
	end
	if vest and armour > 0 then
	  if IsPedModel(GetPlayerPed(-1),"mp_m_freemode_01") then
	    SetPedComponentVariation(player, 9, 4, 1, 2)  --Bulletproof Vest
	  elseif IsPedModel(GetPlayerPed(-1),"mp_f_freemode_01") then
	      SetPedComponentVariation(player, 9, 6, 1, 2)
	  end
    end
    SetPedArmour(player,armour)
  end)
end

AddEventHandler("playerSpawned",function() -- delay state recording
  state_ready = false
  Citizen.CreateThread(function()
	  timeout = 30
	  while not IsPedModel(GetPlayerPed(-1),"mp_m_freemode_01") and not IsPedModel(GetPlayerPed(-1),"mp_f_freemode_01") and timeout > 0 do
		Citizen.Wait(1)
  	  end
	  state_ready = true
  end)
end)

Citizen.CreateThread(function()
  while true do
    if timeout > 0 then
      timeout = timeout - 1
    end
    Citizen.Wait(1000)
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10000)
    if IsPlayerPlaying(PlayerId()) and state_ready then
      ASserver.updateArmor(vRPas.getArmour())
	  if vRPas.getArmour() == 0 then
	    if IsPedModel(GetPlayerPed(-1),"mp_m_freemode_01") or IsPedModel(GetPlayerPed(-1),"mp_f_freemode_01") then
	      SetPedComponentVariation(GetPlayerPed(-1), 9, 0, 1, 2)
		end
	  end
    end
  end
end)