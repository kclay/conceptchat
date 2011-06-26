package com.conceptualideas.chat.formatters
{

	public class LinkFormatter extends TemplateFormatter
	{
		private const TEMPLATE:String = " <flow:a styleName='linkElement' href='{href}' target='_blank' color='{linkFontColor}'><flow:linkNormalFormat>" +
			"<flow:TextLayoutFormat color='{linkFontColor}'/></flow:linkNormalFormat>{text}</flow:a>";

		public function LinkFormatter()
		{
			super(null, TEMPLATE);
		}
	}
}