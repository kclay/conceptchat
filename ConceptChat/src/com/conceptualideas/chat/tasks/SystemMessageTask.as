package com.conceptualideas.chat.tasks
{
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;

	public class SystemMessageTask extends BaseTask
	{
		private var screenContext:IScreenContext
		private var message:String
		private var chatContext:IChatContext

		public function SystemMessageTask(screenContext:IScreenContext, message:String, chatContext:IChatContext=null)
		{
			super();
			this.screenContext = screenContext;
			this.message = message;
			this.chatContext = chatContext;
		}

		override public function run():void
		{

			var screens:Vector.<IScreenContext> = chatContext ? chatContext.chatScreens : Vector.<IScreenContext>([screenContext]);
			var chatMessage:ChatFieldMessage = new ChatFieldMessage();
			chatMessage.from = "#system";
			chatMessage.message = message;
			var screen:IScreenContext
			for each (screen in screens)
			{
				screen.addMessage(chatMessage);
			}
			super.run();

		}

		public override function dispose():void
		{
			screenContext = null;
			chatContext = null;

		}
	}
}