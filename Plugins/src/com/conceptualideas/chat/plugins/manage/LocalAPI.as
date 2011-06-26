package com.conceptualideas.chat.plugins.manage
{
	import com.conceptualideas.chat.plugins.manage.events.APIEvent;
	import com.conceptualideas.chat.plugins.manage.models.Ignore;
	import com.conceptualideas.chat.plugins.manage.models.IgnoreRequest;
	import com.conceptualideas.chat.utils.Convert;

	import flash.net.SharedObject;

	public class LocalAPI extends AbstractAPI
	{
		private var sharedObject:SharedObject

		public static const SO_NAME:String = "chat.userManagement";

		public function LocalAPI()
		{
			super();
			sharedObject = SharedObject.getLocal(SO_NAME);
		}

		override public function removeAllIgnores(username:String):void
		{
			updateSO({ignore:[]})
		}

		override public function removeIgnore(ignore:Ignore):void
		{
			var list:Array = sharedObject.data["ignore"] || [];
			var index:int = list.indexOf(ignore);
			if (index != -1)
			{
				list.splice(index, 1);
				updateSO({ignore:list});
				fetchIgnoreList(null);
			}
		}

		override public function addIgnore(request:IgnoreRequest, timeLimit:int=-1):void
		{


			// TODO : expose hostmask
			var list:Array = sharedObject.data["ignore"] || [];
			var ignore:Ignore = new Ignore();
			ignore.timeLimit = timeLimit;
			ignore.dateAdded = new Date();
			ignore.ip = request.action.user.ip;
			ignore.username = request.action.user.name;
			list.push(ignore);
			updateSO({ignore:list})
			fetchIgnoreList(null);


		}

		private function updateSO(data:Object):void
		{

			for (var key:String in data)
			{
				sharedObject.setProperty(key, data[key]);
					//	localCacheSharedObject.setProperty(key + "TimeStamp", new Date().time);
			}
			sharedObject.flush();
		}

		override public function fetchIgnoreList(username:String):void
		{
			var ignores:Array = sharedObject.data["ignore"] || [];
			var cleaned:Array = [];
			var len:int = ignores.length;
			var ignore:Ignore
			for (var i:int = 0; i < len; i++)
			{
				ignore = ignores[i];
				if (ignore.expired())
					continue;
				cleaned.push(ignore);
			}
			/*if (ignores.length != cleaned.length)
			{ // removed so update
				updateSO({list:cleaned});
			}*/

			/*for (var i:String in ignores)
			 ignores[i] = Convert.convertToObject(Ignore, ignores[i]);*/


			dispatchEvent(new APIEvent(APIEvent.IGNORE_LIST_LOADED,
				false, false, cleaned));

		}
	}
}