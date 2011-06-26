package com.conceptualideas.chat.events
{
	
	import com.conceptualideas.chat.interfaces.IScreenContext;
	
	import flash.events.Event;

	public class ChatContextEvent extends Event
	{
		public static const ADDED_SCREEN:String = "addedScreen";
		public static const REMOVED_SCREEN:String = "removedScreen";
		public static const INIT:String = "init";

		private var _screen:IScreenContext
		private var _index:int

		public function ChatContextEvent(type:String, bubbles:Boolean=false,
			cancelable:Boolean=false, screen:IScreenContext=null)
		{
			super(type, bubbles, cancelable);
			_screen = screen;			
		
		}

		/**
		 * Returns and instance of IScreenContext
		 * */
		public function get screen():IScreenContext
		{
			return _screen;
		}
	}
}