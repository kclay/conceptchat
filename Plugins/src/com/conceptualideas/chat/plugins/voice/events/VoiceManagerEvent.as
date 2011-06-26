package com.conceptualideas.chat.plugins.voice.events
{
	import flash.events.Event;

	public class VoiceManagerEvent extends Event
	{
		public static const CONNECTED:String = "connected";
		public static const DISCONNECTED:String = "disconnected";

		private var _streamName:String

		public function VoiceManagerEvent(type:String, bubbles:Boolean=false,
			cancelable:Boolean=false, streamName:String=null)
		{
			super(type, bubbles, cancelable);
			_streamName = streamName;
		}

		public function get streamName():String
		{
			return _streamName;
		}
	}
}