package com.conceptualideas.chat.plugins.user.events
{
	import flash.events.Event;

	public class UserListEvent extends Event
	{

		public static const NAME_CLICKED:String = "nameClicked";


		public var x:Number
		public var y:Number
		public var name:String

		public function UserListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}