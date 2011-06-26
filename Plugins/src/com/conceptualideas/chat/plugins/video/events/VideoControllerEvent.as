package com.conceptualideas.chat.plugins.video.events
{
	import flash.events.Event;

	public class VideoControllerEvent extends Event
	{

		public static const USER_CLOSED_BLOCK:String = "userClosedBlock";

		private var _username:String

		public function VideoControllerEvent(type:String,
			bubbles:Boolean=false,
			cancelable:Boolean=false, username:String=null)
		{
			super(type, bubbles, cancelable);
			_username = username;
		}

		public function get username():String
		{
			return _username;
		}
	}
}