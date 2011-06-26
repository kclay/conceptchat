package com.conceptualideas.chat.composers.composerClasses
{
	import com.conceptualideas.chat.formatters.TemplateFormatter;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.utils.Utils;


	public class ContainerComposer extends AbstractComposer
	{
		private static const HEADER:String = "<flow:TextFlow xmlns:flow = 'http://ns.adobe.com/textLayout/2008'>"
		private static const TEMPLATE:String = HEADER + "<flow:div id='container' color='{messageColor}' fontStyle='{fontStyle}' fontSize='{messageSize}' fontFamily='{messageFont}'>{message}</flow:div></flow:TextFlow>";
		protected var _tokens:Object;
		protected var _historyColor:String = "#888888";
		protected var _systemColor:String = "#888888";
		protected var _historyItalicize:Boolean = true;
		protected var templateFormatter:TemplateFormatter;




		protected function setupTemplate():void
		{
			templateFormatter = new TemplateFormatter(null, TEMPLATE);
		}
		public function ContainerComposer()
		{


			setupTemplate();

		}

		public function set systemColor(color:Object):void
		{
			_systemColor = Utils.parseColor(color, String) as String;
		}

		public function set historyColor(color:Object):void
		{
			_historyColor = Utils.parseColor(color, String) as String;
		}

		public function set historyItalicize(value:Object):void
		{
			_historyItalicize = Boolean(value) === true;
		}

		/**
		 * Sets tokens for current compose phase, the tokens will be
		 * set to null after compose has been called
		 */
		public function set tokens(value:Object):void
		{
			_tokens = value;
		}

		override public function compose(content:Object, format:String=ComposeFormats.DEFAULT):String
		{

			if (_tokens.isHistory)
			{
				_tokens.messageColor = _historyColor;
			}
			if (_tokens.from == "#system")
			{
				_tokens.messageColor = _systemColor;
			}

			_tokens.fontStyle = _historyItalicize && _tokens.isHistory || _tokens.from == "#system" ? 'italic' : 'normal';
			templateFormatter.tokens = _tokens;
			
			// apply bbcodes
			
			_tokens = null;
			return templateFormatter.format();
		}
	}
}