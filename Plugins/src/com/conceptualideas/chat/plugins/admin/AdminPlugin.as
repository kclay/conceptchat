package com.conceptualideas.chat.plugins.admin
{
	import com.conceptualideas.chat.interfaces.IDock;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.plugins.admin.events.BanWindowEvent;
	import com.conceptualideas.chat.plugins.admin.views.BanWindow;
	import com.conceptualideas.chat.plugins.manage.AbstractAPI;
	import com.conceptualideas.chat.plugins.manage.models.BanAction;
	import com.conceptualideas.chat.plugins.manage.models.BanRequest;
	import com.conceptualideas.chat.plugins.manage.WowzaAPI;
	import com.conceptualideas.chat.plugins.shortcut.AbstractShortcutPlugin;
	import com.conceptualideas.chat.plugins.user.IProfileInfoPlugin;
	import com.conceptualideas.chat.plugins.user.IUserManagerPlugin;
	import flash.display.DisplayObject;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import spark.components.Button;




	public class AdminPlugin extends AbstractShortcutPlugin
	{

		private static const KEY:String = "admin:";

		private var api:AbstractAPI

		private var usersPlugin:IUserManagerPlugin

		private var self:ChatUser

		public function AdminPlugin()
		{
			super();
		}

		override public function handle(token:String, screenContext:IScreenContext, chatMessage:ChatFieldMessage):Boolean
		{

			var tokens:Array = chatMessage.message.split(" ");
			tokens.shift(); // remove main token
			var action:String  = tokens.length ? tokens[0] : null;
			if (token == "ip")
			{


				var user:ChatUser = usersPlugin.getByName(action);
				if (user)
				{

					sendSystemMessage(screenContext, user.name + " : http://www.geoiptool.com/en/?IP=" + user.ip);
				}
				return true;
			}
			switch (action)
			{
				case "manage":
					api.fetchBans();

					break;
				case "unban":
				removeBan(tokens.shift(), onBanRemoved);
				break;


				default:
					displayBanWindow(action);
					break;


			}
			return true;
		}

		override protected function onContextInit():void
		{


			if (!chatContext.hasPlugin(IUserManagerPlugin))
				return;
			super.onContextInit()
			usersPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin;
			if (!chatContext.hasPlugin(IProfileInfoPlugin))
				return;

			var profile:IProfileInfoPlugin = chatContext.getPlugin(IProfileInfoPlugin) as IProfileInfoPlugin;
			var dock:IDock = profile.getDock();
			if (dock)
				setupProfileDock(dock);


		}


		private function setupProfileDock(dock:IDock):void
		{
			var button:Button = new Button();
			button.styleName = "banUserButton"
			button.label = "Ban user";
			dock.add(KEY + "ban", button, banButton_clickHandler);
			
			button = new Button();
			button.label = "Show Ip";
			dock.add(KEY + "ip", button, ipButton_clickHandler);
		}

		private var userToBan:ChatUser

		private function banButton_clickHandler(name:String):void
		{
			displayBanWindow(name);
		}
		 private function ipButton_clickHandler(name:String):void{
            var user:ChatUser = Helpers.getUserByName(chatContext, name);
            if (user){
                navigateToURL(new URLRequest(("http://www.geoiptool.com/en/?IP=" + user.ip)), "_blank");
            };
        }
		private function removeBan(mask:String, callback:Function):void{
            var action:BanAction = new BanAction();
            action.mask = mask;
            api.removeBan(action, callback);
        }

		private function displayBanWindow(name:String):void
		{
			if (!self)
				self = usersPlugin.getByName(chatContext.userName);
			if (chatContext.userName == name)
			 return;
			userToBan = usersPlugin.getByName(name);
			if (userToBan.ip == self.ip) // can't ban your self
			 return;
			if (userToBan)
			{

				var window:BanWindow = new BanWindow();
				window.username = name;
				window.netmask = userToBan.ip;
				window.addEventListener(BanWindowEvent.ADD_BAN, window_eventHandler);
				window.addEventListener(BanWindowEvent.CANCEL, window_eventHandler)

				PopUpManager.addPopUp(window,
					DisplayObject(FlexGlobals.topLevelApplication), true);
				PopUpManager.centerPopUp(window);
			}
			else
			{
				Alert.show("Sorry, but user must be in room to be able to ban them", "User not in room");
			}

		}

		private function window_eventHandler(e:BanWindowEvent):void
		{
			var window:BanWindow = BanWindow(e.target);
			window.removeEventListener(BanWindowEvent.ADD_BAN, window_eventHandler);
			window.removeEventListener(BanWindowEvent.CANCEL, window_eventHandler);
			if (e.type == BanWindowEvent.ADD_BAN)
			{

				var temporaryBan:Boolean = e.banType == BanTimeSpan.TEMPORARY
				addBan(userToBan, temporaryBan, e.timelimit * 60, window.netmask);
				var confirmation:String = confirmation = userToBan.name + " has been banned";
				if (temporaryBan)
				{
					confirmation += " for " + e.timelimit + " minutes";
				}
				else
				{
					confirmation += " permanently";
				}

				Alert.show(confirmation, "User Banned");
				userToBan = null;


			}
			PopUpManager.removePopUp(window);
		}

		private function addBan(user:ChatUser, temporaryBan:Boolean=false, limit:int=0, netmask:String=null):void
		{
			var request:BanRequest = new BanRequest();

			var action:BanAction = BanAction(request.action);
			action.temporaryBan = temporaryBan;
			action.user = user;
			action.mask = netmask;
			action.timeLimit = limit;
			request.reporter = self;
			api.addBan(request);
		}



		override protected function onScreenAdded(screen:IScreenContext):void
		{
			if (!api)
			{
				api = new WowzaAPI();
				api.setEndpoint(screen.chatClient.connection);
					//api.addEventListener(

			}



		}

		override protected function register():void
		{
			super.register();
			addShortcuts({
					"ban":{
						description:"Manage or add an user ban",
						usage:"/ban [manage]|[username]"
					},
					"ip":{
						description:"Shows IP of user",
						usage:"/ip [username]"
					}
				});
		}
	}
}