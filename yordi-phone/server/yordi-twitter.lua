function TwitterGetTweets (accountId, cb)
  if accountId == nil then
    MySQL.Async.fetchAll([===[
      SELECT yordi_twitter_tweets.*,
        yordi_twitter_accounts.username as author,
        yordi_twitter_accounts.avatar_url as authorIcon
      FROM yordi_twitter_tweets
        LEFT JOIN yordi_twitter_accounts
        ON yordi_twitter_tweets.authorId = yordi_twitter_accounts.id
      ORDER BY time DESC LIMIT 130
      ]===], {}, cb)
  else
    MySQL.Async.fetchAll([===[
      SELECT yordi_twitter_tweets.*,
        yordi_twitter_accounts.username as author,
        yordi_twitter_accounts.avatar_url as authorIcon,
        yordi_twitter_likes.id AS isLikes
      FROM yordi_twitter_tweets
        LEFT JOIN yordi_twitter_accounts
          ON yordi_twitter_tweets.authorId = yordi_twitter_accounts.id
        LEFT JOIN yordi_twitter_likes 
          ON yordi_twitter_tweets.id = yordi_twitter_likes.tweetId AND yordi_twitter_likes.authorId = @accountId
      ORDER BY time DESC LIMIT 130
    ]===], { ['@accountId'] = accountId }, cb)
  end
end

function TwitterGetFavotireTweets (accountId, cb)
  if accountId == nil then
    MySQL.Async.fetchAll([===[
      SELECT yordi_twitter_tweets.*,
        yordi_twitter_accounts.username as author,
        yordi_twitter_accounts.avatar_url as authorIcon
      FROM yordi_twitter_tweets
        LEFT JOIN yordi_twitter_accounts
          ON yordi_twitter_tweets.authorId = yordi_twitter_accounts.id
      WHERE yordi_twitter_tweets.TIME > CURRENT_TIMESTAMP() - INTERVAL '15' DAY
      ORDER BY likes DESC, TIME DESC LIMIT 30
    ]===], {}, cb)
  else
    MySQL.Async.fetchAll([===[
      SELECT yordi_twitter_tweets.*,
        yordi_twitter_accounts.username as author,
        yordi_twitter_accounts.avatar_url as authorIcon,
        yordi_twitter_likes.id AS isLikes
      FROM yordi_twitter_tweets
        LEFT JOIN yordi_twitter_accounts
          ON yordi_twitter_tweets.authorId = yordi_twitter_accounts.id
        LEFT JOIN yordi_twitter_likes 
          ON yordi_twitter_tweets.id = yordi_twitter_likes.tweetId AND yordi_twitter_likes.authorId = @accountId
      WHERE yordi_twitter_tweets.TIME > CURRENT_TIMESTAMP() - INTERVAL '15' DAY
      ORDER BY likes DESC, TIME DESC LIMIT 30
    ]===], { ['@accountId'] = accountId }, cb)
  end
end

function getUser(username, password, cb)
  MySQL.Async.fetchAll("SELECT id, username as author, avatar_url as authorIcon FROM yordi_twitter_accounts WHERE yordi_twitter_accounts.username = @username AND yordi_twitter_accounts.password = @password", {
    ['@username'] = username,
    ['@password'] = password
  }, function (data)
    cb(data[1])
  end)
end

function TwitterPostTweet (username, password, message, sourcePlayer, realUser, cb)
  getUser(username, password, function (user)
    if user == nil then
      if sourcePlayer ~= nil then
        TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'error', text = 'There has been a problem with your Twitter account.'})
      end
      return
    end
    MySQL.Async.insert("INSERT INTO yordi_twitter_tweets (`authorId`, `message`, `realUser`) VALUES(@authorId, @message, @realUser);", {
      ['@authorId'] = user.id,
      ['@message'] = message,
      ['@realUser'] = realUser
    }, function (id)
      MySQL.Async.fetchAll('SELECT * from yordi_twitter_tweets WHERE id = @id', {
        ['@id'] = id
      }, function (tweets)
        tweet = tweets[1]
        tweet['author'] = user.author
        tweet['authorIcon'] = user.authorIcon
        TriggerClientEvent('yordi-phone:twitter_newTweets', -1, tweet)
        TriggerEvent('yordi-phone:twitter_newTweets', tweet)
      end)
    end)
  end)
end

