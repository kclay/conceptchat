package com.conceptualideas.chat.plugins.room.tasks
{
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.models.NotificationMessage;
	import com.conceptualideas.chat.plugins.user.IUserManagerPlugin;
	import com.conceptualideas.chat.plugins.room.RoomFlags;

	public class BootUserTask extends RoomTask
	{
		private var target:String
		private var reason:String

		public function BootUserTask(chatContext:IChatContext, screenContext:IScreenContext,
			target:String, reason:String)
		{
			
			super(chatContext, screenContext, room);
			this.target = target;
			this.reason = reason;
		}

		override public function run():void
		{
			var plug:IUserManagerPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin
			if (plug)
			{

				var user:ChatUser = plug.getByName(target);
				// TODO : add message that user wasn't on line
				if (user)
				{


					var note:NotificationMessage = new NotificationMessage();
					note.flag = RoomFlags.NOTIFY_BOOT_FLAG;
					note.fromChatRoom = room;
					note.toClientID = user.clientID
					note.data = {
							owner:chatContext.userName,
							reason:reason,
							room:note.fromChatRoom,
							user:user.name

						}
					screenContext.chatClient.sendNotification(note);
				}
			}
			dispose();
		}
	}
}