package com.conceptualideas.chat.plugins.room.tasks
{
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.models.NotificationMessage;
	import com.conceptualideas.chat.plugins.user.IUserManagerPlugin;

	public class InviteUserTask extends RoomTask
	{

		private var from:String
		private var to:String

		public function InviteUserTask(chatContext:IChatContext, screenContext:IScreenContext,
			room:String, from:String, to:String)
		{

			super(chatContext, screenContext, room);
			this.from = from;
			this.to = to;
		}

		override public function run():void
		{
			var plug:IUserManagerPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin;
			if (to && plug)
			{

				var user:ChatUser = plug.getByName(to);
				if (user)
				{

					var note:NotificationMessage = new NotificationMessage();
					note.flag = "room::invite";
					note.data = {
							room:room.replace("#", ""),
							from:from,
							user:to
						};
					note.toClientID = user.clientID;
					screenContext.chatClient.sendNotification(note);
				}
			}

			dispose();

		}
	}
}