package com.conceptualideas.chat.interfaces
{
	import com.conceptualideas.chat.interfaces.IParser;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.TextFlow;

	/**
	 * 
	 * @author cideas
	 * 
	 */
	public interface IComposerContext
	{
		/**
		 * 
		 * @param v
		 * 
		 */
		function set config(v:IConfiguration):void		
		/**
		 * Will compose the chat message into a valid FlowElement later to be added 
		 * to the requested TextFlow
		 * @param chatMessage ChatFieldMessage to compose into TextFlow Markup
		 * @return 
		 * 
		 */
		function compose(chatMessage:ChatFieldMessage):Object
		/**
		 * 
		 * @param composer
		 * 
		 */
		function set messageComposer(composer:IComposer):void
		/**
		 * 
		 * @return 
		 * 
		 */
		function get messageComposer():IComposer
		/**
		 * 
		 * @return 
		 * 
		 */
		function get chatContext():IChatContext
		/**
		 * 
		 * @param value
		 * 
		 */
		function set chatContext(value:IChatContext):void
		/**
		 * 
		 * @param clazz
		 * @return 
		 * 
		 */
		function newComposer(clazz:Class):IComposer
		/**
		 * 
		 * @param value
		 * 
		 */
		function set stampComposer(value:IComposer):void
		/**
		 * 
		 * @return 
		 * 
		 */
		function get stampComposer():IComposer
	//	function get stampComposer():IComposer
	
	}
}