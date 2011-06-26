package com.conceptualideas.chat.composers
{
	import com.conceptualideas.chat.composers.composerClasses.HTMLContainerComposer;
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class HTMLComposerContext extends AbstractComposerContext
	{

		public function HTMLComposerContext(chatContext:IChatContext=null)
		{

			super(chatContext);
			containerComposer = new HTMLContainerComposer();
		}
		override public function compose(chatMessage:ChatFieldMessage):Object
		{
			var message:String = String(super.compose(chatMessage)).replace(/0x/g, "#");
			trace(message);
			return message;
		}


	}

}