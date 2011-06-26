package com.conceptualideas.chat.parsers
{
	import com.conceptualideas.chat.interfaces.IParser;

	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.formats.TextLayoutFormat;

	public class BBCodeParser implements IParser
	{

		public static const CSS_COLOR_CODES:Object = {
				red:"#FF0000",
				purple:"#800080",
				black:"#000000",
				silver:"#C0C0C0",
				gray:"#808080",
				white:"#FFFFFF",
				maroon:"#800000",
				fuchsia:"#FF00FF",
				green:"#008000",
				lime:"#00FF00",
				olive:"#808000",
				yellow:"#FFFF00",
				navy:"#000080",
				blue:"#0000FF",
				teal:"#008080",
				aqua:"#00FFFF"

			}
		private var codes:Vector.<Object> = Vector.<Object>([
			{
				regex:/\[a:([a-z]+)?\](.*?)\[\/a\]/gi,
				replace:anchor_replaceHandler
			},
			{
				regex:/\[color[=|:]([#0x]?x?)([0-9a-z|omit]+)\](.*?)\[\/color\]/gi,
				replace:color_replaceHandler
			}

			])

		public function BBCodeParser()
		{

		}

		private function anchor_replaceHandler(raw:String, event:String, text:String, ... args:Array):String
		{
			raw = "<flow:a ";
			if (event)
			{
				raw += 'href="event:' + event + '"';
			}
			else
			{
				raw += "href='" + text + '"';
			}
			raw += ">" + text + "</flow:a>";
			return raw;
		}

		private function color_replaceHandler(raw:String, striped:String, color:String, text:String, ... args:Array):String
		{
			if (CSS_COLOR_CODES[color])
			{
				color = String(CSS_COLOR_CODES[color]);
			}
			else if (color == "omit" || !color.match(/^[a-f0-9]{6}$/i))
			{
				return text;
			}
			else
			{
				color = "#" + color;

			}
			if (text.indexOf("<flow:") == 0)
			{
				var insertIndex:int = text.indexOf(" ");
				return text.substr(0, insertIndex) + 'color="' + color + '"' + text.substr(insertIndex);


			}
			return "<flow:span color=\"" + color + "\">" + text + "</flow:span>";
		}

		public function parse(raw:String):String
		{
			var code:Object
			for each (code in codes)
			{
				raw = raw.replace(code.regex, code.replace);
			}
			return raw;
		}

		public function get name():String
		{
			return null;
		}
	}
}