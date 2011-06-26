package com.conceptualideas.chat.plugins.settings
{
	import com.conceptualideas.chat.events.ChatApplicationEvent;
	import com.conceptualideas.chat.interfaces.IDock;
	import com.conceptualideas.chat.interfaces.IDockable;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;
	import com.conceptualideas.chat.plugins.settings.view.ChatSettingsComponent;

	public class ChatSettingsPlugin extends AbstractChatPlugin implements IChatSettingsPlugin
	{

		private var view:ChatSettingsComponent

		public function ChatSettingsPlugin()
		{
			super();
		}


		public function getDock(location:String="default"):IDock
		{
			return view.dock;
		}

		override protected function init():void
		{
			chatContext.chatApplication.addEventListener(ChatApplicationEvent.OPEN_SETTINGS,
				chatApplication_openSettingsHandler);
			view = new ChatSettingsComponent();
		}

		private function chatApplication_openSettingsHandler(e:ChatApplicationEvent):void
		{

		}
	}
}