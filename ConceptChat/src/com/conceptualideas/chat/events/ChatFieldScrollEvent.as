package com.conceptualideas.chat.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class ChatFieldScrollEvent extends Event {
		
		public static const SCROLL:String = "scroll";
		private var _verticalScrollPosition:Number
		private var _horizontalScrollPosition:Number
		public function ChatFieldScrollEvent(verticalScrollPosition:Number,horizontalScrollPosition:Number) { 
			super(ChatFieldScrollEvent.SCROLL, false,false);
			_verticalScrollPosition = verticalScrollPosition;
			_horizontalScrollPosition = horizontalScrollPosition;
		} 
		
		public override function clone():Event { 
			return new ChatFieldScrollEvent(verticalScrollPosition, horizontalScrollPosition);
		} 
		
		public override function toString():String { 
			return formatToString("ChatFieldScrollEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get verticalScrollPosition():Number { return _verticalScrollPosition; }
		
		public function get horizontalScrollPosition():Number { return _horizontalScrollPosition; }
		
	}
	
}