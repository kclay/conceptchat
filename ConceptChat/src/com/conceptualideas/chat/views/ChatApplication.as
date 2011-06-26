package com.conceptualideas.chat.views
{
	import com.conceptualideas.chat.BasicChatController;
	import com.conceptualideas.chat.interfaces.IChatApplication;
	import com.conceptualideas.chat.models.ChatSettings;
	
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;

	public class ChatApplication extends Group implements IChatApplication
	{

		protected var chatController:BasicChatController;

		public function ChatApplication()
		{
			
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}



		private function addedToStageHandler(e:Event):void
		{


			var params:Object = stage.loaderInfo.parameters;
			var chatSettings:ChatSettings = new ChatSettings();
			chatSettings.vars = params;
			chatSettings.chatRoomName = params["r"];
			chatSettings.userName = params["u"] || "";
			chatSettings.settingsURL = params["c"];
			chatSettings.server = params["s"];


			var ratio:Number = chatSettings.browserHeight / chatSettings.browserWidth;
			if (chatSettings.browserHeight > stage.stageHeight - 50)
			{
				chatSettings.browserHeight = stage.stageHeight - 50;
				chatSettings.browserWidth = chatSettings.browserHeight / ratio;
			}
			if (chatSettings.browserWidth > stage.stageWidth - 50)
			{
				chatSettings.browserWidth = stage.stageWidth - 50;
				chatSettings.browserHeight -= 50;
			}
			if (params["i"])
				chatSettings.appInstance += "/" + params["i"];



			chatController = createChatController(chatSettings);
		}

		protected function createChatController(chatSettings:ChatSettings):BasicChatController
		{
			return new BasicChatController(null, chatSettings);
		}

	}
}