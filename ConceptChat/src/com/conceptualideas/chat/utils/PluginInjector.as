package com.conceptualideas.chat.utils
{
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;
	
	import flash.utils.Dictionary;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class PluginInjector extends XMLInjector
	{

		private var classPaths:Dictionary = new Dictionary();
		private var defaults:Array

		public function PluginInjector(defaults:Array=null)
		{
			this.defaults = defaults;
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
			var pluginXML:XMLList = xml.plugins.children();

			for each (var clazz:Class in defaults)
			{
				chatContext.loadPlugin(clazz);
			}
			processXML(pluginXML, function(pluginInstance:AbstractChatPlugin, name:String):void
				{

					if (pluginInstance)
						chatContext.loadPlugin(pluginInstance);
				})

			for each (var plug:XML in pluginXML)
			{
				if ("@path" in plug)
					chatContext.loadPlugin(String(plug.@path));
			}
		}

		override protected function isResolveAble(value:String):Boolean
		{
			return true;
		}



		override protected function resolveValue(value:String):*
		{


			var resolvedValue:*;
			var paths:Array = classPaths["plugins"];

			if (paths && paths.length)
			{
				var path:String


				for each (path in paths)
				{
					
					if ((resolvedValue = getClass(path + "::" + value)) is Class ||( resolvedValue = getClass(path + value)) is Class)
					{
						return new resolvedValue();
					}
				}
			}

			resolvedValue = getClass(value);
			if (resolvedValue)
				return resolvedValue;

			return value;

		}

	}

}