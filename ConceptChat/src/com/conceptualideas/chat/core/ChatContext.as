package com.conceptualideas.chat.core
{
	import com.conceptualideas.chat.events.ChatContextEvent;
	import com.conceptualideas.chat.interfaces.IChatApplication;
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IComposerContext;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class ChatContext extends EventDispatcher implements IChatContext
	{

		public static const HOOK_BEFORE_SEND_MESSAGE_HOOK:uint = 0;




		private var _created:Boolean = false;

		private var pendingActions:Dictionary = new Dictionary();

		private var _pluginManager:PluginManager

		private var _chatScreens:Vector.<IScreenContext> = new Vector.<IScreenContext>();


		private var _chatApplication:IChatApplication

		private var _loaded:Boolean;

		public function get loaded():Boolean
		{
			return _loaded;
		}

		public function ChatContext(chatApplication:IChatApplication)
		{
			_chatApplication = chatApplication;
			init();
		}

		public function get chatApplication():IChatApplication
		{
			return _chatApplication;
		}
		private var _userName:String

		public function set userName(value:String):void
		{
			if (_userName == value)
				return;
			_userName = value;
			dispatchEvent(new Event("nameChanged"));
		}

		public function isGuest():Boolean
		{
			return _userName.indexOf("Guest") == 0;
		}

		public function get userName():String
		{
			return _userName;
		}


		private function init():void
		{
			_pluginManager = new PluginManager();
			_pluginManager.addEventListener(PluginManager.INIT, onPluginManagerInit);

		}


		private var _composerContext:IComposerContext;

		public function set composerContext(value:IComposerContext):void
		{

			if (_composerContext)
			{
				_composerContext.chatContext = null;
			}

			_composerContext = value;
			if (_composerContext)
				value.chatContext = this;


			if (numOfScreens)
			{
				for each (var chatScreen:IScreenContext in _chatScreens)
				{
					chatScreen.chatScreen.composerContext = _composerContext;
				}
			}


		}





		private var nameToScreenHash:Object = {};

		private function dispatch(event:String, screen:IScreenContext):void
		{
			dispatchEvent(new ChatContextEvent(event, false, false, screen));
		}

		public function addScreen(screen:IScreenContext):void
		{

			if (!screen)
				throw new RangeError("Can't pass null client ");

			_chatScreens.push(screen);
			if (_composerContext)
				screen.chatScreen.composerContext = _composerContext;
			nameToScreenHash[screen.name] = screen;
			dispatch(ChatContextEvent.ADDED_SCREEN, screen);
		}

		public function get numOfScreens():Number
		{
			return _chatScreens.length;
		}



		public function get chatScreens():Vector.<IScreenContext>
		{
			return _chatScreens.slice();
		}

		private function inScreenRange(index:int):Boolean
		{
			return (index >= 0 && index < _chatScreens.length)

		}

		public function getScreenAt(index:int):IScreenContext
		{
			if (!inScreenRange(index))
				throw new RangeError("Range error : ChatContext.getChatClientAt");

			return _chatScreens[index];
		}

		public function hasScreen(name:String):Boolean
		{
			return nameToScreenHash[name] ? true : false;
		}

		public function getScreenByName(name:String):IScreenContext
		{

			return (nameToScreenHash[name]) ?
				IScreenContext(nameToScreenHash[name])
				: null;

		}

		public function getScreenIndex(screenContext:IScreenContext):int
		{
			if (!screenContext)
				throw new Error("Can't pass a null screenContext, ChatContext.getScreenIndex");
			return _chatScreens.indexOf(screenContext);
		}

		public function removeScreen(screen:IScreenContext):IScreenContext
		{
			return removeScreenAt(getScreenIndex(screen));
		}

		public function removeScreenAt(index:int):IScreenContext
		{
			if (!inScreenRange(index))
				throw new Error("Range error : ChatContext.removeScreenAt");
			var screenContext:IScreenContext = _chatScreens[index];

			dispatch(ChatContextEvent.REMOVED_SCREEN, screenContext);
			delete nameToScreenHash[screenContext.name];
			if (screenContext is IDisposable)
				IDisposable(screenContext).dispose();
			_chatScreens.splice(index, 1)
			return screenContext;

		}



		public function create(name:String):void
		{
			_userName = name;
			_created = true;
			_pluginManager.init(this);

		}

		public function get pluginManager():PluginManager
		{
			return _pluginManager;
		}

		public function hasPlugin(nameOrClass:*):Boolean
		{
			return _pluginManager.hasPlugin(nameOrClass);
		}

		public function getPlugin(nameOrClass:*):AbstractChatPlugin
		{
			return _pluginManager.getPlugin(nameOrClass);

		}

		public function loadPlugin(content:Object):void
		{
			_pluginManager.addPlugin(content);
		}

		private function onPluginManagerInit(e:Event):void
		{
			dispatchEvent(new ChatContextEvent(ChatContextEvent.INIT));
			_loaded = true;
		}


	}
}