package com.conceptualideas.chat.core
{
	import com.conceptualideas.chat.chat_internal;
	import com.conceptualideas.chat.events.ChatClientManagerEvent;
	import com.conceptualideas.chat.events.RoomEvent;
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.models.ConnectionInfo;
	import com.conceptualideas.chat.models.NotificationMessage;
	import com.conceptualideas.chat.utils.Convert;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.SyncEvent;
	import flash.net.NetConnection;
	import flash.net.SharedObject;


	use namespace chat_internal;

	public class ChatClient extends EventDispatcher implements IChatClient, IDisposable
	{
		private var proxy:ChatProxy
		private var connectionInfo:ConnectionInfo
		private var userSharedObjects:SharedObject;
		private var isDisconnected:Boolean
		private var connectToUsers:Boolean = true;

		private var firstUserSync:Boolean = true;

		private var clientID:String



		public function ChatClient(proxy:ChatProxy)
		{
			this.proxy = proxy;


			init();
		}


		private var _syncThreshold:int

		public function set syncThreshold(value:int):void
		{
			if (_syncThreshold == value)
				return;
			_syncThreshold = value;
		}

		public function changeName(name:String):void
		{
			proxy.call("changeName", onNameChangeCompleted, name);
		}

		public function setProperty(user:ChatUser, name:String, value:Object):void
		{


			userSharedObjects.data[user.clientID][name] = value;
			userSharedObjects.setDirty(user.clientID);
		}

		private function onNameChangeCompleted(name:String):void
		{

			connectionInfo.userInfo.name = name;
			dispatchEvent(new ChatClientManagerEvent(ChatClientManagerEvent.NAME_CHANGED, name));
		}

		protected function init():void
		{
			proxy.addEventListener(ChatClientManagerEvent.DISCONNECTED, proxy_disconnectedHandler);
		}

		private function proxy_disconnectedHandler(e:ChatClientManagerEvent):void
		{
			isDisconnected = true;
		}

		public function updateUserInfo(user:ChatUser):void
		{
			//clientID = user.clientID;
			//userSharedObjects.setProperty(user.clientID, user.toObject());

		}

		public function call(method:String, callback:Function, ... parameters:Array):void
		{
			proxy.call.apply(null, [method, callback].concat(parameters));
		}

		public function get globalDispatcher():IEventDispatcher
		{
			return proxy;
		}

		public function reconnect():void
		{
			if (isDisconnected)
				connectToRoom(connectionInfo);
		}

		public function onMessageRecieved(chatMessage:ChatFieldMessage):void
		{
			dispatchEvent(new ChatClientManagerEvent(ChatClientManagerEvent.NEW_MESSAGE,
				{messages:Vector.<ChatFieldMessage>([chatMessage])}));
		}

		public function addMessage(message:Object):void
		{
			proxy.addMessage(connectionInfo.chatRoom, message);
		}

		public function get roomName():String
		{
			return connectionInfo.chatRoom;
		}



		public function connectToRoom(connectInfo:ConnectionInfo):void
		{
			connectionInfo = connectInfo;
			proxy.call("connectToRoom", onConnectedToRoom, connectionInfo);
		}

		private function onConnectedToRoom(connected:Boolean):void
		{
			if (connected)
			{
				isDisconnected = false;
				connectToSharedObjects();
			}
		}

		protected function disposeSharedObjects():void
		{

			/*if (chatSharedObject)
			   {

			   //chatSharedObject.client = null;
			   chatSharedObject.removeEventListener(SyncEvent.SYNC, onChatSync);
			   chatSharedObject.close();
			   chatSharedObject = null;
			 }*/
			if (userSharedObjects)
			{
				//userSharedObjects.client = null;
				userSharedObjects.removeEventListener(SyncEvent.SYNC, onUserSync);
				userSharedObjects.close();
				userSharedObjects = null;
			}
		}

		protected function connectToSharedObjects():void
		{
			disposeSharedObjects();
			if (connectToUsers) // connect to users first to ensure that any user management plugins has access to users0
			{
				//log("ConnectToUsers");
				userSharedObjects = SharedObject.getRemote(getSharedObjectName(roomName, false), connection.uri);
				userSharedObjects.addEventListener(SyncEvent.SYNC, onUserSync);
				userSharedObjects.client = {
						onClientDisconnect:onClientDisconnect,
						onForceUpdate:onForceUpdate,
						onUserConnected:onUserConnected,
						onUserDisconnected:onUserDisconnected
					};
				userSharedObjects.connect(proxy.connection);
			}



		}

		private function onUserConnected(info:Object):void
		{
			if (hasEventListener(RoomEvent.USER_JOIN))
			{
				dispatchEvent(new RoomEvent(RoomEvent.USER_JOIN,
					false, false, Convert.convertToObject(ChatUser, info)))

			}
		}

		private function onUserDisconnected(info:Object):void
		{
			if (hasEventListener(RoomEvent.USER_DISCONNECTED))
			{
				dispatchEvent(new RoomEvent(RoomEvent.USER_DISCONNECTED,
					false, false, Convert.convertToObject(ChatUser, info)))

			}
		}


		private var lastUserCount:uint

		private var currentThreshold:int = -1;

		/**
		 * Since wowza is having problems with updating the prorperty with setProperty we will force the update
		 * */
		private function onForceUpdate(clientID:String, info:Object):void
		{
			var o:Object = {}
			o[clientID] = info;
			sync(o);
		}

		private function sync(overrideInfo:Object=null):void
		{

			overrideInfo ||= {};
			currentThreshold = 0;
			var user:Object = {};
			var users:Object = {};
			var userCount:int = 0;
			for each (user in userSharedObjects.data)
			{

				if (user)
				{
					userCount++;
					users[user.clientID] = overrideInfo[user.clientID] ? overrideInfo[user.clientID] : user;
				}
			}

			if (userCount)
				dispatchEvent(new ChatClientManagerEvent(ChatClientManagerEvent.USERLIST_UPDATED,
					{users:users, userCount:userCount}));
			if (firstUserSync)
			{
				firstUserSync = false
				if (proxy.hasEventListener("userInfoUpdateRequest"))
					proxy.dispatchEvent(new ChatClientManagerEvent("userInfoUpdateRequest", {target:this}));
				dispatchEvent(new Event(Event.CONNECT));
			}
		}

		private function onUserSync(e:SyncEvent):void
		{
			sync();
			//if (currentThreshold < 0 || !_syncThreshold || (_syncThreshold && ++currentThreshold > _syncThreshold))
			//{

			//}

		}

		protected function getSharedObjectName(room:String, chat:Boolean=true):String
		{
			return ((chat) ? "chat_" : "users_") + room;
		}

		protected function onClientDisconnect(user:Object):void
		{
			var chatUser:ChatUser =  Convert.convertToObject(ChatUser, user) as ChatUser

			dispatchEvent(new ChatClientManagerEvent(ChatClientManagerEvent.CLIENT_DISCONNECTED, chatUser));

		}




		public function get connection():NetConnection
		{
			return proxy.connection;
		}



		public function disconnectFromRoom():void
		{
			if (connectionInfo)
				proxy.disconnectFromRoom(connectionInfo.chatRoom, finishRoomDisconnect);

		}

		private function finishRoomDisconnect():void
		{
			dispose();
		}

		public function dispose():void
		{
			disposeSharedObjects();
			proxy.removeClient(this);
			proxy.removeEventListener(ChatClientManagerEvent.DISCONNECTED, proxy_disconnectedHandler);
			proxy = null;
			connectionInfo = null

		}



		public function sendNotification(notification:NotificationMessage):void
		{
			proxy.call("sendNotification", null, notification);
		}


	}
}