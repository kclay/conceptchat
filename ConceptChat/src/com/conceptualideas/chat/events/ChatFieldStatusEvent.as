package com.conceptualideas.chat.events {
	import flash.events.Event;
	import flashx.textLayout.container.ContainerController;
	
	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class ChatFieldStatusEvent extends Event {
		public static const UPDATE_COMPLETE:String = "update_complete";
		private var _controller:ContainerController
		public function ChatFieldStatusEvent(type:String,controller:ContainerController) { 
			super(type, false,false);
			_controller = controller;
			
		} 
		
		public override function clone():Event { 
			return new ChatFieldStatusEvent(type, _controller);
		} 
		
		
		
		public function get controller():ContainerController { return _controller; }
		
		
		public override function toString():String { 
			return formatToString("ChatFieldStatusEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}