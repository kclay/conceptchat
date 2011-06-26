package com.conceptualideas.chat.plugins.room.tasks
{
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.plugins.room.events.RoomEvent;

	public class JoinRoomTask extends CreateRoomTask
	{
		public function JoinRoomTask(chatContext:IChatContext, screenContext:IScreenContext, room:String)
		{
			super(chatContext, screenContext, room);
		}

		override protected function hasRoomHandler(answer:Boolean):void
		{

			if (answer)
			{
				chatContext.dispatchEvent(new RoomEvent(
					RoomEvent.JOIN, false, true, room));
			}
			else
			{

			}
			dispose();
		}
	}
}