package com.conceptualideas.chat.plugins.shortcut
{
	import com.conceptualideas.chat.events.ChatScreenContextEvent;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.plugins.room.PrivateMessagePlugin;
	import com.conceptualideas.chat.plugins.user.IRoomRoster;
	import com.conceptualideas.chat.plugins.user.IUserManagerPlugin;

	public class ShortcutsPlugin extends AbstractShortcutPlugin implements IShortcutPlugin
	{

		private var privateMessagePlugin:PrivateMessagePlugin



		private var totalScreenCount:int

		private var maxScreenNotice:ChatFieldMessage

		private static const DEFAULT_SCREEN_LIMIT:int = 3;
		private var _maxNumOfScreens:int = DEFAULT_SCREEN_LIMIT;
		private static const DEFAULT_NOTICEMESSAGE:String = "Sorry but you are only allowed ( " + DEFAULT_SCREEN_LIMIT + " ) screen(s) open at one time, please close others.";



		private var shortcuts:Object = {};
		private var shortcutHandlers:Vector.<IShortcutHandler>  = new Vector.<IShortcutHandler>();

		public function registerShortcutHandler(handler:IShortcutHandler):void
		{
			if (shortcutHandlers.indexOf(handler) == -1)
				shortcutHandlers.push(handler);

		}

		override protected function onContextInit():void
		{
			super.onContextInit();
			privateMessagePlugin = chatContext.getPlugin(PrivateMessagePlugin) as PrivateMessagePlugin;
		}

		public function removeShortcut(shortcut:String):void
		{
			delete shortcuts[shortcut];
		}

		override public function handle(token:String, screenContext:IScreenContext, chatMessage:ChatFieldMessage):Boolean
		{
			var tokens:Array = getTokens(chatMessage.message);
			switch (token)
			{
				case "clear":
					screenContext.chatScreen.clear();
					break;
				case "who":
					sendSystemMessage(screenContext, handleWhoToken(screenContext.name));
					break;
				case "help":
					var message:String = "";
					var handler:IShortcutHandler;
					// usage
					// description
					var shortcuts:Object
					var amount:int = 10;
					var index:int=0;
					var page:int = tokens.length ? int(tokens[0]) : 1;
					var start:int  = (page * amount) - amount;
					var end:int = start + amount;
					for each (handler in shortcutHandlers)
					{
						shortcuts = handler.getShortcuts();
						for (token in shortcuts)
						{

							if (shortcuts[token])
							{
								//if (index++ >= start && index < end)
								//{
									message += "usage" in shortcuts[token] ? shortcuts[token]["usage"] : "/" + token;
									message += "description" in shortcuts[token] ? " " + shortcuts[token]["description"] + "\n" : ""
								//}
							}
						}


					}
					//message += "Page " + page + " of " + Math.floor(index / amount);
					chatMessage.from = "#system";
					chatMessage.message = message;
					screenContext.addMessage(chatMessage);


					break;
			}
			return true;
		}




		override protected function register():void
		{
			super.register();
			addShortcuts({

					"who":{
						description:"Show a list of registered users online"

					},
					"help":{
						description:"Shows this help screen",
						usage:"/help [page]"
					},
					"clear":{
						description:"Clear you screen"
					}
				})

		}

		public function ShortcutsPlugin()
		{
			super();
			maxScreenNotice = new ChatFieldMessage();
			maxScreenNotice.from = "#notice"
			maxScreenNoticeMessage = DEFAULT_NOTICEMESSAGE;
		}

		public function set maxNumOfScreens(num:Object):void
		{
			_maxNumOfScreens = int(num);
		}



		public function set maxScreenNoticeMessage(value:Object):void
		{
			maxScreenNotice.message = value as String;

		}


		override protected function onScreenAdded(chatScreen:IScreenContext):void
		{
			totalScreenCount++;
			chatScreen.addEventListener(ChatScreenContextEvent.SEND_MESSAGE, chatScreen_sendMessageHandler, false, int.MAX_VALUE);
		}

		override protected function onScreenRemoved(chatScreen:IScreenContext):void
		{
			totalScreenCount--;
			chatScreen.removeEventListener(ChatScreenContextEvent.SEND_MESSAGE, chatScreen_sendMessageHandler);
		}



		private function chatScreen_sendMessageHandler(e:ChatScreenContextEvent):void
		{

			const chatMessage:ChatFieldMessage = e.chatMessage
			const message:String = chatMessage.message;
			var handled:Boolean = false;
			if (message.charAt(0) == "/")
			{
				handled = true;

				var token:String = message.substr(1, message.indexOf(" ") != -1 ? message.indexOf(" ") - 1 : message.length);
				var handler:IShortcutHandler
				for each (handler in shortcutHandlers)
				{
					if (handler.canHandle(token)) // check if can handle if not we set to true so we miss all not mapped / actions
					{
						handled = handler.handle(token, IScreenContext(e.target), chatMessage);
						break;
					}

				}
			}

			if (handled)
				e.preventDefault();


		}

		private function handleWhoToken(room:String):String
		{
			//TODO : make this into an task

			var plug:IUserManagerPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin;

			var roster:IRoomRoster = plug.getRoomByName(room);
			var myName:String = chatContext.userName;
			var names:Vector.<String> = roster.getUserNames().filter(function(name:String, index:int, vector:Vector.<String>):Boolean
				{
					return (name.indexOf("Guest") == -1 && name != myName);

				});
			var msg:String
			if (names.length)
			{
				msg = "Registered Users Online: " + names.join(" , ");
			}
			else
			{
				msg = "No Other Registered Users Online";
			}
			return msg;

		}





	}
}