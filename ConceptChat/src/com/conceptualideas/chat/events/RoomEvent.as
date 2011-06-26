package com.conceptualideas.chat.events
{
	import com.conceptualideas.chat.models.ChatUser;

	import flash.events.Event;

	public class RoomEvent extends Event
	{
		public static const USER_JOIN:String = "userJoined";
		public static const USER_DISCONNECTED:String = "userDisconnected"
		private var _user:ChatUser

		public function RoomEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,
			user:ChatUser=null)
		{
			super(type, bubbles, cancelable);
			_user = user;
		}

		override public function clone():Event
		{
			return new RoomEvent(type, bubbles, cancelable, user);
		}

		public function get user():ChatUser
		{
			return _user;
		}
	}
}