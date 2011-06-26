package com.conceptualideas.chat.core
{
	import com.conceptualideas.chat.events.ChatClientManagerEvent;
	import com.conceptualideas.chat.events.ChatScreenContextEvent;
	import com.conceptualideas.chat.events.RoomEvent;
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.interfaces.IChatScreen;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.views.ChatScreen;

	import flash.events.EventDispatcher;

	[Event(name="roomInfoRetrived", type="com.conceptualideas.chat.events.ChatClientManagerEvent")]
	[Event(name="newMessage", type="com.conceptualideas.chat.events.ChatClientManagerEvent")]
	[Event(name="userlistUpdated", type="com.conceptualideas.chat.events.ChatClientManagerEvent")]
	public class ChatScreenContext extends EventDispatcher implements IScreenContext, IDisposable
	{
		private var _chatClient:IChatClient
		private var _chatScreen:IChatScreen

		private var onMessagePreCallback:Function = function(message:String):String{return message.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");}
		private var onMessagePostCallback:Function = null;
		private var onMessagesRecievedCallback:Function = null;




		public function ChatScreenContext(
			name:String, chatScreen:IChatScreen, chatClient:IChatClient,
			title:String=null)
		{
			_name = name;
			_chatClient = chatClient;
			_chatScreen = chatScreen;
			_chatScreen.setHandlers(chatScreen_messagePreHandler, chatScreen_messagePostHandler);
			_title = title;
			init();
		}

		private var _name:String

		public function get name():String
		{
			return _name;
		}
		private var _title:String

		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}

		public function get chatClient():IChatClient
		{
			return _chatClient;
		}

		public function get chatScreen():IChatScreen
		{
			return _chatScreen;
		}

		/**
		 * Sets numerious callbacks used for message process and delgatating
		 *
		 * @param preCallback  Callback used to pre-process a message String  pre(String):String
		 * @param postCallback Callback used to post-process a constructed ChatFieldMessage post(ChatFieldMessage):void
		 * @param recieveCallback Callback used to process when messages are returned from server end recieveCallback(Vector.<ChatFieldMessage>):void
		 * **/
		public function setHandlers(preCallback:Function=null, postCallback:Function=null, recieveCallback:Function=null):void
		{
			this.onMessagePreCallback = preCallback != null ? preCallback : onMessagePreCallback;
			this.onMessagePostCallback = postCallback != null ? postCallback : onMessagePostCallback;
			this.onMessagesRecievedCallback = recieveCallback != null ? recieveCallback : onMessagesRecievedCallback;

		}

		private function init():void
		{

			_chatClient.addEventListener(ChatClientManagerEvent.CONNECTED_TO_SERVER, onConnectedToServer);
			_chatClient.addEventListener(ChatClientManagerEvent.NEW_MESSAGE, onMessageRecieved);
			_chatClient.addEventListener(RoomEvent.USER_JOIN, client_roomEventHandler);
			_chatClient.addEventListener(RoomEvent.USER_DISCONNECTED, client_roomEventHandler);

		}

		private function client_roomEventHandler(e:RoomEvent):void
		{
			e.stopImmediatePropagation();
			dispatchEvent(e.clone());
		}

		protected function chatScreen_messagePreHandler(message:String):String
		{
			return onMessagePreCallback != null ? onMessagePreCallback(message) : message;
		}

		protected function chatScreen_messagePostHandler(chatMessage:ChatFieldMessage):void
		{
			if (onMessagePostCallback != null && onMessagePostCallback(chatMessage))
			{
				sendMessage(chatMessage);
			}

		}

		private function onConnectedToServer(e:ChatClientManagerEvent):void
		{
			dispatchEvent(e.clone());
		}

		/**
		 * Sends a chatMessage to server to be dispatched to all users
		 * */
		public function sendMessage(chatMessage:ChatFieldMessage):void
		{


			var e:ChatScreenContextEvent = new ChatScreenContextEvent(ChatScreenContextEvent.SEND_MESSAGE
				, false, true, chatMessage);

			if (!dispatchEvent(e))
				return;
			_chatClient.addMessage(chatMessage);
		}

		/**
		 * Adds a message to the chatScreen for display
		 * @param chatMessage ChatFieldMessage to be added to screen from server
		 * */
		public function addMessage(chatMessage:ChatFieldMessage):void
		{

			_chatScreen.addMessage(chatMessage);
			if (hasEventListener(ChatScreenContextEvent.MESSAGE_ADDED))
				dispatchEvent(new ChatScreenContextEvent(ChatScreenContextEvent.MESSAGE_ADDED))
		}

		private function onMessageRecieved(e:ChatClientManagerEvent):void
		{


			var chatMessages:Vector.<ChatFieldMessage> = e.data.messages;


			onMessagesRecievedCallback != null ? onMessagesRecievedCallback(e.data.messages) : null;

			var chatMessage:ChatFieldMessage;
			var event:ChatScreenContextEvent = new ChatScreenContextEvent(ChatScreenContextEvent.MESSAGE_RECIEVED,
				false, true);
			for each (chatMessage in chatMessages)
			{
				if (hasEventListener(ChatScreenContextEvent.MESSAGE_RECIEVED))
				{
					event.chatMessage = chatMessage;


					if (!dispatchEvent(event))
						continue;

				}
				addMessage(chatMessage);
			}

		}

		public function dispose():void
		{
			onMessagesRecievedCallback = null;
			onMessagePreCallback = null;
			onMessagePostCallback = null;
			if (_chatClient)
			{
				_chatClient.removeEventListener(ChatClientManagerEvent.CONNECTED_TO_SERVER, onConnectedToServer);
				_chatClient.removeEventListener(ChatClientManagerEvent.NEW_MESSAGE, onMessageRecieved);
				if (_chatClient is IDisposable)
					IDisposable(_chatClient).dispose();
			}

			_chatClient = null;
			if (_chatScreen)
			{
				if (_chatScreen is IDisposable)
					IDisposable(_chatScreen).dispose();
			}
			_chatScreen = null;
		}

		public function set enabled(value:Boolean):void
		{
			if (_chatScreen)
				_chatScreen.enabled = value;

		}



	}
}