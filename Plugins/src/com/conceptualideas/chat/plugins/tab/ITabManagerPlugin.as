package com.conceptualideas.chat.plugins.tab
{
	
	import com.conceptualideas.chat.interfaces.IScreenContext;
	
	import flash.events.IEventDispatcher;

	[Event(name="tabChanged", type="flash.events.Event")]
	public interface ITabManagerPlugin extends IEventDispatcher
	{

		function getActiveTabName():String
		function getActiveTab():IScreenContext

	}
}