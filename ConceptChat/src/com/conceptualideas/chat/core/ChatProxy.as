package com.conceptualideas.chat.core
{
	import com.conceptualideas.chat.chat_internal;
	import com.conceptualideas.chat.events.ChatClientManagerEvent;
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.models.NotificationMessage;
	import com.conceptualideas.chat.utils.Convert;
	
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;


	use namespace chat_internal;

	public class ChatProxy extends EventDispatcher
	{
		private var chatClients:Vector.<IChatClient> = new Vector.<IChatClient>();

		protected var netConnection:NetConnection
		protected var _appInstance:String
		protected var _server:String
		private var disconnectWatcher:DisconnectWatcher
		protected var pendingActions:Vector.<PendingAction> = new Vector.<PendingAction>();
		private var connectedOnce:Boolean;
		private var connectArgs:Array;
		private var isConencted:Boolean
		static private var _instance:ChatProxy;

		protected var netConnectionClient:NetClient


		public static function getInstance():ChatProxy
		{
			if (!_instance)
				_instance = new ChatProxy();
			return _instance;
		}

		chat_internal function removeClient(client:IChatClient):void
		{
			var index:int = chatClients.indexOf(client);
			if (index != -1)
				chatClients.splice(index, 1);
		}

		public function newClient(clientClass:Class):IChatClient
		{
			var client:IChatClient = new clientClass(this);
			chatClients.push(client);
			return client;

		}

		public function ChatProxy()
		{
			init();
		}

		protected function init():void
		{
			netConnection = new NetConnection();

			setupNetConnectionClient()
			connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			addHandlers();
		}

		protected function setupNetConnectionClient():void
		{

			connection.client = netConnectionClient = new NetClient();
			connection.objectEncoding = ObjectEncoding.AMF0;

		}

		protected function addHandlers():void
		{
			addClientCallback("onMessageRecieved", onMessageRecieved);
			addClientCallback("onNotification", onNotification);
			addClientCallback("onShutdownRequest", onShutdownRequest);
			addEventListener(ChatClientManagerEvent.RE_CONNECTED, onReconnected);
		}



		private function onReconnected(e:ChatClientManagerEvent):void
		{
			for each (var client:IChatClient in chatClients)
			{
				client.reconnect();
			}
		}





		public function sendNotification(note:NotificationMessage):void
		{
			call("sendNotification", null, note);
		}

		protected function onNotification(note:Object):void
		{

			dispatchEvent(
				new ChatClientManagerEvent(ChatClientManagerEvent.NOTIFICATION,
				Convert.convertToObject(NotificationMessage, note)));
		}

		protected function onShutdownRequest(reason:String):void
		{
			disconnectWatcher.dispose()
			disconnectWatcher = null;
			connection.close()
			dispatchEvent(new ChatClientManagerEvent(ChatClientManagerEvent.CLIENT_DISCONNECTED, reason));
		}



		private function onMessageRecieved(roomName:String, messageData:Object):void
		{
			
			
			//trace(messageData as ChatFieldMessage)
			for each (var client:ChatClient in chatClients)
			{
				if (client.roomName == roomName)
				{
					client.onMessageRecieved(Convert.convertToObject(ChatFieldMessage, messageData) as ChatFieldMessage);
					break;
				}
			}

		}

		public function set appInstance(v:String):void
		{
			_appInstance = v;
		}

		public function setServer(s:String):void
		{
			_server = "rtmp://" + s + "/" + _appInstance;
		}

		public function call(method:String, callback:Function, ... parameters:Array):void
		{
			var args:Array = [method, new Responder(callback)].concat(parameters);

			netConnection.call.apply(netConnection, args);
		}

		public function disconnectFromRoom(roomName:String, callback:Function):void
		{
			call("disconnectFromRoom", function():void{
					removeChatClient(roomName);
					callback();
				}, roomName);
		}

		protected function removeChatClient(roomName:String):void
		{
			var len:int = chatClients.length;
			for (var i:int = 0; i < len; i++)
			{
				if (chatClients[i].roomName != roomName)
					continue;
				chatClients.splice(i, 1);
			}
		}

		public function addMessage(chatRoom:String, message:Object):void
		{

			tryCall("addMessage", null, {
					chatRoom:chatRoom,
					chatMessage:message
				});

		}


		protected function onConnected():void
		{
			if (!connectedOnce)
				dispatchEvent(new ChatClientManagerEvent(ChatClientManagerEvent.CONNECTED_TO_SERVER, {}));
			connectedOnce = true;
			isConencted = true;
		}

		private function onNetStatus(e:NetStatusEvent):void
		{

			trace(e.info.code);

			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":


					onConnected();



					break;

				case "NetConnection.Connect.Rejected":
					onShutdownRequest(e.info.application);
					/*dispatchEvent(new ChatClientManagerEvent(
					   ChatClientManagerEvent.CONNECTED_TO_SERVER, {rejected:true,
					 message:e.info.application}));*/
					break;

			}

		}

		protected function addClientCallback(name:String, callback:Function, priority:int=0):void
		{
			netConnectionClient.addHandler(name, callback, priority);

		}

		public function connect(... paramaters:Array):void
		{


			connectArgs = [_server].concat(paramaters);
			if(!disconnectWatcher)
				disconnectWatcher = new DisconnectWatcher(this, netConnection, connectArgs);
			netConnection.connect.apply(netConnection, connectArgs);

		}




		public function get connection():NetConnection
		{
			return netConnection;

		}

		final protected function tryCall(... commands):void
		{
			if (!isConencted)
			{
				addPendingAction.apply(this, commands);
			}
			else
			{
				call.apply(this, commands);
			}

		}

		final protected function addPendingAction(... commands):void
		{
			pendingActions.push(new PendingAction(commands.shift(), commands.shift(), commands));

		}


	}
}
import com.conceptualideas.chat.interfaces.IChatClient;

import flash.net.Responder;

/**
 * Internal class used for actions that are called before the server has been connected
 */
internal class PendingAction
{

	private var method:String
	private var callback:Function
	private var args:Array

	public function PendingAction(method:String, callback:Function, ... args:Array):void
	{
		this.method = method;
		this.callback = callback
		this.args = args;
	}

	public function invoke(context:Object):void
	{
		context.call.apply(context, [method, callback].concat(args));
		method = null;
		callback = null;
		args = null;
	}

}