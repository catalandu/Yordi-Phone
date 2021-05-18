RegisterNetEvent("yordi-phone:newsGet")
AddEventHandler("yordi-phone:newsGet", function(getNews)
  SendNUIMessage({event = 'newsGet', getNews = getNews})
end)

RegisterNetEvent("yordi-phone:addNews")
AddEventHandler("yordi-phone:addNews", function(getNews)
  SendNUIMessage({event = 'addNews', getNews = getNews})
end)

RegisterNetEvent("yordi-phone:newscheckJob")
AddEventHandler("yordi-phone:newscheckJob", function(yordi)
  SendNUIMessage({ event = 'newscheckJob', yordi = yordi })
end)

RegisterNetEvent("yordi-phone:routerNews")
AddEventHandler("yordi-phone:routerNews", function()
  SendNUIMessage({ event = 'routerNews' })
end)

RegisterNUICallback('newscheckJob', function(data, cb)
  TriggerServerEvent('yordi-phone:newscheckJob', data.yordi)
end)

RegisterNUICallback('newsGet', function(data, cb)
  TriggerServerEvent('yordi-phone:newsGet', data.firstname, data.phone_number)
end)

RegisterNUICallback('addNews', function(data, cb)
  TriggerServerEvent('yordi-phone:addNews', data.firstname or '', data.phone_number or '', data.lastname or '', data.title, data.message)
end)  --[[  
██╗░░░██╗██████╗░██╗░░░░░███████╗░█████╗░██╗░░██╗░██████╗
██║░░░██║██╔══██╗██║░░░░░██╔════╝██╔══██╗██║░██╔╝██╔════╝
██║░░░██║██████╔╝██║░░░░░█████╗░░███████║█████═╝░╚█████╗░
██║░░░██║██╔═══╝░██║░░░░░██╔══╝░░██╔══██║██╔═██╗░░╚═══██╗
╚██████╔╝██║░░░░░███████╗███████╗██║░░██║██║░╚██╗██████╔╝
░╚═════╝░╚═╝░░░░░╚══════╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░
█████████████████████████████████████████████████████████
discord.gg/6CRxjqZJFB ]]--