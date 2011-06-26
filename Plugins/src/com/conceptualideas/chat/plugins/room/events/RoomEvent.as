package com.conceptualideas.chat.plugins.room.events
{
	import flash.events.Event;

	public class RoomEvent extends Event
	{

		public static const CREATE:String = "create";
		public static const JOIN:String = "join";

		private var _room:String

		public function RoomEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,
			room:String=null)
		{
			super(type, bubbles, cancelable);
			_room = room;
		}

		public function get room():String
		{
			return _room;
		}
	}
}