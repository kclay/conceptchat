package com.conceptualideas.chat.plugins.user
{
	import com.conceptualideas.chat.interfaces.IDisposable;

	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class RosterWatcher extends EventDispatcher implements IDisposable
	{

		private var roster:IRoomRoster


		public function get name():String
		{
			return roster.name;
		}

		public function RosterWatcher(roster:IRoomRoster)
		{
			this.roster = roster;
		}

		public function start():void
		{
			if (!roster.hasEventListener("rosterUpdated"))
			{
				roster.addEventListener("rosterUpdated", rosterUpdatedHandler);
				roster.addEventListener("rosterPropertiesChanged", rosterUpdatedHandler);
			}



		}

		public function stop():void
		{
			if (roster.hasEventListener("rosterUpdated"))
			{
				roster.removeEventListener("rosterUpdated", rosterUpdatedHandler);
				roster.removeEventListener("rosterPropertiesChanged", rosterUpdatedHandler);
			}
		}
		private var previous:Vector.<String> = new Vector.<String>();

		private var canUpdate:Boolean = false;
		private var current:Vector.<String> = new Vector.<String>();

		private var list:Array

		private var _users:Vector.<Object>

		private var nameToGenderMapping:Object = {};

		public function update(force:Boolean=false):void
		{
			var users:Vector.<Object> = roster.getFilterList(UserRosterFilters.REGISTERED_ONLY);
			//trace("Registered users online::",users.length);
			canUpdate = force;
			current.length = 0;
			if (users.length != previous.length)
				previous.length = 0;

			users.map(mapNames);

			if (previous.length == current.length) // make sure it really is different
			{
				for (var oldName:String in previous)
				{
					if (current.indexOf(oldName) != -1)
						continue;
					canUpdate = true;
					break;
				}
			}

			if (canUpdate)
			{
				previous = current.slice();

				_users = users.slice();
				dispatchEvent(new Event("rosterChanged"))

			}
		}

		private function rosterUpdatedHandler(e:Event):void
		{
			update();

		}

		public function get users():Vector.<Object>
		{
			return _users;
		}



		private function mapNames(element:Object, index:int, vec:Vector.<Object>):void
		{
			current.push(String(element.name));
			if (!previous || // first run

				previous.indexOf(element.name) == -1 || // all next runs

				!nameToGenderMapping[element.name] || // over safe check

				nameToGenderMapping[element.name] != element.gender) // compare against gender changes
			{
				// we will store name->gender mapping to be able to update the userlist when gender is changed
				nameToGenderMapping[element.name] = element.gender;
				canUpdate = true;
			}
		}


		public function dispose():void
		{
			if (roster.hasEventListener("rosterUpdated"))
				roster.removeEventListener("rosterUpdated", rosterUpdatedHandler);
			roster = null;
			current = null;
			previous = null;
			_users = null;
			nameToGenderMapping = null;

		}
	}
}