package com.conceptualideas.chat.interfaces
{
	import com.conceptualideas.chat.models.ChatFieldMessage;


	public interface IChatWindow
	{

		function addMessage(message:ChatFieldMessage):void
		function get textInput():Object
		function set composerContext(value:IComposerContext):void
		function get composerContext():IComposerContext
		function clear():void

	}
}