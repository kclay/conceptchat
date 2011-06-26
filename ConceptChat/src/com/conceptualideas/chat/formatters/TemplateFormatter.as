package com.conceptualideas.chat.formatters
{
	import com.conceptualideas.chat.formatters.AbstractFormatter;
	import com.conceptualideas.chat.interfaces.ITemplateFormatter;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class TemplateFormatter extends AbstractFormatter implements ITemplateFormatter
	{

		private var _template:String
		private var _tokens:Object

		public var useHTMLMarkup:Boolean = false;

		public function TemplateFormatter(parent:Object=null, template:String="", tokens:Object=null)
		{
			super(parent);
			this._template = template;
			_tokens = tokens || {};
		}


		protected function get template():String
		{
			return _template;
		}

		public function set tokens(v:Object):void
		{
			_tokens = v;
		}

		public function updateTokens(toks:Object):void
		{
			_tokens = (!_tokens) ? {} : _tokens;
			for (var t:String in toks)
			{
				_tokens[t] = toks[t];
			}
		}

		override public function format(content:Object=null):String
		{
			return compile(content ? content as String : template, _tokens);
		}

		override public function reset():void
		{
			_tokens = {};
		}


	}

}