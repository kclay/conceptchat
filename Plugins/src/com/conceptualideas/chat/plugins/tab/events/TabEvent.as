package com.conceptualideas.chat.plugins.tab.events
{
	import flash.events.Event;

	public class TabEvent extends Event
	{

		public static const TAB_CHANGED:String = "tabChanged"

		public static const TAB_REMOVED:String = "tabRemove";

		private var _name:String

		public function TabEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,
			name:String=null)
		{
			super(type, bubbles, cancelable);
			_name = name;
		}

		public function get name():String
		{
			return _name;
		}
	}
}