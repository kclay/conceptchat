package com.conceptualideas.chat.plugins.manage
{
	import com.conceptualideas.chat.plugins.manage.events.APIEvent;
	import com.conceptualideas.chat.plugins.manage.models.BanRequest;
	import com.conceptualideas.chat.plugins.manage.models.FlagRequest;
	import com.conceptualideas.chat.plugins.manage.models.Ignore;
	import com.conceptualideas.chat.plugins.manage.models.IgnoreRequest;
	
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	import flash.net.Responder;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class AbstractAPI extends EventDispatcher 
	{


		public function AbstractAPI()
		{

		}

		protected function call(method:String, responder:Object, ... args:Array):void
		{



		}

		public function removeAllIgnores(name:String):void
		{

		}

		public function fetchBans():void
		{

		}

		/*public function getIgnoreList(username:String):void
		   {

		   call("getIgnoresList", new Responder(ignore_loadResultHandler, ignore_loadFaultHandler), username);
		   }

		   private function ignore_loadResultHandler(e:ResultEvent):void
		   {
		   var list:Array = e.result as Array;
		   dispatchEvent(new APIEvent(APIEvent.IGNORE_LIST_LOADED,
		   false, false, list));

		 }*/


		/* INTERFACE com.conceptualideas.chat.plugins.userManagementClasses.IManagementAPI */

		public function setEndpoint(object:Object):void
		{

		}

		public function fetchIgnoreList(username:String):void
		{

		}

		public function addFlag(request:FlagRequest):void
		{

		}


		public function addIgnore(request:IgnoreRequest,timeLimit:int = -1):void
		{

		}

		public function removeIgnore(ignore:Ignore):void
		{

		}


		public function addBan(request:BanRequest):void
		{

		}

	}

}