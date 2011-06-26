package com.conceptualideas.chat.plugins.room.tasks
{
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.models.PrivateMessageRequest;
	import com.conceptualideas.chat.plugins.user.IUserManagerPlugin;
	import com.conceptualideas.text.ChatFieldManager;
	
	import plugins.privateMessageClasses.views.events.PrivateMessageRequestEvent;

	public class PrivateMessageRequestTask extends RoomTask
	{
		private var to:String
		private var message:String

		public function PrivateMessageRequestTask(chatContext:IChatContext,
			to:String, message:String)
		{
			
			super(chatContext, null, null);
			this.to = to;
			this.message = message;
		}

		override public function run():void
		{

			var plug:IUserManagerPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin;
			if (plug && chatContext.userName != to)
			{

				var self:ChatUser = plug.getByName(chatContext.userName);

				var target:ChatUser = plug.getByName(to);

				if (self && target)
				{
					var chatRequest:PrivateMessageRequest = new PrivateMessageRequest(
						self.clientID, target.clientID);
					var chatMessage:ChatFieldMessage = new ChatFieldMessage();

					chatMessage.message = message || "" // since we split we get the last part which contains the real message to be showend in the channel

					chatRequest.chatMessage = chatMessage;

					chatContext.dispatchEvent(
						new PrivateMessageRequestEvent(chatRequest)
						);

				}

			}
			dispose();

		}
	}
}