function TwitterToogleLike (username, password, tweetId, sourcePlayer)
  getUser(username, password, function (user)
    if user == nil then
      if sourcePlayer ~= nil then
        TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'error', text = 'There has been a problem with your Twitter account.'})
      end
      return
    end
    MySQL.Async.fetchAll('SELECT * FROM yordi_twitter_tweets WHERE id = @id', {
      ['@id'] = tweetId
    }, function (tweets)
      if (tweets[1] == nil) then return end
      local tweet = tweets[1]
      MySQL.Async.fetchAll('SELECT * FROM yordi_twitter_likes WHERE authorId = @authorId AND tweetId = @tweetId', {
        ['authorId'] = user.id,
        ['tweetId'] = tweetId
      }, function (row) 
        if (row[1] == nil) then
          MySQL.Async.insert('INSERT INTO yordi_twitter_likes (`authorId`, `tweetId`) VALUES(@authorId, @tweetId)', {
            ['authorId'] = user.id,
            ['tweetId'] = tweetId
          }, function (newrow)
            MySQL.Async.execute('UPDATE `yordi_twitter_tweets` SET `likes`= likes + 1 WHERE id = @id', {
              ['@id'] = tweet.id
            }, function ()
              TriggerClientEvent('yordi-phone:twitter_updateTweetLikes', -1, tweet.id, tweet.likes + 1)
              TriggerClientEvent('yordi-phone:twitter_setTweetLikes', sourcePlayer, tweet.id, true)
              TriggerEvent('yordi-phone:twitter_updateTweetLikes', tweet.id, tweet.likes + 1)
            end)    
          end)
        else
          MySQL.Async.execute('DELETE FROM yordi_twitter_likes WHERE id = @id', {
            ['@id'] = row[1].id,
          }, function (newrow)
            MySQL.Async.execute('UPDATE `yordi_twitter_tweets` SET `likes`= likes - 1 WHERE id = @id', {
              ['@id'] = tweet.id
            }, function ()
              TriggerClientEvent('yordi-phone:twitter_updateTweetLikes', -1, tweet.id, tweet.likes - 1)
              TriggerClientEvent('yordi-phone:twitter_setTweetLikes', sourcePlayer, tweet.id, false)
              TriggerEvent('yordi-phone:twitter_updateTweetLikes', tweet.id, tweet.likes - 1)
            end)
          end)
        end
      end)
    end)
  end)
end

function TwitterCreateAccount(username, password, avatarUrl, cb)
  MySQL.Async.insert('INSERT IGNORE INTO yordi_twitter_accounts (`username`, `password`, `avatar_url`) VALUES(@username, @password, @avatarUrl)', {
    ['username'] = username,
    ['password'] = password,
    ['avatarUrl'] = avatarUrl
  }, cb)
end

RegisterServerEvent('yordi-phone:twitter_login')
AddEventHandler('yordi-phone:twitter_login', function(username, password)
  local sourcePlayer = tonumber(source)
  getUser(username, password, function (user)
    if user == nil then
      TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'error', text = 'An error occurred while logging into your Twitter account.'})
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'success', text = 'You have successfully logged into your Twitter account.'})
      TriggerClientEvent('yordi-phone:twitter_setAccount', sourcePlayer, username, password, user.authorIcon)
    end
  end)
end)

RegisterServerEvent('yordi-phone:twitter_changePassword')
AddEventHandler('yordi-phone:twitter_changePassword', function(username, password, newPassword)
  local sourcePlayer = tonumber(source)
  getUser(username, password, function (user)
    if user == nil then
      TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'error', text = 'An error occurred while changing the password.'})
    else
      MySQL.Async.execute("UPDATE `yordi_twitter_accounts` SET `password`= @newPassword WHERE yordi_twitter_accounts.username = @username AND yordi_twitter_accounts.password = @password", {
        ['@username'] = username,
        ['@password'] = password,
        ['@newPassword'] = newPassword
      }, function (result)
        if (result == 1) then
          TriggerClientEvent('yordi-phone:twitter_setAccount', sourcePlayer, username, newPassword, user.authorIcon)
          TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'success', text = 'Password has been changed successfully.'})
        else
          TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'error', text = 'An error occurred while changing the password.'})
        end
      end)
    end
  end)
end)


RegisterServerEvent('yordi-phone:twitter_createAccount')
AddEventHandler('yordi-phone:twitter_createAccount', function(username, password, avatarUrl)
  local sourcePlayer = tonumber(source)
  TwitterCreateAccount(username, password, avatarUrl, function (id)
    if (id ~= 0) then
      TriggerClientEvent('yordi-phone:twitter_setAccount', sourcePlayer, username, password, avatarUrl)
      TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'success', text = 'Your Twitter account has been successfully created.'})
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'error', text = 'There was an error creating your Twitter account.'})
    end
  end)
