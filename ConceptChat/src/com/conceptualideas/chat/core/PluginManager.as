package com.conceptualideas.chat.core
{
	import com.conceptualideas.chat.events.PluginManagerEvent;
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;
	import com.conceptualideas.chat.plugins.IPluginFactory;
	import com.conceptualideas.chat.plugins.PluginInfo;
	
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.Dictionary;

	[Event(name="init", type="flash.events.Event")]
	[Event(name="pluginLoaded", type="com.conceptualideas.chat.events.PluginManagerEvent")]
	public class PluginManager extends EventDispatcher
	{
		public static const INIT:String = "init";
		private var loaded:Boolean = false;
		private var pendingPlugins:Array = [];
		private var loadedPlugins:Vector.<AbstractChatPlugin> = new Vector.<AbstractChatPlugin>();
		private var context:IChatContext

		public function PluginManager(target:IEventDispatcher=null)
		{
			super(target);
		}

		internal function init(chatContext:IChatContext):void
		{
			context = chatContext;
			var pluginContent:Object
			/*	for ea(pluginContent in pendingPlugins)
			   {
			   initPlugin(pluginContent, pendingPlugins[pluginContent]);
			 }*/
			while (pluginContent = pendingPlugins.shift())
			{
				initPlugin(pluginContent);
			}
			loaded = true;
			dispatchEvent(new Event(Event.INIT));

		}

		public function addPlugin(content:Object, config:Object=null):void
		{
			if (!loaded)
			{
			//	trace("pending",content);
				pendingPlugins.push(content)
			}
			else
			{
			//	trace("initPlugin",content);
				initPlugin(content, config);
			}
		}


		public function hasPlugin(nameOrClass:*):Boolean
		{
			for each (var plugin:AbstractChatPlugin in loadedPlugins)
				if (plugin is nameOrClass)
					return true;
			return false;
		}

		public function getPlugin(nameOrClass:*):AbstractChatPlugin
		{

			for each (var plug:AbstractChatPlugin in loadedPlugins)
			{
				if (plug is nameOrClass)
					return plug;
			}
			return null;
		}

		private var loaderCache:Dictionary = new Dictionary();

		private function initPlugin(content:Object, config:Object=null):void
		{
			var classInstance:AbstractChatPlugin

			var url:String;
			if (content is String)
			{
				//trace("loading plugin");
				url = content as String;



				var loader:Loader = new Loader();
				loaderCache[loader] = pendingPlugins[content]; // copy config over

				delete pendingPlugins[content];
				setupInfo(loader.contentLoaderInfo);
				var ctx:LoaderContext = url.match("https?:\/\/") ? new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain) : null;
				try
				{
					loader.load(new URLRequest(url), ctx);
				}
				catch (e:Error)
				{
					loader.load(new URLRequest(url));
				}
				
				
				return;
			}
			if (pendingPlugins[content])
			{
				delete pendingPlugins[content];
			}
			if (content is Class)
			{
				classInstance = new content() as AbstractChatPlugin;
			}
			else if (content is AbstractChatPlugin)
			{
				classInstance = content as AbstractChatPlugin;
			}

			if (classInstance)
			{
				classInstance.activate(context);
				if (config)
				{
					for (var c:String in config)
					{
						if (c in classInstance)
							classInstance[c] = config[c];
					}
				}
				loadedPlugins.push(classInstance);
				
				context.dispatchEvent(new PluginManagerEvent(PluginManagerEvent.PLUGIN_LOADED,
					false, false, classInstance));

			}
		}

		private function setupInfo(info:LoaderInfo):void
		{
			info.addEventListener(Event.INIT, onPluginLoaded);
			info.addEventListener(IOErrorEvent.IO_ERROR, onPluginLoadError);
		}

		private function destroyInfo(info:LoaderInfo):void
		{
			info.removeEventListener(Event.INIT, onPluginLoaded);
			info.removeEventListener(IOErrorEvent.IO_ERROR, onPluginLoadError);
		}

		private function onPluginLoaded(e:Event):void
		{
			var info:LoaderInfo = e.target as LoaderInfo;

			//trace(info.content is IPluginFactory);
			var content:IPluginFactory = info.content as IPluginFactory
			var config:Object  = loaderCache[info.loader];
			delete loaderCache[info.loader];
			destroyInfo(info);

			if (!content)
				return;


			var collection:Vector.<PluginInfo> = content.getPlugins();
			var plugInfo:PluginInfo
			for each (plugInfo in collection)
			{
				initPlugin(plugInfo.newInstance(), config);
			}

		}

		private function onPluginLoadError(e:IOErrorEvent):void
		{
			trace(e);
		}
	}
}