SendMessagesToTradeChat = {}

SendMessagesToTradeChat.isRunning = false

local _ = {}

local ticker1
local ticker2
local timer

--- @class ToggleSendingMessagesOptions
--- @field interval number The interval with which the messages are sent again in seconds.
--- @field delay number The delay between the messages in seconds.

--- Toggles sending messages.
--- @param messages string[] The messages to send to the trade chat.
--- @param options ToggleSendingMessagesOptions Options.
function SendMessagesToTradeChat.toggleSendingMessages(messages, options)
  if SendMessagesToTradeChat.isRunning then
    SendMessagesToTradeChat.disableSendingMessages()
  else
    SendMessagesToTradeChat.enableSendingMessages(messages, options)
  end
end

--- @class EnableSendingMessagesOptions
--- @field interval number The interval with which the messages are sent again in seconds.
--- @field delay number The delay between the messages in seconds.

--- Enables sending messages.
--- @param messages string[] The messages to send to the trade chat.
--- @param options ToggleSendingMessagesOptions Options.
function SendMessagesToTradeChat.enableSendingMessages(messages, options)
  if SendMessagesToTradeChat.isRunning then
    error('Sending message to trade chat is already running. Please disable it before enabling it again.')
  else
    options = options or {}
    local interval = options.interval or 5 * 60
    local delay = options.delay or 10

    local numberOfMessages = #messages
    if not (numberOfMessages == 1 or numberOfMessages == 2) then
      error('Only one or two messages are supported. ' .. numberOfMessages .. ' were provided. Please provide only one or two messages.')
      return
    end

    SendMessagesToTradeChat.isRunning = true

    print('Has started sending messages to trade chat.')

    SendMessagesToTradeChat.sendMessageToTradeChat(messages[1])
    ticker1 = C_Timer.NewTicker(interval, function()
      Coroutine.runAsCoroutineImmediately(function()
        _.showPostButton()
        SendMessagesToTradeChat.sendMessageToTradeChat(messages[1])
      end)
    end)
    if #messages >= 2 then
      timer = C_Timer.NewTimer(delay, function()
        Coroutine.runAsCoroutineImmediately(function()
          _.showPostButton()
          SendMessagesToTradeChat.sendMessageToTradeChat(messages[2])
        end)
        ticker2 = C_Timer.NewTicker(interval, function()
          Coroutine.runAsCoroutineImmediately(function()
            _.showPostButton()
            SendMessagesToTradeChat.sendMessageToTradeChat(messages[2])
          end)
        end)
      end)
    end
  end
end

--- Disables sending messages.
function SendMessagesToTradeChat.disableSendingMessages()
  if SendMessagesToTradeChat.isRunning then
    if timer then
      timer:Cancel()
      timer = nil
    end
    ticker1:Cancel()
    ticker1 = nil
    if ticker2 then
      ticker2:Cancel()
      ticker2 = nil
    end
    SendMessagesToTradeChat.isRunning = false
    print('Has stopped sending messages to trade chat.')
  end
end

--- Sends a message to the trade chat.
function SendMessagesToTradeChat.sendMessageToTradeChat(message)
  local tradeChannelID = _.findTradeChannelId() or _G.SendMessagesToTradeChatTradeChannelID
  if tradeChannelID then
    -- SendChatMessage(message, 'CHANNEL', nil, tradeChannelID)
    print(message, tradeChannelID)
  else
    error('Could not find the trade channel automatically. You can specify the trade channel ID with "/run SendMessagesToTradeChatTradeChannelID = 2" (replace 2 with the number of the trade channel if you have changed the default).')
  end
end

function _.findTradeChannelId()
  local tradeChannelName = _.determineTradeChannelName()
  if tradeChannelName then
    local channels = { GetChannelList() }
    for index = 1, #channels, 3 do
      local id, name = channels[index], channels[index + 1]
      if name == tradeChannelName then
        return id
      end
    end
  end

  return nil
end

local tradeChannelNames = {
  enGB = 'Trade',
  enUS = 'Trade',
  deDE = 'Handel',
  frFR = 'Commerce',
  esMX = 'Comercio',
  ptBR = 'Comércio',
  esES = 'Comercio',
  itIT = 'Commercio',
  ruRU = 'Торговля',
  koKR = '거래', -- This one has been done via Google Translate. So the actual string in-game might be different.
  zhCN = '贸易', -- This one has been done via Google Translate. So the actual string in-game might be different.
  zhTW = '貿易' -- This one has been done via Google Translate. So the actual string in-game might be different.
}

function _.determineTradeChannelName()
	return tradeChannelNames[GetLocale()]
end

SEND_MESSAGES_TO_TRADE_CHAT_BUTTON = 'Confirm sending message to trade chat'

SendMessagesToTradeChat.threads = {}

local postButton

function SendMessagesToTradeChat.confirm()
  postButton:Hide()
  if next(SendMessagesToTradeChat.threads) then
    local thread = table.remove(SendMessagesToTradeChat.threads, 1)
    Coroutine.resumeWithShowingError(thread)
  end
  if next(SendMessagesToTradeChat.threads) then
    RunNextFrame(function ()
      postButton:Show()
    end)
  end
end

postButton = CreateFrame('Button', nil, UIParent, 'UIPanelButtonTemplate')
postButton:SetSize(280, 48)
postButton:SetText('Send message to trade chat')
postButton:SetPoint('CENTER', 0, 0)
postButton:SetScript('OnClick', function()
  SendMessagesToTradeChat.confirm()
end)
postButton:Hide()

function _.showPostButton()
  table.insert(SendMessagesToTradeChat.threads, coroutine.running())
  postButton:Show()
  coroutine.yield()
end

local chatEditInsertLink = _G.ChatEdit_InsertLink
_G.ChatEdit_InsertLink = function (text)
  if text and SendMessagesToTraceChatEditBox:HasFocus() then
    SendMessagesToTraceChatEditBox:Insert(text)
    SendMessagesToTraceChatEditBox:SetFocus()
    return true
  else
    return chatEditInsertLink(text)
  end
end
