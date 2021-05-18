ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

-- Bank // Transfer (server)

RegisterServerEvent('yordi-phone:bankTransfer')
AddEventHandler('yordi-phone:bankTransfer', function(to, amount)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local zPlayer = ESX.GetPlayerFromId(to)
  local balance = 0

    if zPlayer ~= nil then
        balance = xPlayer.getAccount('bank').money
        zbalance = zPlayer.getAccount('bank').money
          if tonumber(_source) == tonumber(to) then
            TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'error', text = 'You cant send money to yourself.' })
          else
            if balance <= 0 or balance < tonumber(amount) or tonumber(amount) <= 0 then
                TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'error', text = 'You dont have enough money for the transfer!'})
            else
                xPlayer.removeAccountMoney('bank', tonumber(amount))
                zPlayer.addAccountMoney('bank', tonumber(amount))
                TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'success', text = '' .. zPlayer .. ' kişisine ' .. amount .. '$ para transferi yaptın!'})
                TriggerClientEvent('mythic_notify:client:SendAlert', to, {type = 'success', text = '' .. xPlayer .. ' kişisinden '  .. amount .. '$ para transferi yapıldı hesabına!'})
            end
        end
    end

end)

-- Bank // Transfer (server)

-- Bank // Fatura (server)

function FaturaGetBilling (accountId, cb)
  local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll([===[
      SELECT * FROM billing WHERE identifier = @identifier
      ]===], { ['@identifier'] = xPlayer.identifier }, cb)
  end 

function getUserFatura(phone_number, firstname, cb)
  MySQL.Async.fetchAll("SELECT firstname, phone_number FROM users WHERE users.firstname = @firstname AND users.phone_number = @phone_number", {
    ['@phone_number'] = phone_number,
	['@firstname'] = firstname
  }, function (data)
    cb(data[1])
  end)
end

RegisterServerEvent('yordi-phone:fatura_getBilling')
AddEventHandler('yordi-phone:fatura_getBilling', function(phone_number, firstname)
  local sourcePlayer = tonumber(source)
  if phone_number ~= nil and phone_number ~= "" and firstname ~= nil and firstname ~= "" then
    getUserFatura(phone_number, firstname, function (user)
      local accountId = user and user.id
      FaturaGetBilling(accountId, function (getFatura)
        TriggerClientEvent('yordi-phone:fatura_getBilling', sourcePlayer, getFatura)
      end)
    end)
  else
    FaturaGetBilling(nil, function (getFatura)
      TriggerClientEvent('yordi-phone:fatura_getBilling', sourcePlayer, getFatura)
    end)
  end
end)

RegisterServerEvent('yordi-phone:payFatura')
AddEventHandler('yordi-phone:payFatura', function(id, sender, amount, target)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local xTarget = ESX.GetPlayerFromIdentifier(sender)

  if xTarget ~= nil then
    if amount ~= nil then
      if xPlayer.getBank() >= amount then

        payFatura(id)
        xPlayer.removeAccountMoney('bank', amount)
        xTarget.addAccountMoney('bank', amount)
        TriggerClientEvent('mythic_notify:client:SendAlert', src, {type = 'success', text = 'You paid the bill ' .. amount .. '$'})
        TriggerClientEvent('mythic_notify:client:SendAlert', sender, {type = 'error', text = 'You cant pay this bill!'})
        TriggerClientEvent('mythic_notify:client:SendAlert', xTarget.source, {type = 'success', text = 'The bill you issued has been paid, ' .. amount .. '$'})
      else
        TriggerClientEvent('mythic_notify:client:SendAlert', src, {type = 'error', text = 'You dont have enough money to pay the bill!'})
      end
    end
  end

end)

function payFatura(id)
  MySQL.Sync.execute("DELETE FROM billing WHERE `id` = @id", {
      ['@id'] = id
  })
end

-- Bank // Fatura (server)  --[[  
██╗░░░██╗██████╗░██╗░░░░░███████╗░█████╗░██╗░░██╗░██████╗
██║░░░██║██╔══██╗██║░░░░░██╔════╝██╔══██╗██║░██╔╝██╔════╝
██║░░░██║██████╔╝██║░░░░░█████╗░░███████║█████═╝░╚█████╗░
██║░░░██║██╔═══╝░██║░░░░░██╔══╝░░██╔══██║██╔═██╗░░╚═══██╗
╚██████╔╝██║░░░░░███████╗███████╗██║░░██║██║░╚██╗██████╔╝
░╚═════╝░╚═╝░░░░░╚══════╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░
█████████████████████████████████████████████████████████
discord.gg/6CRxjqZJFB ]]--