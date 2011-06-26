package com.conceptualideas.chat.plugins.user
{
	import com.conceptualideas.chat.models.ChatUser;

	import flash.events.IEventDispatcher;

	public interface IUserDelegator extends IEventDispatcher
	{

		function set list(value:Array):void
		function get enabled():Boolean
		function set enabled(value:Boolean):void

	}
}