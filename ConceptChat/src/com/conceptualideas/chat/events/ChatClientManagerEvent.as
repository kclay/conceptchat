package com.conceptualideas.chat.events
{
	import flash.events.Event;


	/**
	 * ...
	 * @author Conceptual Ideas 2008 Keyston Clay
	 */
	public class ChatClientManagerEvent extends Event
	{

		public static const CONNECTED_TO_SERVER:String = "connectedToServer";
		public static const CLIENT_DISCONNECTED:String = "clientDisconnected";
		public static const DISCONNECTED:String = "disconnected";
		public static const RE_CONNECTED:String = "reconnected";
		public static const NEW_MESSAGE:String = "newMessage";
		public static const USERLIST_UPDATED:String = "userlistUpdated";
		public static const ROOM_INFO_RETRIVED:String = "roomInfoRetrived";
		public static const NOTIFICATION:String = "notification";
		
		public static const NAME_CHANGED:String="nameChanged";

		protected var _data:Object

		public function ChatClientManagerEvent(type:String, data:Object=null)
		{
			super(type, true, true);
			_data = data;


		}



		public override function clone():Event
		{
			return new ChatClientManagerEvent(type, _data);
		}

		public override function toString():String
		{
			return formatToString("ChatClientEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

		public function get data():Object
		{
			return _data;
		}

	}
}