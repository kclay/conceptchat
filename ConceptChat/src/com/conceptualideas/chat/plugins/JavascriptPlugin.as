package com.conceptualideas.chat.plugins
{
	import com.conceptualideas.chat.interfaces.IChatScreen;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	
	import flash.external.ExternalInterface;
	import flash.system.Security;

	public class JavascriptPlugin extends AbstractChatPlugin
	{
		private var _handlerName:String

		public function JavascriptPlugin()
		{

		}

		override protected function onContextInit():void
		{
			if (ExternalInterface.available)
			{
				exposeCalls();
			}
		}

		override protected function init():void
		{

		}

		public function set handlerName(value:String):void
		{
			_handlerName = value;
		}

		private function exposeCalls():void
		{
			Security.allowDomain("*");
			ExternalInterface.addCallback("dispatchMessage", dispatchMessageHandler);

		}

		public function dispatch(event:String, info:Object=null):void
		{
			if (_handlerName)
			{

				ExternalInterface.call(_handlerName, {
						type:event,
						data:info
					});
			}
		}



		private function dispatchMessageHandler(message:String):void
		{

			chatContext.getScreenAt(0).chatScreen.dispatchMessage(message);

		}

	}
}