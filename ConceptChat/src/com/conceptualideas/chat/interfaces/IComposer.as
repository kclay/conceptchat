package com.conceptualideas.chat.interfaces
{
	import com.conceptualideas.chat.composers.composerClasses.ComposeFormats;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	
	import flashx.textLayout.elements.TextFlow;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public interface IComposer
	{
		
		/**
		 * Composes content 
		 * @param	content
		 * @param	format
		 * @return Final markup as TextFlow markup
		 */
		function compose(content:Object, format:String = "default"):String
		/**
		 * Check to see paser is bound to composer
		 * @param	clazz
		 * @return
		 */
		function hasParser(clazz:Class):Boolean
		/**
		 * Get bounded paser
		 * @param	nameOrClass This can be either a String or Class Instance
		 * @return bounded instance of IPaser
		 */
		function getParser(nameOrClass:*):IParser
		/**
		 * Bounds a paser to current composer
		 * @param	parser
		 */
		function addParser(parser:IParser):void
			
		function get context():IComposerContext
		
		
		function set context(value:IComposerContext):void
			
		function newFormatter(clazz:Class):IFormatter
		
	}

}