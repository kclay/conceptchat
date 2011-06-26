package com.conceptualideas.chat
{

	import com.conceptualideas.chat.core.AbstractConfigReader;
	import com.conceptualideas.chat.core.ChatClientFactory;
	import com.conceptualideas.chat.core.ChatContext;
	import com.conceptualideas.chat.core.ChatProxy;
	import com.conceptualideas.chat.core.ChatScreenContext;
	import com.conceptualideas.chat.core.FloodManager;
	import com.conceptualideas.chat.events.ChatClientManagerEvent;
	import com.conceptualideas.chat.events.ChatContextEvent;
	import com.conceptualideas.chat.interfaces.IChatApplication;
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IChatScreen;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.models.ChatSettings;
	import com.conceptualideas.chat.models.ConnectionInfo;
	import com.conceptualideas.chat.views.ChatScreen;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	import mx.controls.Alert;
	import mx.core.ClassFactory;
	import mx.core.UIComponent;
	import mx.utils.StringUtil;

	public class BasicChatController extends EventDispatcher
	{
		protected var chatScreen:IChatScreen
		private var _chatClient:IChatClient

		protected var chatContext:IChatContext

		protected var userName:String

		protected var currentRoom:String
		protected var chatSettings:ChatSettings

		private var floodManager:FloodManager

		protected var bootStrapper:AbstractConfigReader

		private var chatScreenClassFactory:ClassFactory = new ClassFactory(ChatScreen);

		protected var firstMessageSent:Boolean
		protected var useHistory:Boolean

		private var _isConnected:Boolean


		protected var mainChatScreenContext:ChatScreenContext

		protected var activeChatScreenContext:Vector.<ChatScreenContext> = new Vector.<ChatScreenContext>();


		public function get settings():ChatSettings
		{
			return chatSettings;
		}

		protected var chatApplication:IChatApplication

		public function BasicChatController(chatApplication:IChatApplication, chatSettings:ChatSettings)
		{
			this.chatSettings = chatSettings;
			this.chatApplication = chatApplication;

			this.chatScreen = createChatScreen();

			UIComponent(this.chatScreen).callLater(init);

			ChatClientFactory.appInstance = chatSettings.appInstance;

			chatContext = new ChatContext(chatApplication);
			this.chatScreen.enabled = false;
			bootStrapper = createBootStrapperInstance();


		}

		private function globalEventHandler(e:ChatClientManagerEvent):void
		{
			switch (e.type)
			{

				case ChatClientManagerEvent.DISCONNECTED:
					chatApplication.enabled = false;
					Alert.show("Server has Disconnected, we will try to reconnect you","Disconnected");
					break;
					break;
				case ChatClientManagerEvent.RE_CONNECTED:
					break;
				case ChatClientManagerEvent.CONNECTED_TO_SERVER:
					if (e.data.rejected)
					{

						Alert.show(e.data.message, "Server Message");

					}
					else
					{
						onChatClientConnected();
					}
					break;
				case ChatClientManagerEvent.NAME_CHANGED:
					ChatContext(chatContext).userName = String(e.data);
					chatSettings.userName = String(e.data);
					break;
				case ChatClientManagerEvent.CLIENT_DISCONNECTED:
					onChatClientDisconnected(String(e.data));
					break;
			}
		}

		protected function onChatClientDisconnected(reason:String):void
		{
			Alert.show(reason, "Server Shutdown Request");
			chatApplication.enabled = false;


		}

		protected function onChatClientConnected():void
		{

			if (!chatSettings.userName)
			{
				onGuestConnected();
			}
			else
			{
				onRegisteredUserConnected()
			}


		}

		public function set chatScreenClass(clazz:Class):void
		{
			chatScreenClassFactory = new ClassFactory(clazz);
		}

		protected function createChatScreen():IChatScreen
		{
			return chatScreenClassFactory.newInstance()
		}

		protected function createBootStrapperInstance():AbstractConfigReader
		{
			return new AbstractConfigReader(chatContext);
		}


		protected function init():void
		{
			const dispatcher:IEventDispatcher = ChatClientFactory.getProxyInstance();
			dispatcher.addEventListener(ChatClientManagerEvent.CLIENT_DISCONNECTED, globalEventHandler);
			dispatcher.addEventListener(ChatClientManagerEvent.RE_CONNECTED, globalEventHandler);

			dispatcher.addEventListener(ChatClientManagerEvent.CONNECTED_TO_SERVER, globalEventHandler);
			//	setupClientClients(); // give it enough time to setup 
			chatContext.addEventListener(ChatContextEvent.REMOVED_SCREEN, chatContext_screenRemovedHandler);
			var loader:URLLoader = new URLLoader(new URLRequest(chatSettings.settingsURL + "?r=" + Math.random()));
			loader.addEventListener(Event.COMPLETE, loader_completeHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioHandler);



		}

		protected function setupClientClients():void
		{
			_chatClient = ChatClientFactory.getChatClient(chatSettings.chatRoomName);
			setupChatClient(chatSettings.chatRoomName, _chatClient, chatScreen, "#" + chatSettings.chatRoomName);
		}

		protected function setupChatClient(roomName:String, client:IChatClient, screen:IChatScreen, title:String=null):void
		{
			// TODO : fix bug when creation events
			if (mainChatScreenContext && mainChatScreenContext.chatClient == client)
				return;
			var screenContext:ChatScreenContext = new ChatScreenContext(roomName, screen, client, title);

			activeChatScreenContext.push(screenContext);

			screenContext.setHandlers(chatScreen_messagePreHandler, chatScreen_messagePostHandler, onMessagesRecieved);
			//client.addEventListener(ChatClientManagerEvent.CONNECTED_TO_SERVER, onConnectedToServer);
			if (!mainChatScreenContext) // only need to listen to first connect
			{
				//screenContext.addEventListener(ChatClientManagerEvent.CONNECTED_TO_SERVER, onConnectedToServer);
				mainChatScreenContext = screenContext;
				_chatClient = client;
				client.addEventListener(ChatClientManagerEvent.NAME_CHANGED, globalEventHandler);

			}

			//client.addEventListener(Event.CONNECT, onConnected);

			//function onConnected(e:Event):void{
			//client.removeEventListener(Event.CONNECT, onConnected);
			chatContext.addScreen(screenContext)
			//}

			//screenContext.addEventListener(ChatClientManagerEvent.NEW_MESSAGE, onMessageRecieved);

		}



		private function loader_completeHandler(e:Event):void
		{

			e.target.removeEventListener(Event.COMPLETE, loader_completeHandler);
			// TODO fix parsing
			setupBootStrapper(new XML(e.target.data));


			connectToServer();

		}

		protected function setupBootStrapper(xml:XML):void
		{
			bootStrapper.startup(xml);



			floodManager = new FloodManager(int(xml.floodManager.@maxWords),
				int(xml.floodManager.@maxOccuranceCount));
		}

		private function connectToServer():void
		{
			var proxy:ChatProxy = ChatClientFactory.getProxyInstance();
			proxy.setServer(chatSettings.server);
			proxy.connect(chatSettings.chatRoomName);

		}

		private function loader_ioHandler(e:IOErrorEvent):void
		{


			e.target.removeEventListener(IOErrorEvent.IO_ERROR, loader_ioHandler);
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,
				false, false, "Unabled to load application settings."));
		}


		protected function chatScreen_messagePreHandler(message:String):String
		{
			return StringUtil.trim(message);
		}

		protected function chatScreen_messagePostHandler(chatMessage:ChatFieldMessage):Boolean
		{
			if (!floodManager.isFlood(chatMessage))
			{
				chatMessage.from = chatSettings.userName;
				chatMessage.time = new Date();
				firstMessageSent = true;
				return true;

			}
			return false;

		}


		protected function onRegisteredUserConnected():void
		{
			enabledChatScreen(true);
			connectToRoom();
		}

		protected function onGuestConnected():void
		{
			chatClient.call("getUserName", function(name:String):void
				{
					chatSettings.userName = name;;
					enabledChatScreen(true);
					connectToRoom();
				})
		}

		protected function enabledChatScreen(value:Boolean):void
		{
			if (value)
			{
				onChatScreenEnabled()
			}
			else
			{
				onChatScreenDisabled();
			}
		}

		protected function onChatScreenEnabled():void
		{
			chatScreen.enabled = true;
		}

		protected function onChatScreenDisabled():void
		{
			chatScreen.enabled = false;
		}

		protected function get isConnected():Boolean
		{
			return _isConnected;
		}

		protected function getConnectionInfo(room:String):ConnectionInfo
		{
			var connectInfo:ConnectionInfo = new ConnectionInfo();
			connectInfo.chatRoom = room;
			connectInfo.userInfo.name = chatSettings.userName;
			return connectInfo;
		}

		protected function connectToRoom():void
		{
			_isConnected = true;

			chatContext.create(chatSettings.userName);


			chatClient.connectToRoom(getConnectionInfo(chatSettings.chatRoomName));

		}

		protected function onMessagesRecieved(chatMessages:Vector.<ChatFieldMessage>):void
		{

			//	onMessagesRecieved(Vector.<ChatFieldMessage>(e.data.messages), e.currentTarget as ChatScreenContext);

		}



		protected function getChatClient(roomName:String, create:Boolean=true):IChatClient
		{
			return ChatClientFactory.getChatClient(roomName, create);
		}

		protected function onScreenContextRemoved(chatScreenContext:IScreenContext):void
		{
			activeChatScreenContext.splice(activeChatScreenContext.indexOf(chatScreenContext), 1);
			ChatClientFactory.remove(chatScreenContext.name);
		}

		private function chatContext_screenRemovedHandler(e:ChatContextEvent):void
		{
			onScreenContextRemoved(e.screen);
		}

		public function get chatClient():IChatClient
		{
			return _chatClient;
		}

		public function getMainChatScreen():IChatScreen
		{
			return mainChatScreenContext ? mainChatScreenContext.chatScreen : null;

		}


	}
}