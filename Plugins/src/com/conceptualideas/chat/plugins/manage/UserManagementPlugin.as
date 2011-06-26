package com.conceptualideas.chat.plugins.manage
{
	import com.conceptualideas.chat.events.ChatScreenContextEvent;
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.interfaces.IDock;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.models.PrivateMessageRequest;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;
	import com.conceptualideas.chat.plugins.manage.events.APIEvent;
	import com.conceptualideas.chat.plugins.manage.models.Ignore;
	import com.conceptualideas.chat.plugins.manage.models.IgnoreRequest;
	import com.conceptualideas.chat.plugins.settings.IChatSettingsPlugin;
	import com.conceptualideas.chat.plugins.user.IProfileInfoPlugin;
	import com.conceptualideas.chat.plugins.user.IUserManagerPlugin;
	import com.conceptualideas.chat.utils.Helpers;

	import flash.events.Event;
	import flash.events.IEventDispatcher;

	import mx.controls.Alert;
	import mx.events.CloseEvent;

	import spark.components.Label;



	public class UserManagementPlugin extends AbstractChatPlugin implements IUserManagementPlugin
	{

		private static const DOCK_NAMESPACE:String = "usermangementplugin::";

		private var chatClient:IChatClient

		public var ignoreUserMessage:String = "Are you sure you want to ingore all interaction with [user]? This will mean no messages,private messageing from [user] untill ignore is lifted";


		private var ignoreList:Array = [];


		public var apiEndpoint:String = "http://localhost/chat/manage/api";

		private var api:AbstractAPI

		protected var canManage:Boolean = false;



		public function UserManagementPlugin()
		{
			super();



		}


		override protected function init():void
		{
			canManage = !chatContext.isGuest();
		}

		override protected function onContextInit():void
		{
			if (canManage)
				trySetup();
		}


		override protected function onScreenAdded(screen:IScreenContext):void
		{
			super.onScreenAdded(screen);
			if (!canManage)
				return;
			if (!api)
			{
				initAPI(screen.chatClient.connection);

			}

			screen.addEventListener(ChatScreenContextEvent.MESSAGE_RECIEVED, screenContext_messageRecievedHandler);
		}

		private function initAPI(endpoint:Object):void
		{
			api = new LocalAPI();
			//api.removeAllIgnores(chatContext.userName);
			api.setEndpoint(endpoint);

			api.addEventListener(APIEvent.IGNORE_LIST_LOADED, api_ignoreHandler);
			api.addEventListener(APIEvent.IGNORE_LIST_FAILED, api_ignoreHandler);
			api.fetchIgnoreList(chatContext.userName);
		}


		private function api_ignoreHandler(e:APIEvent):void
		{
			switch (e.type)
			{
				case APIEvent.IGNORE_LIST_LOADED:
					ignoreList = e.data as Array
					break;
			}
		}

		override protected function onScreenRemoved(screen:IScreenContext):void
		{
			super.onScreenRemoved(screen);
			if (canManage)
				screen.removeEventListener(ChatScreenContextEvent.MESSAGE_RECIEVED, screenContext_messageRecievedHandler);

		}

		protected function screenContext_messageRecievedHandler(e:ChatScreenContextEvent):void
		{
			var user:Object /** instance of chat user*/ = e.chatMessage.user;
			if (!user)
				return;
			if (user.name == chatContext.userName)
				return; // just incase the mask is the same

			if (isIgnore(user))
				e.preventDefault();

		}

		private function isIgnore(criteria:Object):Boolean
		{
			// Right now we only check for ip ignores
			var ignore:Ignore;
			for each (ignore in ignoreList)
			{
				if (!ignore.accepts(criteria))
					continue;
				return true;
				break;
			}
			return false;
		}

		private var setupProfilePlugin:Boolean = false;

		private var setupSettingsPlugin:Boolean = false;

		private function trySetup():void
		{
			var dock:IDock
			if (chatContext.hasPlugin(IProfileInfoPlugin) && !setupProfilePlugin)
			{
				setupProfilePlugin = true
				var pplug:IProfileInfoPlugin =  chatContext.getPlugin(IProfileInfoPlugin)
					as IProfileInfoPlugin;


				dock = pplug.getDock();
				if (!dock)
					return;
				setupProfileDock(dock);


			}
			/*if (chatContext.hasPlugin(IChatSettingsPlugin) && !setupSettingsPlugin)
			   {
			   setupSettingsPlugin = true;

			   var splug:IChatSettingsPlugin = chatContext.getPlugin(IChatSettingsPlugin) as IChatSettingsPlugin;

			   dock = splug.getDock();
			   if (!dock)
			   return;
			   setupSettingsDock(dock);

			 }*/
			if (setupProfilePlugin)
			{
				/*chatContext.removeEventListener(PluginManagerEvent.PLUGIN_LOADED,
				 chatContext_pluginLoadedHandler);*/
				var dispatcher:IEventDispatcher  = chatContext.getScreenAt(0).chatClient.globalDispatcher;

				dispatcher.addEventListener("directMessageRequest", proxy_directMessageRequestHandler, false, int.MAX_VALUE, false);
			}


		}


		private function proxy_directMessageRequestHandler(e:Event):void
		{
			var request:PrivateMessageRequest = PrivateMessageRequest(e["data"]);

			if (!acceptPrivateMessageRequest(request))
				e.preventDefault();

		}

		protected function acceptPrivateMessageRequest(request:PrivateMessageRequest):Boolean
		{

			var plug:IUserManagerPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin;
			var fromUser:ChatUser = plug.getByClientID(request.fromClientID);
			return isIgnore(fromUser) ? false : true;


		}


		override protected function onPluginLoaded(plugin:AbstractChatPlugin):void
		{
			if (canManage && plugin is IProfileInfoPlugin || plugin is IChatSettingsPlugin)
				trySetup();
		}



		private function setupProfileDock(dock:IDock):void
		{

			var label:Label = new Label();
			label.text = "Ignore user";
			label.buttonMode = true;
			label.useHandCursor = true;
			label.styleName = "ignoreUserLabel";
			dock.add(DOCK_NAMESPACE + "mute", label, profileDock_ignoreUserHandler);

		/*label = new Label();
		   label.buttonMode = true;
		   label.useHandCursor = true;
		   label.text = "Flag user";
		   label.styleName = "flagUserLabel";
		 dock.add(DOCK_NAMESPACE + "flag", label, dock_flagUserHandler);*/

		}

		private function setupSettingsDock(dock:IDock):void
		{
			var label:Label = new Label();
			label.text = "Manage Ignore List";
			label.buttonMode = true;
			label.useHandCursor = true;
			label.styleName = "manageIgnoreList";
			dock.add(DOCK_NAMESPACE + "manage", label, settingsDock_manageIgnoresHandler);
		}


		private var pendingUserName:String

		private function profileDock_ignoreUserHandler(name:String):void
		{
			pendingUserName = name;
			Alert.show(ignoreUserMessage.replace(/\[user\]/g, name),
				"Ignore " + name, Alert.YES | Alert.NO, null, confirmIgnoreHandler);
		}

		private function confirmIgnoreHandler(e:CloseEvent):void
		{
			if (e.detail == Alert.YES)
			{

				var chatUser:ChatUser = Helpers.getUserByName(chatContext, pendingUserName)
				if (chatUser)
				{

					addIgnore(chatUser);
						// we 

						//chatClient.call("addBan", null, request);

				}

			}

			pendingUserName = null;
		}

		public function removeIgnore(criteria:Object):Boolean
		{
			var ignore:Ignore;
			for each (ignore in ignoreList)
			{
				if (ignore.accepts(criteria))
				{
					api.removeIgnore(ignore);
					return true;
				}
			}
			return false;
		}

		public function addIgnore(user:ChatUser, timelimit:int=-1):Boolean
		{
			if (!api)
				return false;
			var request:IgnoreRequest = new IgnoreRequest();
			request.action.user = user;
			request.reporter = Helpers.getUserByName(chatContext, chatContext.userName);
			api.addIgnore(request); // send ban to api which will send an request to wowza 
			return true;

		}



		private function settingsDock_manageIgnoresHandler():void
		{
			//var view:ManageView = new ManageView();
			//	view.show();
		}

		private function dock_flagUserHandler(name:String):void
		{

		}

	}
}