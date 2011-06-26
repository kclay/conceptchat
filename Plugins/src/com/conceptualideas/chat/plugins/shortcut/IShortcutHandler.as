package com.conceptualideas.chat.plugins.shortcut
{
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;

	public interface IShortcutHandler
	{
		function handle(token:String, screenContext:IScreenContext, chatMessage:ChatFieldMessage):Boolean
		function canHandle(token:String):Boolean
		function getShortcuts():Object
	}
}