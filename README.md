## Send Messages to Trade Chat

An add-on for sending periodically messages to the trade chat.

## How to use

### Installation

Download the [latest release](https://github.com/SanjoSolutions/SendMessagesToTradeChat/releases) and extract the folders into the AddOns folder.

### Configuring what messages are sent

One or two messages can be sent.

What messages are sent can be configured by calling the API with an additional add-on that the user can provide.

You can download a template for such add-on [here](https://github.com/SanjoSolutions/SendMessagesToTradeChatData.git).

In line 5 and 6 of [SendMessagesToTradeChatData.lua](https://github.com/SanjoSolutions/SendMessagesToTradeChatData/blob/9255d14ae42960fb5dfb69616011f7c04e0d96c5/SendMessagesToTradeChatData.lua#L5-L6), you can add the messages.
If you'd like to only send one message, you can delete line 6.

The APIs that are available can be found in [SendMessagesToTradeChat.lua](https://github.com/SanjoSolutions/SendMessagesToTradeChat/blob/main/SendMessagesToTradeChat/SendMessagesToTradeChat.lua).

### Starting the process

`/run SendMessagesToTradeChatData.toggleSendingMessages()` (if the add-on template has been used).

This command can also be put into a macro.
