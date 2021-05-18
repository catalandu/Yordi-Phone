function adgetAd (accountId, cb)
  if accountId == nil then
    MySQL.Async.fetchAll([===[
	SELECT * FROM `yordi_ads` ORDER BY `yordi_ads`.`id` DESC
      ]===], {}, cb)
  end
end

function adgetUser(phone_number, firstname, cb)
  MySQL.Async.fetchAll("SELECT firstname, phone_number FROM users WHERE users.firstname = @firstname AND users.phone_number = @phone_number", {
    ['@phone_number'] = phone_number,
	  ['@firstname'] = firstname
  }, function (data)
    cb(data[1])
  end)
end

function adnewAd (phone_number, firstname, lastname, message, sourcePlayer, cb)
    adgetUser(phone_number, firstname, function (user)
    if user == nil then
      if sourcePlayer ~= nil then
        TwitterShowError(sourcePlayer, 'Twitter Info', 'APP_TWITTER_NOTIF_LOGIN_ERROR')
      end
      return
    end
    MySQL.Async.insert("INSERT INTO yordi_ads (`phone_number`, `firstname`, `lastname`, `message`) VALUES(@phone_number, @firstname, @lastname, @message);", {
	  ['@phone_number'] = phone_number,
	  ['@firstname'] = firstname,
	  ['@lastname'] = lastname,
      ['@message'] = message
    }, function (id)
      MySQL.Async.fetchAll('SELECT * from yordi_ads WHERE id = @id', {
        ['@id'] = id
      }, function (getAd)
        getAd = getAd[1]
        getAd['firstname'] = user.firstname
        getAd['phone_number'] = user.phone_number
        TriggerClientEvent('yordi-phone:ad_newAd', -1, getAd)
        TriggerEvent('yordi-phone:ad_newAd', getAd)
      end)
    end)
  end)
end

function YellowShowError (sourcePlayer, title, message)
  TriggerClientEvent('yordi-phone:yellow_showError', sourcePlayer, message)
end
function YellowShowSuccess (sourcePlayer, title, message)
  TriggerClientEvent('yordi-phone:yellow_showSuccess', sourcePlayer, title, message)
end

function getIdentity(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local identity = result[1]

		return {
			identifier = identity['identifier'],
			firstname = identity['firstname'],
			lastname = identity['lastname'],
			phone_number = identity['phone_number'],
		}
	else
		return nil
	end
end

RegisterServerEvent('yordi-phone:ad_newAd')
AddEventHandler('yordi-phone:ad_newAd', function(firstname, phone_number, lastname, message)
  local sourcePlayer = tonumber(source)
  local name = getIdentity(source)
  adnewAd(name.phone_number, name.firstname, name.lastname, message, sourcePlayer)
end)

RegisterServerEvent('yordi-phone:ad_getPages')
AddEventHandler('yordi-phone:ad_getPages', function(phone_number, firstname)
  local sourcePlayer = tonumber(source)
  if phone_number ~= nil and phone_number ~= "" and firstname ~= nil and firstname ~= "" then
    adgetUser(phone_number, firstname, function (user)
      local accountId = user and user.id
      adgetAd(accountId, function (getAd)
        TriggerClientEvent('yordi-phone:ad_getPages', sourcePlayer, getAd)
      end)
    end)
  else
    adgetAd(nil, function (getAd)
      TriggerClientEvent('yordi-phone:ad_getPages', sourcePlayer, getAd)
    end)
  end
end)

AddEventHandler('yordi-phone:ad_newAd', function(getAd)
  local yordiwebhook = 'Your Webhook Here'

  local connect = {
    {
        ["color"] = 16753920,
        ["title"] = "Ads",
        ["description"] = "Person posting: __" .. getAd.firstname .. " " .. getAd.lastname .. "__\n Ad message: __" .. getAd.message .. "__\nPhone of the advertiser: __" .. getAd.phone_number .. "__",
        ["footer"] = {
          ["text"] = "by Yordi",
      },
    }
  }

  PerformHttpRequest(yordiwebhook, function(err, text, headers) end, 'POST', json.encode({username = DISCORD_NAME, embeds = connect, avatar_url = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })
end)  --[[  
██╗░░░██╗██████╗░██╗░░░░░███████╗░█████╗░██╗░░██╗░██████╗
██║░░░██║██╔══██╗██║░░░░░██╔════╝██╔══██╗██║░██╔╝██╔════╝
██║░░░██║██████╔╝██║░░░░░█████╗░░███████║█████═╝░╚█████╗░
██║░░░██║██╔═══╝░██║░░░░░██╔══╝░░██╔══██║██╔═██╗░░╚═══██╗
╚██████╔╝██║░░░░░███████╗███████╗██║░░██║██║░╚██╗██████╔╝
░╚═════╝░╚═╝░░░░░╚══════╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░
█████████████████████████████████████████████████████████
discord.gg/6CRxjqZJFB ]]--