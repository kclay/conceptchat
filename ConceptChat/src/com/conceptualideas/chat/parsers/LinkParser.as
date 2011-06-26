package com.conceptualideas.chat.parsers
{
	import com.conceptualideas.chat.formatters.LinkFormatter;
	import com.conceptualideas.chat.formatters.TemplateFormatter;
	import com.conceptualideas.chat.interfaces.IFormatter;
	import com.conceptualideas.chat.interfaces.IParser;
	import com.conceptualideas.chat.interfaces.ITemplateFormatter;
	import com.conceptualideas.chat.utils.HTMLTools;

	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.LinkElement;

	public class LinkParser implements IParser
	{
		private static const LINK_REGX:RegExp = HTMLTools.LINK_REGX;

		private var _linkFontColor:String = "#83AAD1";

		public var formatter:ITemplateFormatter = new LinkFormatter();

		public function LinkParser()
		{

			
		}

		public function set linkFontColor(v:Object):void
		{
			if (v is uint)
			{
				_linkFontColor = "#" + uint(v).toString(16);
			}
			else if (v is String)
			{
				_linkFontColor = v as String;
			}
		}

		public function get linkFontColor():Object
		{
			return _linkFontColor;
		}



		public function parse(raw:String):String
		{

			if (!LINK_REGX.test(raw))
				return raw;
			LINK_REGX.exec("");
			var self:Object = this;

			var link:String;
			var title:String
			return raw.replace(LINK_REGX, function(... args):String
				{

					title = args[1] ? args[1].replace("\"", "") : null;
					link = args.splice(2,2).join("");

					if (title && title.lastIndexOf(":") == title.length - 1)
						title = title.substr(0, title.length - 1);
					formatter.updateTokens({
							href:link,
							text:title ? title : link,
							linkFontColor:linkFontColor
						});
					return formatter.format();
				});


		}

		public function get name():String
		{
			return "link";
		}
	}
}