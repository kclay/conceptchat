package com.conceptualideas.chat.plugins.shortcut
{
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;
	import com.conceptualideas.chat.tasks.SystemMessageTask;

	public class AbstractShortcutPlugin extends AbstractChatPlugin implements IShortcutHandler
	{
		protected var canRegisterShortcuts:Boolean = true;

		public function AbstractShortcutPlugin()
		{
			super();
		}

		protected function getTokens(str:String):Array
		{
			return str.split(" ").splice(1);
		}

		override protected function onContextInit():void
		{
			super.onContextInit();


			if (canRegisterShortcuts && chatContext.hasPlugin(IShortcutPlugin))
				register();
		}

		protected function sendSystemMessage(screenContext:IScreenContext, message:String):void
		{
			if (screenContext == null)
			{
				new SystemMessageTask(screenContext, message, chatContext).run();
			}
			else
			{
				new SystemMessageTask(screenContext, message).run();
			}


		}

		protected function register():void
		{

			IShortcutPlugin(chatContext.getPlugin(IShortcutPlugin)).registerShortcutHandler(this);

		}

		protected function addShortcuts(map:Object):void
		{
			for (var token:String in map)
			{
				shortcutTokens[token] = map[token];
			}
		}

		public function handle(token:String, screenContext:IScreenContext, chatMessage:ChatFieldMessage):Boolean
		{

			return false;
		}

		public function canHandle(token:String):Boolean
		{
			return (shortcutTokens[token]) ? true : false;

		}


		protected var shortcutTokens:Object = {

			}

		public function getShortcuts():Object
		{
			return shortcutTokens;
		}
	}
}