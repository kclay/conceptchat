package com.conceptualideas.chat.plugins.video
{
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.interfaces.IDock;
	import com.conceptualideas.chat.interfaces.IDockable;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;
	import com.conceptualideas.chat.plugins.user.IUserManagerPlugin;
	import com.conceptualideas.chat.plugins.video.core.VideoController;
	import com.conceptualideas.chat.plugins.video.events.VideoControllerEvent;
	import com.conceptualideas.chat.plugins.video.views.VideoDock;

	import flash.events.Event;
	import flash.utils.Dictionary;

	public class VideoChatPlugin extends AbstractChatPlugin
	{




		private var controllers:Vector.<VideoController> = new Vector.<VideoController>();


		public static const DOCK_ITEM_NAME:String = "plugin.VideoChatPluginDock";

		public function VideoChatPlugin()
		{
			super();
		}


		private var _videoBlockDimensions:Array = [162, 120];



		private var _maxVideoCount:Number = -1;

		public function set maxVideoCount(value:Object):void
		{
			_maxVideoCount = Number(value) || -1;
		}

		public function set videoBlockDimensions(size:String):void
		{
			_videoBlockDimensions = size.split("x")

		}

		override protected function onContextInit():void
		{
			chatContext.addEventListener("nameChanged", chatContext_nameChangedHandler);
		}

		private function chatContext_nameChangedHandler(e:Event):void
		{
			var newName:String = chatContext.userName;
			for each (var ctr:VideoController in controllers)
			{
				ctr.username = newName;
			}
		}

		override protected function onScreenAdded(screen:IScreenContext):void
		{


			if (!(screen.chatScreen is IDockable))
				return;
			var dock:IDock = IDockable(screen.chatScreen).getDock();
			if (!dock)
				return;

			var plug:IUserManagerPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin;
			if (!plug)
				return;
			var videoDock:VideoDock = new VideoDock();
			var ctr:VideoController = new VideoController(chatContext.userName,
				plug.getRoomByClient(screen.chatClient),
				screen.chatClient, videoDock,
				Number(_videoBlockDimensions[0]), Number(_videoBlockDimensions[1]));
			ctr.addEventListener(VideoControllerEvent.USER_CLOSED_BLOCK, controller_closedBlockHandler);
			ctr.maxVideoCount = _maxVideoCount;
			videoDock.controller = ctr;
			controllers.push(ctr);
			dock.add(DOCK_ITEM_NAME, videoDock);
		}

		private function controller_closedBlockHandler(e:VideoControllerEvent):void
		{

		}

		override protected function onScreenRemoved(screen:IScreenContext):void
		{
			if (!(screen.chatScreen is IDockable))
				return;
			var dock:IDock = IDockable(screen.chatScreen).getDock();
			if (!dock)
				return;
			var videoDock:VideoDock = dock.remove(DOCK_ITEM_NAME) as VideoDock;
			var ctr:VideoController = videoDock.controller as VideoController;
			videoDock.controller = null;
			ctr.removeEventListener(VideoControllerEvent.USER_CLOSED_BLOCK, controller_closedBlockHandler);
			ctr.dispose();
			videoDock.dispose();

			controllers.splice(controllers.indexOf(ctr), 1);
		}




	}
}