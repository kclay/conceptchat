package com.conceptualideas.chat.plugins.user
{
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.utils.Convert;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;



	public class RoomRoster extends EventDispatcher implements IRoomRoster
	{
		private var mappingByName:Object = {};
		private var mappingByClientID:Object = {};

		private var userCount:int

		private var _name:String

		public function RoomRoster(name:String)
		{
			_name = name;
		}

		public function get name():String
		{
			return _name;
		}

		protected function clear():void
		{
			mappingByName = {};
			mappingByClientID = {};
		}

		public function dispose():void
		{
			mappingByName = null;
			mappingByClientID = null;
		}

		public function hasUser(name:String):Boolean
		{
			return mappingByName[name] || mappingByName[name.toLowerCase()] ? true : false;
		}

		public function hash():String
		{
			return null;
		}

		public function getUserNames():Vector.<String>
		{
			var names:Vector.<String> = new Vector.<String>();
			for (var name:String in mappingByName)
			{
				if (!mappingByName[name])
					continue;
				names.push(name);
			}
			return names;
		}

		public function getUsers():Vector.<ChatUser>
		{
			var users:Vector.<ChatUser> = new Vector.<ChatUser>();
			var user:Object
			for each (user in mappingByName)
			{
				users.push(Convert.convertToObject(ChatUser, user));
			}
			return users;
		}

		public function get size():int
		{
			return userCount;
		}

		public function update(users:Object /** by clientID **/):void
		{
			//	var sort:Vector.<String> = new Vector.<String>();
			var newUserCount:int = 0;

			var user:Object;
			var clientID:String
			clear();

			for (clientID in users)
			{
				newUserCount++;
				user = users[clientID];
				mappingByClientID[clientID] = user;
				mappingByName[user.name] = user;

			}

			if (newUserCount != userCount)
			{
				userCount = newUserCount;

				dispatchEvent(new Event("rosterUpdated"));
			}
			else
			{
				dispatchEvent(new Event("rosterPropertiesChanged"));
			}


		}


		private function fetch(dict:Object, key:String):ChatUser
		{
			var user:ChatUser = null;

			if (dict[key])
			{
				user = Convert.convertToObject(ChatUser, dict[key]);

			}
			else if (dict[key.toLowerCase()])
			{
				user = Convert.convertToObject(ChatUser, dict[key.toLowerCase()]);
			}
			return user;
		}


		/**
		 * Returns a ChatUser instnace by clientID
		 * @param clientID - ClientID as known from wowza
		 * @return ChatUser
		 * */
		public function getByClientID(clientID:String):ChatUser
		{

			return fetch(mappingByClientID, clientID);
		}

		public function getByName(userName:String):ChatUser
		{
			return fetch(mappingByName, userName);

		}

		public function getFilterList(flags:uint):Vector.<Object>
		{
			var set:Vector.<Object> = new Vector.<Object>();
			var user:Object
			var passed:Boolean
			for each (user in mappingByName)
			{

				if ((flags & UserRosterFilters.REGISTERED_ONLY) > 0)
				{
					if (user.name.indexOf("Guest") != 0)
						set.push(user);
				}


			}
			return set;
		}

	}
}