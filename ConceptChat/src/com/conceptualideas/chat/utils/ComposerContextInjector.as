package com.conceptualideas.chat.utils
{
	import com.conceptualideas.chat.composers.TLFComposerContext;
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IComposer;
	import com.conceptualideas.chat.interfaces.IComposerContext;
	import com.conceptualideas.chat.interfaces.IParser;
	import com.conceptualideas.chat.parsers.BBCodeParser;

	import flash.utils.Dictionary;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class ComposerContextInjector extends XMLInjector
	{

		private var classPaths:Dictionary = new Dictionary();

		public function ComposerContextInjector()
		{

		}

		private function addClassPath(name:String, xml:XML, extra:String=null):void
		{
			classPaths[name] = ["com.conceptualideas.chat." + name + ((extra) ? "." + extra : "")];
			if (xml.classPaths.attribute(name) != "")
				classPaths[name].push(String(xml.classPaths.attribute(name)));
		}

		override public function inject(chatContext:IChatContext, xml:XML):void
		{

			addClassPath("plugins", xml);
			addClassPath("parsers", xml);
			addClassPath("composers", xml, "composerClasses");

			addClassPath("formatters", xml);


			var composerXML:XMLList = xml.composerContext;

			var composerContext:IComposerContext = new TLFComposerContext(chatContext);

			var list:XMLList = composerXML.extras.children();
			processXML(list, function(instance:Object, name:String):void
				{
					extras[name] = instance;
				});
			list = composerXML.parsers.children();

			var messageComposer:IComposer = composerContext.messageComposer;

			processXML(list, function(parser:IParser, name:String):void
				{
					if (parser)
						messageComposer.addParser(parser);
				}) // add link support
			messageComposer.addParser(new BBCodeParser());
			list = composerXML.composers.children();

			processXML(list, function(composer:IComposer, name:String):void
				{
					if (composer && Object(composerContext).hasOwnProperty(name)){
						composerContext[name] = composer;

					}
				});
			//	chatContext.chatScreens[0].chatScreen.composerContext = composerContext;
			//chatContext.chatScreen.composerContext = composerContext

			extras = null;
			classPaths = null;
			chatContext.composerContext = composerContext;


		}

		override protected function isResolveAble(value:String):Boolean
		{
			return (value.indexOf("[") == -1) ? false : true;
		}



		override protected function resolveValue(value:String):*
		{

			if (value.indexOf("[") == -1)
				return super.resolveValue(value);
			var bundle:String = value.substr(1, value.indexOf("]") - 1);
			value = value.substr(value.indexOf("]") + 1);

			var paths:Array = classPaths[bundle];

			if (paths && paths.length)
			{
				var path:String
				var resolvedValue:*

				for each (path in paths)
				{
					resolvedValue = getClass(path + "::" + value);
					if (resolvedValue is Class)
					{
						return new resolvedValue();
					}
				}
			}
			return value;

		}



	}

}