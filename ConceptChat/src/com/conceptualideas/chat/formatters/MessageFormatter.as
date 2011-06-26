package com.conceptualideas.chat.formatters
{
	import com.conceptualideas.chat.formatters.AbstractFormatter;
	import com.conceptualideas.chat.models.ChatFieldMessage;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class MessageFormatter extends AbstractFormatter
	{

		public function MessageFormatter(parent:Object=null)
		{
			super(parent);

		}

		override public function format(content:Object=null):String
		{
			return content ? content.message || "" : "";
		}

		override public function formatSelf(content:Object=null):String
		{
			return content ? content.message || "" : "";
		}

		override public function formatSystem(content:Object=null):String
		{
			return content ? content.message || "" : "";
		}

	}

}