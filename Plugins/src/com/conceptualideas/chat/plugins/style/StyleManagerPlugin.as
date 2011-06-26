package com.conceptualideas.chat.plugins.style
{
	import com.conceptualideas.chat.interfaces.IInjector;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;

	import flash.utils.Dictionary;

	public class StyleManagerPlugin extends AbstractChatPlugin implements IStyleManagerPlugin, IInjector
	{
		private var styles:Object = {};

		public function StyleManagerPlugin()
		{
			super();
		}

		public function inject(context:Object):void
		{
			var xml:XML = XML(context);
			for each(var node:XML in xml.children())
			{
				setStyle(node.@path, String(node.@value));
			}
		}

		public function getStyle(styleProp:String):*
		{
			return styles[styleProp];
		}

		public function setStyle(styleProp:String, value:*):void
		{
			var oldValue:* = styles[styleProp];
			if (oldValue != value)
			{

				styles[styleProp] = value;
					// TODO: dispatch change
			}
		}
	}
}