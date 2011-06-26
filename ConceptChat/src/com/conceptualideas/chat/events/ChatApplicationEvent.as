package com.conceptualideas.chat.events
{
	import flash.events.Event;

	public class ChatApplicationEvent extends Event
	{
		public static const OPEN_SETTINGS:String = "openSettings";
		public static const OPEN_USERLIST:String = "openUserList";

		public function ChatApplicationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}