package com.conceptualideas.chat.interfaces
{
	import flash.events.IEventDispatcher;

	public interface IChatApplication extends IEventDispatcher
	{

		function set enabled(value:Boolean):void
	}
}