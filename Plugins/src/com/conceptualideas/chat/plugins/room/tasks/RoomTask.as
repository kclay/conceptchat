package com.conceptualideas.chat.plugins.room.tasks
{
	import com.conceptualideas.chat.tasks.BaseTask;
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IScreenContext;

	public class RoomTask extends BaseTask
	{
		protected var screenContext:IScreenContext
		protected var chatContext:IChatContext
		protected var room:String

		public function RoomTask(chatContext:IChatContext,
			screenContext:IScreenContext, room:String)
		{

			this.chatContext = chatContext;
			this.screenContext = screenContext;
			this.room = room
		}

		public override function dispose():void
		{
			chatContext = null
			screenContext = null;
		}
	}
}