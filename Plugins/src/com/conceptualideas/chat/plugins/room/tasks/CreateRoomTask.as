package com.conceptualideas.chat.plugins.room.tasks
{
	import com.conceptualideas.chat.tasks.BaseTask;
	import com.conceptualideas.chat.tasks.SystemMessageTask;
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.plugins.room.events.RoomEvent;

	public class CreateRoomTask extends RoomTask
	{
		
		protected var message:String
		public function CreateRoomTask(chatContext:IChatContext,
			screenContext:IScreenContext, room:String,
			message:String=null)
		{
			super(chatContext,screenContext,room);

			
			
			this.message = message;

		}

		override public function run():void
		{
			screenContext.chatClient.call("hasRoom", hasRoomHandler);

		}

		protected function hasRoomHandler(answer:Boolean):void
		{
			if (answer)
			{
				new SystemMessageTask(screenContext, message).run()

			}
			else
			{
				chatContext.dispatchEvent(new RoomEvent(
					RoomEvent.CREATE, false, true, room));
			}
			dispose();

		}

		
	}
}