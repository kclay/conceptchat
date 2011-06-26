package com.conceptualideas.chat.core
{
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;


	dynamic public class NetClient extends Proxy
	{
		public function NetClient()
		{
			super();
		}

		public function addHandler(name:String, handler:Function, priority:int=0):void
		{
			var handlersForName:Array = handlers.hasOwnProperty(name) ?
				handlers[name] : (handlers[name] = []);


			if (priority)
			{

				var index:int = -1;
				var length:int = handlersForName.length;
				for (var i:int = 0; i < length; i++)
				{
					if (priority < handlersForName[i].priority)
						continue;
					index = i;
					break;
				}
				if (!index)
					handlersForName.push({handler:handler, priority:priority})
				else
					handlersForName.splice(index, 0, {handler:handler, priority:priority});
			}
			else
			{
				handlersForName.push({
						handler:handler,
						priority:priority
					});
			}


		}

		public function removeHandler(name:String, handler:Function):Boolean
		{
			var removed:Boolean;
			if (handlers.hasOwnProperty(name))
			{

				var index:int = -1;
				var handlersForName:Array = handlers[name];
				var length:int = handlersForName.length;
				for (var i:int = 0; i < length; i++)
				{
					if (handlersForName[i].handler == handler)
					{
						index = i;
						break;
					}
				}

				if (index != -1)
				{
					handlersForName.splice(index, 1);
					removed = true;
				}

			}
			return removed;
		}

		private var handlers:Dictionary = new Dictionary();

		override flash_proxy function callProperty(methodName:*, ... args):*
		{
			return invokeHandlers(methodName, args);
		}

		/**
		 * @inheritDoc
		 * @private
		 */
		override flash_proxy function getProperty(name:*):* 
		{
			var result:*;			
			if (handlers.hasOwnProperty(name))
			{
				result 
				=  function():*
				{
					return invokeHandlers(arguments.callee.name,arguments);
				}
				
				result.name = name;
			}
			
			return result;
		}
		private function invokeHandlers(methodName:String, args:Array):*
		{
			var result:Array;

			if (handlers.hasOwnProperty(methodName))
			{
				result = [];
				var handlersForName:Array = handlers[methodName];
				for each (var obj:Object in handlersForName)
				{
					result.push(obj.handler.apply(null, args));
				}
			}

			return result;
		}


	}
}