package com.conceptualideas.chat.plugins.media
{
	import flash.events.Event;

	public class MediaManagerEvent extends Event
	{

		public static const CONNECTED:String = "connected";
		public static const DISCONNECTED:String  = "disconnected";
		private var _stream:String

		public function MediaManagerEvent(type:String, stream:String=null)
		{
			super(type, false, false);
			_stream = stream;
		}

		public function get stream():String
		{
			return _stream;
		}
	}
}