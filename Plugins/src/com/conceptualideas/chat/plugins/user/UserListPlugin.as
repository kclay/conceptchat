package com.conceptualideas.chat.plugins.user
{
	import andromeda.ioc.io.ObjectResourceBuilder;

	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;
	import com.conceptualideas.chat.plugins.tab.ITabManagerPlugin;
	import com.conceptualideas.chat.plugins.tab.events.TabEvent;
	import com.conceptualideas.chat.plugins.user.events.UserListEvent;
	import com.conceptualideas.chat.utils.Utils;
	import com.conceptualideas.text.IAutoCompleteInput;

	import flash.events.Event;
	import flash.utils.Dictionary;

	public class UserListPlugin extends AbstractChatPlugin
	{

		private var roster:IRoomRoster

		private var delegator:IUserDelegator

		public function UserListPlugin()
		{
			super();
		}

		private var _maleColor:uint = 0x7BA4C4;

		public function set maleColor(value:Object):void
		{
			_maleColor = Utils.parseColor(value, uint) as uint;
		}
		private var _femaleColor:uint = 0xFE0180;

		public function set femaleColor(value:Object):void
		{
			_femaleColor = Utils.parseColor(value, uint) as uint;
		}


		private var pendingTab:String

		override protected function init():void
		{

			if (chatContext.chatApplication is IUserListProvider)
			{

				delegator = IUserListProvider(chatContext.chatApplication).userlistDelegator;
				if (delegator)
				{
					variableHash["watchRoster"] = true;
					var tabManager:ITabManagerPlugin = chatContext.getPlugin(ITabManagerPlugin) as ITabManagerPlugin;
					if (tabManager)
					{
						tabManager.addEventListener(TabEvent.TAB_CHANGED, tabManager_tabChangedHandler);
						pendingTab = tabManager.getActiveTabName();;

					}
					delegator.addEventListener(UserListEvent.NAME_CLICKED, delegator_nameClickHandler);

				}
				else
				{
					roster = null;
				}
			}

		}

		private var previousTab:String

		private function tabManager_tabChangedHandler(e:TabEvent):void
		{
			switchWatcher(e.name);

		}

		private function switchWatcher(name:String):void
		{
			if (watchers[name])
			{

				if (name != previousTab)
				{

					var watcher:RosterWatcher = watchers[previousTab];
					if (watcher)
						watcher.stop();

				}
				watcher = watchers[name];
				watcher.start();
				watcher.update(true);
				previousTab = name;
			}
		}


		/*private function roster_updateHandler(e:Event):void
		   {



		   var users:Vector.<Object> = roster.getFilterList(UserRosterFilters.REGISTERED_ONLY);
		   var names:Vector.<String> = new Vector.<String>();

		   var update:Boolean = false;
		   var name:String


		   users.map(function(element:Object, index:int, vec:Vector.<Object>):void{
		   name = String(element.name)
		   names.push(name);
		   if (!previous || (previous && previous.indexOf(name) == -1)){

		   update = true;
		   }
		   })

		   if (update)
		   {
		   previous = names;
		   var list:Array = [];
		   users.map(function(element:Object, index:int, vec:Vector.<Object>):void{

		   if (!element)return;
		   list.push({label:element.name, name:element.name,
		   color:element.gender != undefined ?
		   element.gender == "m" ? _maleColor : _femaleColor : _maleColor})
		   });
		   delegator.list = list;
		   }
		   }
		 */
		private var variableHash:Object = {};
		private var infoPlugin:IProfileInfoPlugin

		private var watchers:Dictionary = new Dictionary();

		private var roomToScreenMapping:Object = {};

		override protected function onScreenAdded(screen:IScreenContext):void
		{
			if (variableHash["watchRoster"])
			{
				var room:String = screen.name;
				var roster:IRoomRoster = IUserManagerPlugin(chatContext.getPlugin(IUserManagerPlugin)).getRoomByName(room);
				var watcher:RosterWatcher = new RosterWatcher(roster);
				watcher.addEventListener("rosterChanged", watcher_rosterChangedHandler);
				watchers[room] = watcher;

				if (pendingTab)
				{
					switchWatcher(pendingTab);
					pendingTab = null;
				}

			}
		}

		override protected function onScreenRemoved(screen:IScreenContext):void
		{
			if (variableHash["watchRoster"])
			{
				var room:String = screen.name;
				var watcher:RosterWatcher = watchers[room];
				watcher.removeEventListener("rosterChanged", watcher_rosterChangedHandler);
				watcher.dispose()
				delete watchers[room];
			}


		}

		private function watcher_rosterChangedHandler(e:Event):void
		{
			var list:Array = [];
			var watcher:RosterWatcher = RosterWatcher(e.target)
			var words:Vector.<String> = new Vector.<String>();
			watcher.users.map(function(element:Object, index:int, vec:Vector.<Object>):void{
					words.push(element.name);
					list.push(getListInfo(element))
				});
			delegator.list = list;
			var screen:IScreenContext = chatContext.getScreenByName(watcher.name);
			if (screen && screen.chatScreen is IAutoCompleteInput)
			{
				var input:IAutoCompleteInput = IAutoCompleteInput(screen.chatScreen);

				input.dictionary.clear();
				input.dictionary.addAll(words);

			}

		}

		private function getListInfo(element:Object):Object
		{
			var isMale:Boolean = element.gender == undefined || element.gender == "m";
			return {
					label:element.name,
					name:element.name,
					color:isMale ? _maleColor : _femaleColor
				}
		}

		private function delegator_nameClickHandler(e:UserListEvent):void
		{
			if (!infoPlugin && !variableHash["infoPluginChecked"])
			{
				variableHash["infoPluginChecked"] = true;
				infoPlugin = chatContext.getPlugin(IProfileInfoPlugin) as IProfileInfoPlugin;
			}
			if (!infoPlugin)
				return;

			infoPlugin.show(e.name, e.x, e.y);
		}



	}
}