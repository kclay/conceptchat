package com.conceptualideas.chat.interfaces
{
	import com.conceptualideas.chat.models.ChatFieldMessage;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public interface IFormatter
	{
		function format(content:Object=null):String


		function formatSelf(content:Object=null):String


		function formatSystem(content:Object=null):String

		function reset():void
		function set parent(value:Object):void

		function get parent():Object


	}

}