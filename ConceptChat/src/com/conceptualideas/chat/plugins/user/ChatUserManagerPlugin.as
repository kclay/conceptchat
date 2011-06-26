package com.conceptualideas.chat.plugins.user
{
	import com.conceptualideas.chat.core.ChatClientFactory;
	import com.conceptualideas.chat.events.ChatClientManagerEvent;
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;

	import flash.utils.Dictionary;

	public class ChatUserManagerPlugin extends AbstractChatPlugin implements IUserManagerPlugin
	{


		private var clientToRoomUsersMapping:Dictionary = new Dictionary(true);

		public function ChatUserManagerPlugin()
		{
			super();
		}



		override protected function init():void
		{
			trace("ChatUserManagerPlugin::init");


		}

		override protected function onScreenAdded(screen:IScreenContext):void
		{

			screen.chatClient.addEventListener(
				ChatClientManagerEvent.USERLIST_UPDATED,
				chatClient_userUpdatedHandler, false, 100);


			clientToRoomUsersMapping[screen.chatClient] = new RoomRoster(screen.name);

			super.onScreenAdded(screen);
		}

		override protected function onScreenRemoved(screen:IScreenContext):void
		{
			screen.chatClient.removeEventListener(
				ChatClientManagerEvent.USERLIST_UPDATED,
				chatClient_userUpdatedHandler);
			var room:RoomRoster = clientToRoomUsersMapping[screen.chatClient];
			if (room)
			{
				room.dispose();
				delete clientToRoomUsersMapping[screen.chatClient];
			}
			super.onScreenRemoved(screen);
		}


		private function chatClient_userUpdatedHandler(e:ChatClientManagerEvent):void
		{
			var room:RoomRoster = clientToRoomUsersMapping[e.target];
			if (room)
			{
				room.update(e.data.users);
			}
			//update(e.data.users, e.data.parted);
		}

		public function getRoomByClient(chatClient:IChatClient):IRoomRoster
		{



			for (var client:* in clientToRoomUsersMapping)
			{
				if (client == chatClient)
					return clientToRoomUsersMapping[client];
			}
			return null
		}

		public function getRoomByName(name:String):IRoomRoster
		{
			for each (var roster:IRoomRoster in clientToRoomUsersMapping)
			{
				if (roster.name == name)
					return roster;
			}

			return null;
		}



		/**
		 * Returns a ChatUser instnace by clientID
		 * @param clientID - ClientID as known from wowza
		 * @return ChatUser
		 * */
		public function getByClientID(clientID:String):ChatUser
		{
			clientID = trim(clientID);
			var user:ChatUser
			var room:RoomRoster
			for each (room in clientToRoomUsersMapping)
			{
				user = room.getByClientID(clientID)
				if (user)
					return user;
			}
			return user;

		}

		private function trim(str:String):String
		{
			return str.replace(/^\s+|\s+$/gs, '');
		}

		public function getByName(userName:String):ChatUser
		{
			userName = trim(userName);
			var user:ChatUser
			var room:RoomRoster
			for each (room in clientToRoomUsersMapping)
			{
				user = room.getByName(userName)
				if (user)
					return user;
			}
			return user;


		}

		public function hasUser(userName:String):Boolean
		{
			var has:Boolean = false;
			var room:RoomRoster
			for each (room in clientToRoomUsersMapping)
			{
				if (room.hasUser(userName))
					return true;

			}
			return false;
		}

	}
}
