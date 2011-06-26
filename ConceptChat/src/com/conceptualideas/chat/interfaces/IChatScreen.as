package com.conceptualideas.chat.interfaces
{
	import com.conceptualideas.chat.interfaces.IEmoticonMapper;
	import com.conceptualideas.chat.models.ChatFieldMessage;

	import flash.events.IEventDispatcher;

	import flashx.textLayout.elements.TextFlow;

	public interface IChatScreen extends IEventDispatcher
	{

		function setHandlers(messagePreHandler:Function, messagePostHandler:Function):void

		function set enabled(value:Boolean):void
		function clear():void
		function set composerContext(value:IComposerContext):void
		function get composerContext():IComposerContext

		function appendText(text:String):void
		function addMessage(chatMessage:ChatFieldMessage):void
		function dispatchMessage(message:String):Boolean
		function get textInputObject():Object
	

	}
}