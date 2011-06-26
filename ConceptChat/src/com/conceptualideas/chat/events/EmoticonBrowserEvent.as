package com.conceptualideas.chat.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class EmoticonBrowserEvent extends Event {
		public static const SELECTED:String = "selected";
		/**
		 * Current selected emoticon text 
		 */
		private var _selected:String;
		public function EmoticonBrowserEvent(type:String,selected:String) { 
			super(type, true,false);
			_selected = selected;
		} 
		
		public override function clone():Event { 
			return new EmoticonBrowserEvent(type, _selected);
		} 
		
		public override function toString():String { 
			return formatToString("EmoticonBrowserEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get selected():String { return _selected; }
		
	}
	
}