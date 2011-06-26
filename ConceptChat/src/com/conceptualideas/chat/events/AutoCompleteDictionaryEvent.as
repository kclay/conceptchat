package com.conceptualideas.chat.events
{
	import flash.events.Event;
	
	public class AutoCompleteDictionaryEvent extends Event
	{
		public static const UPDATED:String="updated";
		
		public function AutoCompleteDictionaryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}