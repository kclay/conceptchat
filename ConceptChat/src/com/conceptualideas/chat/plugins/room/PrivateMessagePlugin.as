package com.conceptualideas.chat.plugins.room
{
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.models.PrivateMessageRequest;

	import plugins.privateMessageClasses.views.events.PrivateMessageRequestEvent;
	import com.conceptualideas.chat.plugins.user.IUserManagerPlugin;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;

	public class PrivateMessagePlugin extends AbstractChatPlugin implements IPrivateMessagePlugin
	{
		private var userPlugin:IUserManagerPlugin


		private static const DOCK_ITEM_NAME:String = "com.conceptualideas.chat.plugins.room.PrivateMessagePlugin"

		public function PrivateMessagePlugin()
		{
			super();
		}

		override protected function onContextInit():void
		{
			userPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin;
		/*var button:Button = new Button();
		   button.verticalCenter = 0;
		   button.width = 32;
		   button.height = 32;
		   button.setStyle("skinClass", PrivateMessageButtonSkin);
		   var controlBarContent:Array = FlexGlobals.topLevelApplication.controlBarContent;
		   if (!controlBarContent)
		   controlBarContent = [];
		   controlBarContent.push(button);
		 FlexGlobals.topLevelApplication.controlBarContent = controlBarContent;*/
			 //dock.add(DOCK_ITEM_NAME, button, dock_invokePrivateMessageHandler);

		}



		public function sendChatRequest(toUserName:String, message:String=null):Boolean
		{



			if (!userPlugin)
				return false;

			if (chatContext.userName == toUserName)
				return true;
			var toChatUser:ChatUser = userPlugin.getByName(toUserName);
			if (!toChatUser)
				return false;
			var fromChatUser:ChatUser = userPlugin.getByName(chatContext.userName);
			if (!fromChatUser)
				return false;
			


			var chatRequest:PrivateMessageRequest = new PrivateMessageRequest(
				fromChatUser.clientID, toChatUser.clientID);
			var chatMessage:ChatFieldMessage = new ChatFieldMessage();

			chatMessage.message = message || "" // since we split we get the last part which contains the real message to be showend in the channel

			chatRequest.chatMessage = chatMessage;

			chatContext.dispatchEvent(
				new PrivateMessageRequestEvent(chatRequest)
				);
			return true;
		}



	/*	public function close():void
	   {
	   PopUpManager.removePopUp(popup);
	   }

	   private function dock_invokePrivateMessageHandler():void
	   {
	   if (!popup)
	   {
	   popup = new PrivateMessageChatRequestView();
	   popup.delegate = this;
	   }



	   PopUpManager.addPopUp(popup,
	   DisplayObject(FlexGlobals.topLevelApplication), true, PopUpManagerChildList.APPLICATION);
	   PopUpManager.centerPopUp(popup);
	   PopUpManager.bringToFront(popup);



	 }*/
	}
}