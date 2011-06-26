package com.conceptualideas.chat.plugins.user
{
	import com.conceptualideas.chat.interfaces.IDock;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;
	import com.conceptualideas.chat.plugins.JavascriptPlugin;
	import com.conceptualideas.chat.plugins.room.IPrivateMessagePlugin;
	import com.conceptualideas.chat.skins.IMSkin;
	import com.conceptualideas.chat.skins.ProfileInfoSkin;
	import com.conceptualideas.chat.skins.ProfileSkin;
	import com.conceptualideas.chat.views.ProfileInfo;

	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;

	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;

	import mx.controls.Alert;

	import spark.components.Button;

	public class ProfileInfoPlugin extends AbstractChatPlugin implements IProfileInfoPlugin
	{
		private var userPlugin:IUserManagerPlugin
		private var messagePlugin:IPrivateMessagePlugin
		private var firstRun:Boolean = true;
		private var info:ProfileInfo

		private var isShowing:Boolean = false;





		private var stage:Stage

		public function ProfileInfoPlugin()
		{
			super();
		}


		override protected function init():void
		{
			info = new ProfileInfo();
			info.setStyle("skinClass", ProfileInfoSkin);
			var button:Button = new Button();
			button.label = "Private MSG";
			button.setStyle("skinClass", IMSkin);
			button.mouseChildren = false;
			button.useHandCursor = true;
			button.buttonMode = true;
			info.add("im", button, buttonIM_clickHandler);

			button = new Button();
			button.label = "Profile"
			button.mouseChildren = false;
			button.useHandCursor = true;
			button.buttonMode = true;
			button.setStyle("skinClass", ProfileSkin);


			info.add("profile", button, buttonProfile_clickHandler);
			info.addEventListener("guestChanged", info_isGuestHandler);
			stage = DisplayObject(chatContext.chatApplication).stage;
		}




		public function getDock(location:String="default"):IDock
		{
			return info;
		}


		protected function setupPlugin():void
		{

			firstRun = false;

			userPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin;
			messagePlugin = chatContext.getPlugin(IPrivateMessagePlugin) as IPrivateMessagePlugin;
		}



		private function info_isGuestHandler(e:Event):void
		{
			info.retrive("profile")["enabled"] = !info.guest;
		}



		private function buttonProfile_clickHandler(userName:String):void
		{
			var plug:JavascriptPlugin = chatContext.getPlugin(JavascriptPlugin) as JavascriptPlugin;
			plug.dispatch("SHOW_USER_PROFILE", {
					name:userName
				});
		}

		private function buttonIM_clickHandler(userName:String):void
		{

			if (!messagePlugin)
				return;
			if (!messagePlugin.sendChatRequest(userName))
			{
				Alert.show("Sorry, but seems that " + userName + " is not online anymore", "Not online??");
			}

			info.close()

		}

		override protected function onScreenAdded(screen:IScreenContext):void
		{



			var textInput:IEventDispatcher = IEventDispatcher(screen.chatScreen.textInputObject);
			if (textInput is TextFlow)
			{
				textInput.addEventListener(FlowElementMouseEvent.CLICK, textFlow_rollOverClickHandler);
					//textInput.addEventListener(FlowElementMouseEvent.ROLL_OVER, textFlow_rollOverClickHandler)
			}


		}

		override protected function onScreenRemoved(screen:IScreenContext):void
		{
			var textInput:IEventDispatcher = IEventDispatcher(screen.chatScreen.textInputObject);
			if (textInput is TextFlow)
			{
				textInput.removeEventListener(FlowElementMouseEvent.CLICK, textFlow_rollOverClickHandler);
					//textInput.removeEventListener(FlowElementMouseEvent.ROLL_OVER, textFlow_rollOverClickHandler)
			}
		}


		private function textFlow_rollOverClickHandler(e:FlowElementMouseEvent):void
		{
			var link:LinkElement = e.flowElement as LinkElement;
			if (!link || link.styleName != "profileName")
				return;


			show(link.getText(), e.originalEvent.stageX, e.originalEvent.stageY);
		}




		private var _username:String

		public function show(name:String, x:Number, y:Number):void
		{
			if (firstRun)
				setupPlugin();



			info.username = name;
			info.guest = name.indexOf("Guest") == 0;
			var user:ChatUser = null;
			if (userPlugin)
				user = userPlugin.getByName(name);

			info.avatar = user && user.avatar ? user.avatar : null;
			info.show()


			var screenBounds:Rectangle = getScreenBounds();

			if (x > screenBounds.width - info.width - 10)
				x = screenBounds.width - info.width - 10
			if (y > screenBounds.height - info.height - 10)
				y = screenBounds.height - info.height - 10
			info.x = x;
			info.y = y;

		}

		private function getScreenBounds():Rectangle
		{
			return new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		}


	}
}