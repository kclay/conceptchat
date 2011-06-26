package com.conceptualideas.chat.plugins.voice
{
	import com.conceptualideas.chat.events.ChatClientManagerEvent;
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.interfaces.IDock;
	import com.conceptualideas.chat.interfaces.IDockable;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;
	import com.conceptualideas.chat.plugins.user.IUserManagerPlugin;
	import com.conceptualideas.chat.plugins.media.MediaManager;
	import com.conceptualideas.chat.plugins.user.IRoomRoster;
	import com.conceptualideas.chat.plugins.voice.core.VoiceController;
	import com.conceptualideas.chat.plugins.voice.interfaces.IVoiceModel;
	import com.conceptualideas.chat.plugins.voice.views.Dock;
	
	import flash.display.Sprite;
	import flash.net.NetConnection;
	import flash.utils.Dictionary;

	/**
	 * 
	 * @author cideas
	 * 
	 */
	public class VoiceChatPlugin extends AbstractChatPlugin
	{
		private var chatClientsToControllerMapping:Dictionary = new Dictionary(true);

		/**
		 * 
		 * 
		 */
		public function VoiceChatPlugin()
		{
			super();
		}

		/**
		 * 
		 * @param screen
		 * 
		 */
		override protected function onScreenAdded(screen:IScreenContext):void
		{
			if (chatContext.getScreenIndex(screen) == 0) // dont setup on first screen
				return;
			if (screen.chatScreen is IDockable)
				setupDock(IDockable(screen.chatScreen).dock, screen.chatClient);
		}
		override protected function onScreenRemoved(screen:IScreenContext):void{
			if(screen.chatScreen is IDockable)
				tearDownDock(IDockable(screen.chatScreen).dock);
		}

		private function tearDownDock(dock:IDock):void{
			var uiDock:Dock = dock.remove("plugin.voice") as Dock;
			VoiceController(uiDock.controller).dispose();
		}
		private function setupDock(dock:IDock, chatClient:IChatClient):void
		{

			//chatClient.addEventListener(ChatClientManagerEvent.NOTIFICATION, chatClient_notificationHandler);
			var userManager:IUserManagerPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin;
			if (!userManager)
				return;
			var roster:IRoomRoster = userManager.getRoomByClient(chatClient);
			if (!roster)
				return;
			var uiDock:Dock = new Dock();
			uiDock.controller = new VoiceController(
				chatContext.userName,
				chatClient,
				roster, Sprite(uiDock));
			//chatClientsToControllerMapping[uiDock.controller];

			dock.add("plugin.voice", uiDock, null);

		}




	}
}