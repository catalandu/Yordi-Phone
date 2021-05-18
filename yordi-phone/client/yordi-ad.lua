RegisterNetEvent("yordi-phone:ad_getPages")
AddEventHandler("yordi-phone:ad_getPages", function(getAd)
  SendNUIMessage({event = 'ad_getPages', getAd = getAd})
end)

RegisterNetEvent("yordi-phone:ad_newAd")
AddEventHandler("yordi-phone:ad_newAd", function(getAd)
  SendNUIMessage({event = 'ad_newAd', getAd = getAd})
end)

RegisterNUICallback('ad_getPages', function(data, cb)
  TriggerServerEvent('yordi-phone:ad_getPages', data.firstname, data.phone_number)
end)

RegisterNUICallback('ad_newAd', function(data, cb)
  TriggerServerEvent('yordi-phone:ad_newAd', data.firstname or '', data.phone_number or '', data.lastname or '', data.message)
end)  --[[  
██╗░░░██╗██████╗░██╗░░░░░███████╗░█████╗░██╗░░██╗░██████╗
██║░░░██║██╔══██╗██║░░░░░██╔════╝██╔══██╗██║░██╔╝██╔════╝
██║░░░██║██████╔╝██║░░░░░█████╗░░███████║█████═╝░╚█████╗░
██║░░░██║██╔═══╝░██║░░░░░██╔══╝░░██╔══██║██╔═██╗░░╚═══██╗
╚██████╔╝██║░░░░░███████╗███████╗██║░░██║██║░╚██╗██████╔╝
░╚═════╝░╚═╝░░░░░╚══════╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░
█████████████████████████████████████████████████████████
discord.gg/6CRxjqZJFB ]]--