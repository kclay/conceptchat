package com.conceptualideas.chat.events
{
	import flash.events.Event;
	
	public class UserListEvent extends Event
	{
		
	
		public function UserListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}