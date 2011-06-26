package com.conceptualideas.chat.plugins.manage
{
	import com.conceptualideas.chat.plugins.manage.events.APIEvent;
	import com.conceptualideas.chat.plugins.manage.models.BanRequest;
	import com.conceptualideas.chat.plugins.manage.models.BaseRequest;
	import com.conceptualideas.chat.plugins.manage.models.FlagRequest;
	import com.conceptualideas.chat.plugins.manage.models.Flags;
	import com.conceptualideas.chat.plugins.manage.models.Ignore;
	import com.conceptualideas.chat.plugins.manage.models.IgnoreRequest;
	import com.conceptualideas.chat.utils.Convert;

	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.net.Responder;

	import vegas.errors.IllegalArgumentError;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class WowzaAPI extends AbstractAPI
	{

		private var netConnection:NetConnection

		public function WowzaAPI()
		{

		}

		override public function setEndpoint(object:Object):void
		{
			if (!(object is NetConnection))
				throw new IllegalArgumentError("Endpoing needs to be of NetConnection");
			netConnection = object as NetConnection
		}

		override protected function call(method:String, responder:Object, ... args:Array):void
		{
			netConnection.call.apply(netConnection, [method, responder].concat(args));
		}



		private var _bans:Array;

		override public function fetchBans():void
		{
			if (_bans)
			{
				bans_fetchResultHandler(_bans)
			}
			else
			{
				call("fetchBans", new Responder(bans_fetchResultHandler, bans_fetchFaultHandler));
			}
		}

		private function bans_fetchResultHandler(bans:Array):void
		{
			_bans = bans;
			dispatchEvent(new APIEvent(APIEvent.BAN_LIST_LOADED, false, false, bans));
		}

		private function bans_fetchFaultHandler(info:Object):void
		{

		}

		override public function addBan(request:BanRequest):void
		{
			call("invokeManagementRequest", null, request);
		}

		override public function addFlag(request:FlagRequest):void
		{
			call("invokeManagementRequest", null, request);
		}

		override public function addIgnore(request:IgnoreRequest, timeLimit:int=-1):void
		{
			call("invokeManagementRequest", null, request);
		}

		override public function fetchIgnoreList(username:String):void
		{
			call("fetchIgnoreList", new Responder(ignore_fetchResultHandler, ignore_fetchFaultHandler), username);
		}

		private function ignore_fetchResultHandler(ignores:Array):void
		{
			for (var i:String in ignores)
				ignores[i] = Convert.convertToObject(Ignore, ignores[i]);

			dispatchEvent(new APIEvent(APIEvent.IGNORE_LIST_LOADED,
				false, false, ignores));
		}

		private function ignore_fetchFaultHandler(info:Object):void
		{

		}

	}

}