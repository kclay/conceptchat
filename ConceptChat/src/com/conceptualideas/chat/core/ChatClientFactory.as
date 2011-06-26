package com.conceptualideas.chat.core
{
	import com.conceptualideas.chat.core.ChatProxy;
	import com.conceptualideas.chat.interfaces.IChatClient;

	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class ChatClientFactory
	{
		private static var chatClientManagers:Dictionary = new Dictionary();

		public static var _clientClass:Class = ChatClient;

		private static var _instance:IChatClient

		private static var _proxyClass:Class = ChatProxy

		public static function set proxyClass(value:Class):void
		{
			_proxyClass = value;
		}

		public static function set clientClass(value:Class):void
		{

			_clientClass = value;

		}

		private static var _appInstance:String

		public static function set appInstance(value:String):void
		{
			_proxyClass["getInstance"]().appInstance = value;

		}

		public static function getProxyInstance():ChatProxy
		{
			return _proxyClass["getInstance"]();
		}

		public static function get dispatcher():IEventDispatcher
		{

			return _proxyClass.dispatcher;
		}

		public static function remove(roomName:String):void
		{
			chatClientManagers[roomName] = null;
			delete chatClientManagers[roomName];
		}

		public static function getChatClient(roomName:String, create:Boolean=true):IChatClient
		{

			if (!chatClientManagers[roomName] && create)
			{
				chatClientManagers[roomName] = getProxyInstance().newClient(_clientClass) as IChatClient

			}


			return chatClientManagers[roomName];
		}
	}
}