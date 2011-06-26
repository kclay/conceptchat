package com.conceptualideas.chat.formatters
{
	import com.conceptualideas.chat.interfaces.IFormatter;
	import com.conceptualideas.chat.models.ChatFieldMessage;


	public class AbstractFormatter implements IFormatter
	{

		private var _parent:Object
		
		public function set parent(value:Object):void{
			_parent = value;
		}
		public function get parent():Object{
			return _parent;
		}
		protected function compile(template:String, tokens:Object):String
		{
			var regex:RegExp;
			
			for (var key:String in tokens)
			{
				regex=new RegExp("\{"+key+"\}","g");
				template = template.replace(regex, tokens[key]);
			}
			return template;

		}

		public function AbstractFormatter(parent:Object=null)
		{
			_parent = parent;
		}

		public function format(content:Object=null):String
		{
			return "";
		}

		public function formatSelf(content:Object=null):String
		{
			return "";
		}

		public function formatSystem(content:Object=null):String
		{
			return "";
		}
		public function reset():void{
			
		}
	}
}