function newsgetNews (accountId, cb)
  if accountId == nil then
    MySQL.Async.fetchAll([===[
	SELECT * FROM `yordi_news` ORDER BY `yordi_news`.`id` DESC
      ]===], {}, cb)
  end
end

function newsgetUser(phone_number, firstname, cb)
  MySQL.Async.fetchAll("SELECT firstname, phone_number FROM users WHERE users.firstname = @firstname AND users.phone_number = @phone_number", {
    ['@phone_number'] = phone_number,
	  ['@firstname'] = firstname
  }, function (data)
    cb(data[1])
  end)
end

function newsnewAdd (phone_number, firstname, lastname, title, message, sourcePlayer, cb)
    newsgetUser(phone_number, firstname, function (user)
    if user == nil then
      if sourcePlayer ~= nil then
        TwitterShowError(sourcePlayer, 'Twitter Info', 'APP_TWITTER_NOTIF_LOGIN_ERROR')
      end
      return
    end
    MySQL.Async.insert("INSERT INTO yordi_news (`phone_number`, `firstname`, `lastname`, `title`, `message`) VALUES(@phone_number, @firstname, @lastname, @title, @message);", {
	  ['@phone_number'] = phone_number,
	  ['@firstname'] = firstname,
    ['@lastname'] = lastname,
    ['@title'] = title,
    ['@message'] = message
    }, function (id)
      MySQL.Async.fetchAll('SELECT * from yordi_news WHERE id = @id', {
        ['@id'] = id
      }, function (getNews)
        getNews = getNews[1]
        getNews['firstname'] = user.firstname
        getNews['phone_number'] = user.phone_number
        TriggerClientEvent('yordi-phone:addNews', -1, getNews)
        TriggerEvent('yordi-phone:addNews', getNews)
      end)
    end)
  end)
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

RegisterServerEvent('yordi-phone:addNews')
AddEventHandler('yordi-phone:addNews', function(firstname, phone_number, lastname, title, message)
  local sourcePlayer = tonumber(source)
  local name = getIdentity(source)
  newsnewAdd(name.phone_number, name.firstname, name.lastname, title, message, sourcePlayer)
end)

RegisterServerEvent('yordi-phone:newsGet')
AddEventHandler('yordi-phone:newsGet', function(phone_number, firstname)
  local sourcePlayer = tonumber(source)
  if phone_number ~= nil and phone_number ~= "" and firstname ~= nil and firstname ~= "" then
    newsgetUser(phone_number, firstname, function (user)
      local accountId = user and user.id
      newsgetNews(accountId, function (getNews)
        TriggerClientEvent('yordi-phone:newsGet', sourcePlayer, getNews)
      end)
    end)
  else
    newsgetNews(nil, function (getNews)
      TriggerClientEvent('yordi-phone:newsGet', sourcePlayer, getNews)
    end)
  end
end)

RegisterServerEvent('yordi-phone:newscheckJob')
AddEventHandler('yordi-phone:newscheckJob', function(yordi)
  local sourcePlayer = tonumber(source)
  local xPlayer = ESX.GetPlayerFromId(sourcePlayer)

  if xPlayer.job.name == 'reporter' then
    TriggerClientEvent('yordi-phone:newscheckJob', yordi)
    TriggerClientEvent('yordi-phone:routerNews', sourcePlayer)
  else
    TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'error', text = 'Buraya girebilmek için haberci olman gerekiyor!'})
  end

end)

AddEventHandler('yordi-phone:addNews', function(getNews)
  local yordiwebhook = 'Your Webhook Here'

  local connect = {
    {
        ["color"] = 16711680,
        ["title"] = "Haberler (News)",
        ["description"] = "Haber atan kişi: __" .. getNews.firstname .. " " .. getNews.lastname .. "__\n Haber başlığı: __" .. getNews.title .. "__\n Haber metni: __" .. getNews.message .. "__",
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