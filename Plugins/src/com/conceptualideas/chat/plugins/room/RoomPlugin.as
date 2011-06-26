package com.conceptualideas.chat.plugins.room
{
	import com.conceptualideas.chat.events.ChatClientManagerEvent;
	import com.conceptualideas.chat.events.ChatScreenContextEvent;
	
	import com.conceptualideas.chat.formatters.TemplateFormatter;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.models.NotificationMessage;
	import com.conceptualideas.chat.plugins.room.events.RoomEvent;
	import com.conceptualideas.chat.plugins.room.tasks.BootUserTask;
	import com.conceptualideas.chat.plugins.room.tasks.CreateRoomTask;
	import com.conceptualideas.chat.plugins.room.tasks.InviteUserTask;
	import com.conceptualideas.chat.plugins.room.tasks.JoinRoomTask;
	import com.conceptualideas.chat.plugins.room.tasks.PrivateMessageRequestTask;
	import com.conceptualideas.chat.plugins.shortcut.AbstractShortcutPlugin;

	import flash.events.Event;

	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.events.FlowElementMouseEvent;

	public class RoomPlugin extends AbstractShortcutPlugin implements IPrivateMessagePlugin
	{



		private var formatter:TemplateFormatter = new TemplateFormatter();

		public static const JOIN_ROOM:String = "joinRoom";

		public var roomAlreadyCreatedTemplate:String = "Room ({room}) is already created, but you can join [a:joinRoom][color:#83AAD1]#{room}[/color][/a]";
		public var inviteTemplate:String = "{user} has invited you to join [a:joinRoom][color:#83AAD1]#{room}[/color][/a]";
		public var bootTemplate:String = "{user} as booted you from #{room} {reason}";
		
		private var storage:AbstractStorage

		// simple room_name -> Boolean
		private var isCreatorHash:Object = {};

		public function RoomPlugin()
		{
			super();
		}

		override public function handle(token:String, screenContext:IScreenContext, chatMessage:ChatFieldMessage):Boolean
		{
			//if (super.handle(token, screenContext, chatMessage))
			//return true;
			var tokens:Array = chatMessage.message.split(" ");
			tokens.shift() //
			var message:String;

			switch (token)
			{
				case "msg":
					sendChatRequest(tokens.shift(), tokens.join(" "));
					break
				case "room":
					var action:String = tokens.length ? tokens.shift() : null;
					var target:String = tokens.length ? tokens.shift() : null;
					switch (action)
					{

						case "auto":
						auto = storage
						case "create":


							if (target)
							{
								formatter.tokens = {
										room:target
									};
								message = formatter.format(roomAlreadyCreatedTemplate);
								new CreateRoomTask(chatContext, screenContext, target, message).run();

							}
							break;
						case "join":

							if (target)
							{
								if (!chatContext.hasScreen(target)) // stop from opening the window twice
								{
									new JoinRoomTask(chatContext, screenContext, target).run();

								}

							}
							break;
						case "invite":

							var room:String = tokens.length ? tokens.shift() : screenContext.name
							new InviteUserTask(chatContext,
								screenContext, room,
								chatContext.userName, target).run();

							break;
						case "boot":
							if (target)
							{


								if (isCreatorHash[screenContext.name] == null)
								{
									screenContext.chatClient.call("getRoomInfo", function(info:Object):void{

											isCreatorHash[screenContext.name] = (info.owner && info.owner
												== chatContext.userName)


											doBoot(screenContext, target, tokens.join(" "));
										}, screenContext.name);

								}
								else
								{
									doBoot(screenContext, target, tokens.join(" "));
								}

							}
					}
					break;
				default: // show help;

			}





			return true; // supress output to main message
		}

		private function doBoot(screenContext:IScreenContext, name:String, reason:String=""):void
		{

			if (!isCreatorHash[screenContext.name])
				return;
			new BootUserTask(chatContext, screenContext, name, reason).run();



		}
		private var catchNotifyMessages:Boolean

		override protected function onScreenAdded(screen:IScreenContext):void
		{

			
			if (!catchNotifyMessages)
				screen.chatClient.globalDispatcher.addEventListener(ChatClientManagerEvent.NOTIFICATION, notifyHandler);
			screen.addEventListener(com.conceptualideas.chat.events.RoomEvent.USER_JOIN, client_userActionHandler);
			screen.addEventListener(com.conceptualideas.chat.events.RoomEvent.USER_DISCONNECTED, client_userActionHandler);
			screen.chatScreen.textInputObject.addEventListener(JOIN_ROOM, joinRoomHandler);
		}

		private function client_userActionHandler(e:Event):void
		{
			var joined:Boolean = e.type == "userJoined";

			var screen:IScreenContext = IScreenContext(e.target);
			var message:String = e["user"].name + ((joined) ? " has joined the room" : " has left the room");
			sendSystemMessage(screen, message);
		}

		override protected function onScreenRemoved(screen:IScreenContext):void
		{
			screen.chatScreen.textInputObject.removeEventListener(JOIN_ROOM, joinRoomHandler);
			delete isCreatorHash[screen.name];
			screen.addEventListener("userJoined", client_userActionHandler);
			screen.addEventListener("userDisconnected", client_userActionHandler);
		}


		private function joinRoomHandler(e:Event):void
		{
			if (e is FlowElementMouseEvent)
			{
				var link:LinkElement = FlowElementMouseEvent(e).flowElement as LinkElement;
				if (!link)
					return;
				var room:String = link.getText().replace("#", "");
				if (!chatContext.hasScreen(room))
				{

					chatContext.dispatchEvent(new RoomEvent(RoomEvent.JOIN, false, false, room))
				}

			}

		}

		private function notifyHandler(e:ChatClientManagerEvent):void
		{
			var note:NotificationMessage = NotificationMessage(e.data);
			if (note.flag.indexOf(RoomFlags.NOTIFY_FLAG) != 0)
				return;
			var message:String;
			var screenContext:IScreenContext
			switch (note.flag)
			{
				case RoomFlags.NOTIFY_INVITE_FLAG:
					if (!chatContext.hasScreen(note.data.room))
					{
						formatter.tokens = note.data;
						message = formatter.format(inviteTemplate);
						formatter.reset();
						for each (screenContext in chatContext.chatScreens)
						{
							sendSystemMessage(screenContext, message);
						}
					}
					break;
				case RoomFlags.NOTIFY_BOOT_FLAG:


					screenContext = chatContext.getScreenByName(note.data.room)
					if (screenContext)
					{
						var chatMessage:ChatFieldMessage = new ChatFieldMessage();
						formatter.tokens = note.data;

						chatMessage.message = formatter.format(bootTemplate)

						screenContext.sendMessage(chatMessage);
						chatContext.removeScreen(screenContext);


					}

					break;
			}


		}


		public function sendChatRequest(to:String, message:String=null):Boolean
		{
			new PrivateMessageRequestTask(chatContext, to, message).run();
			return true;
		}

		override protected function register():void
		{

			addShortcuts({
					"room":{
						description:"Control your room",
						usage:"/room (create|join)[room_name] | (invite|boot)[username] [reason])"
					},

					"msg":{
						description:"Send and direct message",
						usage:"/msg [username]"
					}
				})
			super.register()
		}
	}
}