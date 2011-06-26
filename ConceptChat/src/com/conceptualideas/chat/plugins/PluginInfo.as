package com.conceptualideas.chat.plugins
{

	public class PluginInfo
	{
		private var factory:Class

		public function PluginInfo(factory:Class)
		{
			this.factory = factory;
		}

		public function newInstance(config:Object=null):AbstractChatPlugin
		{

			var plug:AbstractChatPlugin = new factory();
			for (var setting:* in config)
			{
				if (setting in plug)
					plug[setting] = config[setting];
			}
			return plug;

		}
	}
}