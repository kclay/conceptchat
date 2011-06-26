package com.conceptualideas.chat.events
{
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;

	import flash.events.Event;

	public class PluginManagerEvent extends Event
	{
		public static const PLUGIN_LOADED:String = "pluginLoaded";
		private var _plugin:AbstractChatPlugin

		public function PluginManagerEvent(type:String, bubbles:Boolean=false,
			cancelable:Boolean=false, plugin:AbstractChatPlugin=null)
		{
			super(type, bubbles, cancelable);
			_plugin = plugin;
		}

		public function get plugin():AbstractChatPlugin
		{
			return _plugin;
		}
	}
}