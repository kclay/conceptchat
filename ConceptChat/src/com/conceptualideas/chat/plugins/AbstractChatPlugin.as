package com.conceptualideas.chat.plugins
{
	import com.conceptualideas.chat.events.ChatContextEvent;
	import com.conceptualideas.chat.events.PluginManagerEvent;
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IChatScreen;
	import com.conceptualideas.chat.interfaces.IChatWindow;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.interfaces.IDock;
	import com.conceptualideas.chat.interfaces.IDockable;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	

	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class AbstractChatPlugin extends EventDispatcher implements IDisposable
	{
		protected var chatContext:IChatContext

		public function AbstractChatPlugin()
		{
		}

		protected function init():void
		{

		}


		final public function activate(context:IChatContext):void
		{
			chatContext = context;

			chatContext.addEventListener(ChatContextEvent.ADDED_SCREEN, chatContextHandler)
			chatContext.addEventListener(ChatContextEvent.REMOVED_SCREEN, chatContextHandler)
			chatContext.addEventListener(ChatContextEvent.INIT, chatContextHandler);
			chatContext.addEventListener(PluginManagerEvent.PLUGIN_LOADED, chatContextHandler);

			init();

			if (chatContext && chatContext.loaded)
				onContextInit()
			const activeScreens:Vector.<IScreenContext> = chatContext.chatScreens;
			var screen:IScreenContext
			for each (screen in activeScreens)
			{
				onScreenAdded(screen);
			}
			onActivated();


		}



		protected function onActivated():void
		{

		}

		private function chatContextHandler(e:Event):void
		{
			switch (e.type)
			{
				case ChatContextEvent.ADDED_SCREEN:
					onScreenAdded(ChatContextEvent(e).screen);

					break;
				case ChatContextEvent.REMOVED_SCREEN:
					onScreenRemoved(ChatContextEvent(e).screen);
					break;
				case ChatContextEvent.INIT:
					onContextInit();
					break;
				case PluginManagerEvent.PLUGIN_LOADED:
					onPluginLoaded(PluginManagerEvent(e).plugin);
					break
			}

		}

		protected function onPluginLoaded(plugin:AbstractChatPlugin):void
		{

		}

		public function dispose():void
		{

			const activeScreens:Vector.<IScreenContext> = chatContext.chatScreens;
			var screen:IScreenContext
			for each (screen in activeScreens)
			{
				onScreenRemoved(screen);
			}
			chatContext.removeEventListener(ChatContextEvent.ADDED_SCREEN, chatContextHandler)
			chatContext.removeEventListener(ChatContextEvent.REMOVED_SCREEN, chatContextHandler)
			chatContext.removeEventListener(ChatContextEvent.INIT, chatContextHandler);
			chatContext = null;
		}




		protected function onContextInit():void
		{

		}

		protected function onScreenAdded(screen:IScreenContext):void
		{

		}

		protected function onScreenRemoved(screen:IScreenContext):void
		{

		}
	}
}