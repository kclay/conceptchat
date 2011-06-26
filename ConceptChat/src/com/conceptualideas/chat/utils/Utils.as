package com.conceptualideas.chat.utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;


	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class Utils
	{

		public function Utils()
		{


		}

		private static function getUrlLoader(type:String=null):URLLoader
		{
			var loader:URLLoader = new URLLoader();
			//loader.dataFormat = type;
			return loader;
			
		}

		private static var loaderHash:Dictionary  = new Dictionary();

		public static function makeRequest(url:String, callback:*,
			params:Object=null, method:String="GET", removeNoCache:Boolean=false, ... args:Array):URLLoader
		{
			var _params:URLVariables = new URLVariables();
			var hasParams:Boolean = false;
			for (var key:String in params)
			{
				_params[key] = params[key];
				hasParams = true;
			}
			url = decodeURIComponent(url);

			if (!removeNoCache)
			{

				url += ((url.indexOf("?") == -1) ? "?" : "&") + "noCache=" + (new Date()).time + "&";


			}




			if (method != "POST" && hasParams)
			{
				url += ((url.indexOf("?") == -1) ? "?" : "&") + _params.toString();
				_params = null;

			}



			var request:URLRequest = new URLRequest(url);
			if (_params)
				request.data = _params;

			var functions:Object = {
					complete:function(e:Event):void
				{
					var _args:Array = [e].concat(args);


					if (callback is Function)
					{
						callback.apply(null, _args);
					}
					else
					{
						callback.complete.apply(null, _args);
					}
					cleanUpAfterLoader(loader);

				},
				io:(callback is Function) ? null : callback.io,
				security:(callback is Function) ? null : callback.security
				};

			var loader:URLLoader = getUrlLoader();
			loaderHash[loader] = functions;
			request.method = method;
			loader.addEventListener(Event.COMPLETE, functions.complete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOEvent, false, 0, true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);

			loader.load(request);
			return loader;
		}

		private static function cleanUpAfterLoader(loader:URLLoader):void
		{
			var functions:Object = loaderHash[loader];
			loader.removeEventListener(Event.COMPLETE, functions.complete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOEvent);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loaderHash[loader] = null;
			delete loaderHash[loader];

		}

		private static function onSecurityError(e:SecurityErrorEvent):void
		{
			if (loaderHash[e.target].security)
				loaderHash[e.target].security(e);
			cleanUpAfterLoader(e.target as URLLoader);
			
		}

		private static function onIOEvent(e:IOErrorEvent):void
		{
			if (loaderHash[e.target].io)
				loaderHash[e.target].io(e);
			cleanUpAfterLoader(e.target as URLLoader);
		}

		public static function parseColor(value:Object, classType:Class=null):Object
		{

			
			if (!isNaN(Number(value)) && classType == String)
			{
				value = "#" + Number(value).toString(16);
			}

			return value;
		}

	}

}