end)

RegisterServerEvent('yordi-phone:twitter_getTweets')
AddEventHandler('yordi-phone:twitter_getTweets', function(username, password)
  local sourcePlayer = tonumber(source)
  if username ~= nil and username ~= "" and password ~= nil and password ~= "" then
    getUser(username, password, function (user)
      local accountId = user and user.id
      TwitterGetTweets(accountId, function (tweets)
        TriggerClientEvent('yordi-phone:twitter_getTweets', sourcePlayer, tweets)
      end)
    end)
  else
    TwitterGetTweets(nil, function (tweets)
      TriggerClientEvent('yordi-phone:twitter_getTweets', sourcePlayer, tweets)
    end)
  end
end)

RegisterServerEvent('yordi-phone:twitter_getFavoriteTweets')
AddEventHandler('yordi-phone:twitter_getFavoriteTweets', function(username, password)
  local sourcePlayer = tonumber(source)
  if username ~= nil and username ~= "" and password ~= nil and password ~= "" then
    getUser(username, password, function (user)
      local accountId = user and user.id
      TwitterGetFavotireTweets(accountId, function (tweets)
        TriggerClientEvent('yordi-phone:twitter_getFavoriteTweets', sourcePlayer, tweets)
      end)
    end)
  else
    TwitterGetFavotireTweets(nil, function (tweets)
      TriggerClientEvent('yordi-phone:twitter_getFavoriteTweets', sourcePlayer, tweets)
    end)
  end
end)

RegisterServerEvent('yordi-phone:twitter_postTweets')
AddEventHandler('yordi-phone:twitter_postTweets', function(username, password, message)
  local sourcePlayer = tonumber(source)
  local srcIdentifier = getPlayerID(source)
  TwitterPostTweet(username, password, message, sourcePlayer, srcIdentifier)
end)

RegisterServerEvent('yordi-phone:twitter_toogleLikeTweet')
AddEventHandler('yordi-phone:twitter_toogleLikeTweet', function(username, password, tweetId)
  local sourcePlayer = tonumber(source)
  TwitterToogleLike(username, password, tweetId, sourcePlayer)
end)


RegisterServerEvent('yordi-phone:twitter_setAvatarUrl')
AddEventHandler('yordi-phone:twitter_setAvatarUrl', function(username, password, avatarUrl)
  local sourcePlayer = tonumber(source)
  MySQL.Async.execute("UPDATE `yordi_twitter_accounts` SET `avatar_url`= @avatarUrl WHERE yordi_twitter_accounts.username = @username AND yordi_twitter_accounts.password = @password", {
    ['@username'] = username,
    ['@password'] = password,
    ['@avatarUrl'] = avatarUrl
  }, function (result)
    if (result == 1) then
      TriggerClientEvent('yordi-phone:twitter_setAccount', sourcePlayer, username, password, avatarUrl)
      TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'success', text = 'Avatar başarıyla değiştirildi.'})
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', sourcePlayer, { type = 'error', text = 'Yapmış olduğun işlem için twitter hesabının olması gerekiyor.'})
    end
  end)
end)

AddEventHandler('yordi-phone:twitter_newTweets', function (tweet)
  local discord_webhook = GetConvar('discord_webhook', 'Your Webhook Here')
  if discord_webhook == '' then
    return
  end
  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = tweet.author,
    ["embeds"] = {{
      ["thumbnail"] = {
        ["url"] = tweet.authorIcon
      },
      ["color"] = 1942002,
      ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ", tweet.time / 1000 )
    }}
  }
  local isHttp = string.sub(tweet.message, 0, 7) == 'http://' or string.sub(tweet.message, 0, 8) == 'https://'
  local ext = string.sub(tweet.message, -4)
  local isImg = ext == '.png' or ext == '.pjg' or ext == '.gif' or string.sub(tweet.message, -5) == '.jpeg'
  data['embeds'][1]['image'] = { ['url'] = tweet.message }
  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

AddEventHandler('yordi-phone:twitter_newTweets', function(tweet)
  local yordiwebhook = 'Your Webhook Here'

  local connect = {
    {
        ["color"] = 1942002,
        ["title"] = "Twitter",
        ["description"] = "The person who tweeted: __" .. tweet.author .. "__\n Tweet message: __" .. tweet.message .. "__\n Steam hex: __" .. tweet.realUser .. "__",
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