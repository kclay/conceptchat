package com.conceptualideas.chat.formatters
{
	import com.conceptualideas.chat.formatters.BasicStampFormatter;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.utils.Utils;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class ProfileStampFormatter extends BasicStampFormatter
	{
		public static const PROFILE_CLICKED:String = "profileUserNameClicked";
		private var _linkColor:Object

		public function ProfileStampFormatter(parent:Object=null)
		{
			super(parent);

		}

		public function set linkFontColor(v:Object):void
		{
			_linkColor = Utils.parseColor(v, String);

		}

		public function get linkFontColor():Object
		{
			return _linkColor;
		}

		protected function isTemplateable():Boolean
		{
			return (currentMessage.isHistory || !currentMessage.isAcceptableUser()) ? false : true;
		}

		override protected function get template():String
		{
			return (currentMessage.from == "#system") ? "" : composeTemplate();

		}

		protected function composeTemplate():String
		{
			currentMessage.fromColor = _linkColor as String;
			if (useHTMLMarkup){
				return "<font color='{fromColor}' size='{fromSize}' face='{fromFont}'>" +
				"<a href='event:profileUserNameClicked'>{from}</a></font>";
			}
			return "<flow:a href='event:profileUserNameClicked' styleName='profileName'>" +
				"<flow:linkNormalFormat>" +
				"<flow:TextLayoutFormat color='{fromColor}' fontSize='{fromSize}' fontFamily='{fromFont}' textDecoration='none'/>" +
				"</flow:linkNormalFormat>" +
				"{from}</flow:a>: ";
		}

		override protected function internalFormat(chatMessage:ChatFieldMessage):String
		{

			var defaultFromColor:String = chatMessage.fromColor;

			var content:String = super.internalFormat(chatMessage);

			chatMessage.fromColor = defaultFromColor;

			return content;
		}

	}

}