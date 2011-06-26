package com.conceptualideas.chat.formatters
{
	import com.conceptualideas.chat.formatters.AbstractFormatter;
	import com.conceptualideas.chat.models.ChatFieldMessage;

	import flashx.textLayout.elements.LinkElement;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class BasicStampFormatter extends TemplateFormatter
	{



		protected var currentMessage:ChatFieldMessage;

		public function BasicStampFormatter(parent:Object=null)
		{
			super(parent);
		}

		override protected function get template():String
		{
			if (currentMessage.isHistory)
				return "<flow:span  fontSize='{fromSize}' fontFamily='{fromFont}' >{from}</flow:span> : ";
			if (currentMessage.from == "#system")
				return "";
			if (useHTMLMarkup){
				return "<font color='{fromColor}' size='{fromSize}' face='{fromFont'}>{from}</font>"
			}
			return "<flow:span color='{fromColor}' fontSize='{fromSize}' fontFamily='{fromFont}' >{from}</flow:span> : ";
		}


		protected function internalFormat(chatMessage:ChatFieldMessage):String
		{
			updateTokens({
					fromColor:chatMessage.fromColor,
					fromSize:chatMessage.fromSize,
					fromFont:chatMessage.fromFont,
					from:chatMessage.from
				});
			return super.format()

		}



		override public function format(content:Object=null):String
		{
			currentMessage = content as ChatFieldMessage;
			return internalFormat(currentMessage);
		}

		override public function formatSelf(content:Object=null):String
		{
			currentMessage = content as ChatFieldMessage;
			return internalFormat(currentMessage);
		}

		override public function formatSystem(content:Object=null):String
		{
			currentMessage = content as ChatFieldMessage;
			return internalFormat(currentMessage);
		}
	}

}