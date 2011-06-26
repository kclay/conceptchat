package com.conceptualideas.chat.interfaces
{
	import com.conceptualideas.chat.models.ChatFieldMessage;
	
	import flash.events.IEventDispatcher;
	
	/**
	 * 
	 * @author cideas
	 * 
	 */
	[Event(name="screenContextMessageRecieved",type="com.conceptualideas.chat.events.ChatScreenContextEvent")]
	[Event(name="screenContextSendMessage",type="com.conceptualideas.chat.events.ChatScreenContextEvent")]
	public interface IScreenContext extends IEventDispatcher, IDisposable
	{
		
	
		/**
		 * 
		 * @return 
		 * 
		 */
		function get chatScreen():IChatScreen
		/**
		 * 
		 * @return 
		 * 
		 */
		function get chatClient():IChatClient
		/**
		 * 
		 * @param chatMessage
		 * 
		 */
		function addMessage(chatMessage:ChatFieldMessage):void
		/**
		 * Sends a message to ALL users, this entrypoint will fire an
		 * ChatScreenContextEvent.SEND_MESSAGE to allow listeners to modify the message, apply hooks
		 * @param chatMessage
		 * 
		 */
		function sendMessage(chatMessage:ChatFieldMessage):void
		/**
		 * 
		 * @return 
		 * 
		 */
		function get title():String
		/**
		 * 
		 * @param value
		 * 
		 */
		function set title(value:String):void
		
		/**
		 * Returns the room name for the screen
		 * */
		function get name():String
			
		function set enabled(value:Boolean):void
		
	}
}