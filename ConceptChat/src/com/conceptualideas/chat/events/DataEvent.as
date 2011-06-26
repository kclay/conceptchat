package com.conceptualideas.chat.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class DataEvent extends Event 
	{
		
		public function DataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new DataEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DataEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}