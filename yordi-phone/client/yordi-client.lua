local KeyToucheCloseEvent = {
    { code = 172, event = 'ArrowUp' },
    { code = 173, event = 'ArrowDown' },
    { code = 174, event = 'ArrowLeft' },
    { code = 175, event = 'ArrowRight' },
    { code = 176, event = 'Enter' },
    { code = 177, event = 'Backspace' },
  }
  
  local KeyOpenClose = 288 -- F2
  local KeyTakeCall = 38 -- E
  local menuIsOpen = false
  local contacts = {}
  local messages = {}
  local myPhoneNumber = ''
  local isDead = false
  local USE_RTC = false
  local useMouse = false
  local ignoreFocus = false
  local takePhoto = false
  local hasFocus = false
  local PhoneInCall = {}
  local currentPlaySound = false
  local soundDistanceMax = 8.0
  local TokoVoipID = nil
  
  ESX = nil
  
  Citizen.CreateThread(function()
          while ESX == nil do
                  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                  Citizen.Wait(0)
          end
  end)
  
  function hasPhone (cb)
    cb(true)
  end
  
  RegisterNetEvent('yordi:phoneOpen')
  AddEventHandler('yordi:phoneOpen', function()
    TooglePhone()
  end)
  
  function ShowNoPhoneWarning()
    if (ESX == nil) then return end
    --add mythic to frikking config or something idk lol
    exports['mythic_notify']:SendAlert('error', 'Something Wrong')
  end
  
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)
      if takePhoto ~= true then
        if IsControlJustPressed(1, KeyOpenClose) then
          ESX.TriggerServerCallback('gcphone:getItemAmount', function(qtty)
            if qtty > 0 then

              TooglePhone()
            else
             ShowNoPhoneWarning()
            end
          end, 'phone')
        end
        if menuIsOpen == true then
          for _, value in ipairs(KeyToucheCloseEvent) do
            if IsControlJustPressed(1, value.code) then
              SendNUIMessage({keyUp = value.event})
            end
          end
          if useMouse == true and hasFocus == ignoreFocus then
            local nuiFocus = not hasFocus
            SetNuiFocus(nuiFocus, nuiFocus)
            hasFocus = nuiFocus
          elseif useMouse == false and hasFocus == true then
            SetNuiFocus(false, false)
            hasFocus = false
          end
        else
          if hasFocus == true then
            SetNuiFocus(false, false)
            hasFocus = false
          end
        end
      end
    end
  end)
  
  RegisterNetEvent('yordi-phone:setEnableApp')
  AddEventHandler('yordi-phone:setEnableApp', function(appName, enable)
    SendNUIMessage({event = 'setEnableApp', appName = appName, enable = enable })
  end)
  
  function startFixeCall (fixeNumber)
    local number = ''
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 10)
    while (UpdateOnscreenKeyboard() == 0) do
      DisableAllControlActions(0);
      Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
      number =  GetOnscreenKeyboardResult()
    end
    if number ~= '' then
      TriggerEvent('yordi-phone:autoCall', number, {
        useNumber = fixeNumber
      })
      PhonePlayCall(true)
    end
  end
  
  function TakeAppel (infoCall)
    TriggerEvent('yordi-phone:autoAcceptCall', infoCall)
  end
  
  RegisterNetEvent("yordi-phone:notifyFixePhoneChange")
  AddEventHandler("yordi-phone:notifyFixePhoneChange", function(_PhoneInCall)
    PhoneInCall = _PhoneInCall
  end)
  
  function showFixePhoneHelper (coords)
    for number, data in pairs(FixePhone) do
      local dist = GetDistanceBetweenCoords(
        data.coords.x, data.coords.y, data.coords.z,
        coords.x, coords.y, coords.z, 1)
      if dist <= 2.0 then
        SetTextComponentFormat("STRING")
        AddTextComponentString("~g~" .. data.name .. ' ~o~' .. number .. '~n~~INPUT_PICKUP~~w~ To Use')
        DisplayHelpTextFromStringLabel(0, 0, 0, -1)
        if IsControlJustPressed(1, KeyTakeCall) then
          startFixeCall(number)
        end
        break
      end
    end
  end
  
  Citizen.CreateThread(function ()
    local mod = 0
    while true do
      local playerPed   = PlayerPedId()
      local coords      = GetEntityCoords(playerPed)
      local inRangeToActivePhone = false
      local inRangedist = 0
      for i, _ in pairs(PhoneInCall) do
          local dist = GetDistanceBetweenCoords(
            PhoneInCall[i].coords.x, PhoneInCall[i].coords.y, PhoneInCall[i].coords.z,
            coords.x, coords.y, coords.z, 1)
          if (dist <= soundDistanceMax) then
            DrawMarker(1, PhoneInCall[i].coords.x, PhoneInCall[i].coords.y, PhoneInCall[i].coords.z,
                0,0,0, 0,0,0, 0.1,0.1,0.1, 0,255,0,255, 0,0,0,0,0,0,0)
            inRangeToActivePhone = true
            inRangedist = dist
            if (dist <= 1.5) then
              SetTextComponentFormat("STRING")
              AddTextComponentString("~INPUT_PICKUP~ Pick up")
              DisplayHelpTextFromStringLabel(0, 0, 1, -1)
              if IsControlJustPressed(1, KeyTakeCall) then
                PhonePlayCall(true)
                TakeAppel(PhoneInCall[i])
                PhoneInCall = {}
                StopSoundJS('call.mp3')
              end
            end
            break
          end
      end
      if inRangeToActivePhone == false then
        showFixePhoneHelper(coords)
      end
      if inRangeToActivePhone == true and currentPlaySound == false then
        PlaySoundJS('call.mp3', 0.2 + (inRangedist - soundDistanceMax) / -soundDistanceMax * 0.8 )
        currentPlaySound = true
      elseif inRangeToActivePhone == true then
        mod = mod + 1
        if (mod == 15) then
          mod = 0
          SetSoundVolumeJS('call.mp3', 0.2 + (inRangedist - soundDistanceMax) / -soundDistanceMax * 0.8 )
        end
      elseif inRangeToActivePhone == false and currentPlaySound == true then
        currentPlaySound = false
        StopSoundJS('call.mp3')
      end
      Citizen.Wait(0)
    end
  end)
  
  function PlaySoundJS (sound, volume)
    SendNUIMessage({ event = 'playSound', sound = sound, volume = volume })
  end
  
  function SetSoundVolumeJS (sound, volume)
    SendNUIMessage({ event = 'setSoundVolume', sound = sound, volume = volume})
  end
  
  function StopSoundJS (sound)
    SendNUIMessage({ event = 'stopSound', sound = sound})
  end
  
  RegisterNetEvent("yordi-phone:forceOpenPhone")
  AddEventHandler("yordi-phone:forceOpenPhone", function(_myPhoneNumber)
    if menuIsOpen == false then
      TooglePhone()
    end
  end)
  
  RegisterNetEvent("yordi-phone:myPhoneNumber")
  AddEventHandler("yordi-phone:myPhoneNumber", function(_myPhoneNumber)
    myPhoneNumber = _myPhoneNumber
    SendNUIMessage({event = 'updateMyPhoneNumber', myPhoneNumber = myPhoneNumber})
  end)
  
  RegisterNetEvent("yordi-phone:serverIP")
  AddEventHandler("yordi-phone:serverIP", function(sip)
    SendNUIMessage({ event = 'serverIP', sip = sip })
  end)
  
  RegisterNetEvent("yordi-phone:contactList")
  AddEventHandler("yordi-phone:contactList", function(_contacts)
    SendNUIMessage({event = 'updateContacts', contacts = _contacts})
    contacts = _contacts
  end)
  
  RegisterNetEvent("yordi-phone:allMessage")
  AddEventHandler("yordi-phone:allMessage", function(allmessages)
    SendNUIMessage({event = 'updateMessages', messages = allmessages})
    messages = allmessages
  end)
  
  RegisterNetEvent("yordi-phone:getBourse")
  AddEventHandler("yordi-phone:getBourse", function(bourse)
    SendNUIMessage({event = 'updateBourse', bourse = bourse})
  end)
  
  RegisterNetEvent("yordi-phone:receiveMessage")
  AddEventHandler("yordi-phone:receiveMessage", function(message)
    SendNUIMessage({event = 'newMessage', message = message})
    table.insert(messages, message)
    if message.owner == 0 then
      exports['mythic_notify']:SendAlert('success', 'New message has arrived!')
      PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
      Citizen.Wait(300)
      PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
      Citizen.Wait(300)
      PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
    end
  end)
  
  function addContact(display, num)
      TriggerServerEvent('yordi-phone:addContact', display, num)
  end
  
  function deleteContact(num)
      TriggerServerEvent('yordi-phone:deleteContact', num)
  end
  
  function sendMessage(num, message)
    TriggerServerEvent('yordi-phone:sendMessage', num, message)
  end
  
  function deleteMessage(msgId)
    TriggerServerEvent('yordi-phone:deleteMessage', msgId)
    for k, v in ipairs(messages) do
      if v.id == msgId then
        table.remove(messages, k)
        SendNUIMessage({event = 'updateMessages', messages = messages})
        return
      end
    end
  end
  
  function deleteMessageContact(num)
    TriggerServerEvent('yordi-phone:deleteMessageNumber', num)
  end
  
  function deleteAllMessage()
    TriggerServerEvent('yordi-phone:deleteAllMessage')
  end
  
  function setReadMessageNumber(num)
    TriggerServerEvent('yordi-phone:setReadMessageNumber', num)
    for k, v in ipairs(messages) do
      if v.transmitter == num then
        v.isRead = 1
      end
    end
  end
  
  function requestAllMessages()
    TriggerServerEvent('yordi-phone:requestAllMessages')
  end
  
  function requestAllContact()
    TriggerServerEvent('yordi-phone:requestAllContact')
  end
  
  local aminCall = false
  local inCall = false
  
  RegisterNetEvent("yordi-phone:waitingCall")
  AddEventHandler("yordi-phone:waitingCall", function(infoCall, initiator)
    SendNUIMessage({event = 'waitingCall', infoCall = infoCall, initiator = initiator})
    if initiator == true then
      PhonePlayCall()
      if menuIsOpen == false then
        TooglePhone()
      end
    end
  end)
  
  RegisterNetEvent("yordi-phone:acceptCall")
  AddEventHandler("yordi-phone:acceptCall", function(infoCall, initiator)
    if inCall == false and USE_RTC == false then
      inCall = true
      exports['tokovoip_script']:setPlayerData(GetPlayerName(PlayerId()), "call:channel", infoCall.id + 120, true)
      exports.tokovoip_script:addPlayerToRadio(infoCall.id + 120)
      TokoVoipID = infoCall.id + 120
    end
    if menuIsOpen == false then
      TooglePhone()
    end
    PhonePlayCall()
    SendNUIMessage({event = 'acceptCall', infoCall = infoCall, initiator = initiator})
  end)
  
  RegisterNetEvent("yordi-phone:rejectCall")
  AddEventHandler("yordi-phone:rejectCall", function(infoCall)
    if inCall == true then
      inCall = false
      exports['tokovoip_script']:setPlayerData(GetPlayerName(PlayerId()), "call:channel", 'nil', true)
      exports.tokovoip_script:removePlayerFromRadio(TokoVoipID)
      TokoVoipID = nil
    end
    PhonePlayText()
    SendNUIMessage({event = 'rejectCall', infoCall = infoCall})
  end)
  
  RegisterNetEvent("yordi-phone:historiqueCall")
  AddEventHandler("yordi-phone:historiqueCall", function(historique)
    SendNUIMessage({event = 'historiqueCall', historique = historique})
  end)
  
  function startCall (phone_number, rtcOffer, extraData)
    TriggerServerEvent('yordi-phone:startCall', phone_number, rtcOffer, extraData)
  end
  
  function acceptCall (infoCall, rtcAnswer)
    TriggerServerEvent('yordi-phone:acceptCall', infoCall, rtcAnswer)
  end
  
  function rejectCall(infoCall)
    TriggerServerEvent('yordi-phone:rejectCall', infoCall)
  end
  
  function ignoreCall(infoCall)
    TriggerServerEvent('yordi-phone:ignoreCall', infoCall)
  end
  
  function requestHistoriqueCall()
    TriggerServerEvent('yordi-phone:getHistoriqueCall')
  end
  
  function appelsDeleteHistorique (num)
    TriggerServerEvent('yordi-phone:appelsDeleteHistorique', num)
  end
  
  function appelsDeleteAllHistorique ()
    TriggerServerEvent('yordi-phone:appelsDeleteAllHistorique')
  end
  
  RegisterNUICallback('startCall', function (data, cb)
    startCall(data.numero, data.rtcOffer, data.extraData)
    cb()
  end)
  
  RegisterNUICallback('acceptCall', function (data, cb)
    acceptCall(data.infoCall, data.rtcAnswer)
    cb()
  end)
  RegisterNUICallback('rejectCall', function (data, cb)
    rejectCall(data.infoCall)
    cb()
  end)
  
  RegisterNUICallback('ignoreCall', function (data, cb)
    ignoreCall(data.infoCall)
    cb()
  end)
  
  RegisterNUICallback('notififyUseRTC', function (use, cb)
    USE_RTC = use
    if USE_RTC == true and inCall == true then
      inCall = false
      exports['tokovoip_script']:setPlayerData(GetPlayerName(PlayerId()), "call:channel", 'nil', true)
      exports.tokovoip_script:removePlayerFromRadio(TokoVoipID)
      TokoVoipID = nil
    end
    cb()
  end)
  
  RegisterNUICallback('onCandidates', function (data, cb)
    TriggerServerEvent('yordi-phone:candidates', data.id, data.candidates)
    cb()
  end)
  
  RegisterNetEvent("yordi-phone:candidates")
  AddEventHandler("yordi-phone:candidates", function(candidates)
    SendNUIMessage({event = 'candidatesAvailable', candidates = candidates})
  end)
  
  RegisterNetEvent('yordi-phone:autoCall')
  AddEventHandler('yordi-phone:autoCall', function(number, extraData)
    if number ~= nil then
      SendNUIMessage({ event = "autoStartCall", number = number, extraData = extraData})
    end
  end)
  
  RegisterNetEvent('yordi-phone:autoCallNumber')
  AddEventHandler('yordi-phone:autoCallNumber', function(data)
    TriggerEvent('yordi-phone:autoCall', data.number)
  end)
  
  RegisterNetEvent('yordi-phone:autoAcceptCall')
  AddEventHandler('yordi-phone:autoAcceptCall', function(infoCall)
    SendNUIMessage({ event = "autoAcceptCall", infoCall = infoCall})
  end)
  
  RegisterNUICallback('log', function(data, cb)
    print(data)
    cb()
  end)
  
  RegisterNUICallback('focus', function(data, cb)
    cb()
  end)
  
  RegisterNUICallback('blur', function(data, cb)
    cb()
  end)
  
  RegisterNUICallback('reponseText', function(data, cb)
    local limit = data.limit or 255
    local text = data.text or ''
  
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", text, "", "", "", limit)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
        text = GetOnscreenKeyboardResult()
    end
    cb(json.encode({text = text}))
  end)
  
  RegisterNUICallback('getMessages', function(data, cb)
    cb(json.encode(messages))
  end)
  
  RegisterNUICallback('sendMessage', function(data, cb)
    if data.message == '%pos%' then
      local myPos = GetEntityCoords(PlayerPedId())
      data.message = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
    end
    TriggerServerEvent('yordi-phone:sendMessage', data.phoneNumber, data.message)
  end)
  
  RegisterNUICallback('deleteMessage', function(data, cb)
    deleteMessage(data.id)
    cb()
  end)
  
  RegisterNUICallback('deleteMessageNumber', function (data, cb)
    deleteMessageContact(data.number)
    cb()
  end)
  
  RegisterNUICallback('deleteAllMessage', function (data, cb)
    deleteAllMessage()
    cb()
  end)
  
  RegisterNUICallback('setReadMessageNumber', function (data, cb)
    setReadMessageNumber(data.number)
    cb()
  end)
  
  RegisterNUICallback('addContact', function(data, cb)
    TriggerServerEvent('yordi-phone:addContact', data.display, data.phoneNumber)
  end)
  
  RegisterNUICallback('updateContact', function(data, cb)
    TriggerServerEvent('yordi-phone:updateContact', data.id, data.display, data.phoneNumber)
  end)
  
  RegisterNUICallback('deleteContact', function(data, cb)
    TriggerServerEvent('yordi-phone:deleteContact', data.id)
  end)
  
  RegisterNUICallback('getContacts', function(data, cb)
    cb(json.encode(contacts))
  end)
  
  RegisterNUICallback('setGPS', function(data, cb)
    SetNewWaypoint(tonumber(data.x), tonumber(data.y))
    cb()
  end)
  
  RegisterNUICallback('callEvent', function(data, cb)
    local eventName = data.eventName or ''
    if string.match(eventName, 'yordi-phone') then
      if data.data ~= nil then
        TriggerEvent(data.eventName, data.data)
      else
        TriggerEvent(data.eventName)
      end
    else
      print('Event not allowed')
    end
    cb()
  end)
  RegisterNUICallback('useMouse', function(um, cb)
    useMouse = um
  end)
  RegisterNUICallback('deleteALL', function(data, cb)
    TriggerServerEvent('yordi-phone:deleteALL')
    cb()
  end)
  
  function TooglePhone()
    menuIsOpen = not menuIsOpen
    SendNUIMessage({show = menuIsOpen})
    if menuIsOpen == true then
      PhonePlayIn()
    else
      PhonePlayOut()
    end
  end
  
  RegisterNUICallback('faketakePhoto', function(data, cb)
    menuIsOpen = false
    SendNUIMessage({show = false})
    cb()
    TriggerEvent('camera:open')
  end)
  
  RegisterNUICallback('closePhone', function(data, cb)
    menuIsOpen = false
    SendNUIMessage({show = false})
    PhonePlayOut()
    cb()
  end)
  
  RegisterNUICallback('appelsDeleteHistorique', function (data, cb)
    appelsDeleteHistorique(data.numero)
    cb()
  end)
  RegisterNUICallback('appelsDeleteAllHistorique', function (data, cb)
    appelsDeleteAllHistorique(data.infoCall)
    cb()
  end)
  
  AddEventHandler('onClientResourceStart', function(res)
    DoScreenFadeIn(300)
    if res == "yordi-phone" then
        TriggerServerEvent('yordi-phone:allUpdate')
    end
  end)
  
  RegisterNUICallback('setIgnoreFocus', function (data, cb)
    ignoreFocus = data.ignoreFocus
    cb()
  end)
  
  RegisterNUICallback('takePhoto', function(data, cb)
          CreateMobilePhone(1)
    CellCamActivate(true, true)
    takePhoto = true
    Citizen.Wait(0)
    if hasFocus == true then
      SetNuiFocus(false, false)
      hasFocus = false
    end
          while takePhoto do
      Citizen.Wait(0)
  
                  if IsControlJustPressed(1, 27) then -- Toogle Mode
                          frontCam = not frontCam
                          CellFrontCamActivate(frontCam)
      elseif IsControlJustPressed(1, 177) then -- CANCEL
        DestroyMobilePhone()
        CellCamActivate(false, false)
        cb(json.encode({ url = nil }))
        takePhoto = false
        break
      elseif IsControlJustPressed(1, 176) then -- TAKE.. PIC
                          exports['screenshot-basic']:requestScreenshotUpload(data.url, data.field, function(data)
          local resp = json.decode(data)
          DestroyMobilePhone()
          CellCamActivate(false, false)
          cb(json.encode({ url = resp.files[1].url }))
        end)
        takePhoto = false
                  end
                  HideHudComponentThisFrame(7)
                  HideHudComponentThisFrame(8)
                  HideHudComponentThisFrame(9)
                  HideHudComponentThisFrame(6)
                  HideHudComponentThisFrame(19)
      HideHudAndRadarThisFrame()
    end
    Citizen.Wait(1000)
    PhonePlayAnim('text', false, true)
  end)  --[[  
██╗░░░██╗██████╗░██╗░░░░░███████╗░█████╗░██╗░░██╗░██████╗
██║░░░██║██╔══██╗██║░░░░░██╔════╝██╔══██╗██║░██╔╝██╔════╝
██║░░░██║██████╔╝██║░░░░░█████╗░░███████║█████═╝░╚█████╗░
██║░░░██║██╔═══╝░██║░░░░░██╔══╝░░██╔══██║██╔═██╗░░╚═══██╗
╚██████╔╝██║░░░░░███████╗███████╗██║░░██║██║░╚██╗██████╔╝
░╚═════╝░╚═╝░░░░░╚══════╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░
█████████████████████████████████████████████████████████
discord.gg/6CRxjqZJFB ]]--