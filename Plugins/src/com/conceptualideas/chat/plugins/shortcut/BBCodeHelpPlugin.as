package com.conceptualideas.chat.plugins.shortcut
{
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;

	public class BBCodeHelpPlugin extends AbstractShortcutPlugin
	{
		public function BBCodeHelpPlugin()
		{
			super();
		}



		override public function handle(token:String, screenContext:IScreenContext, chatMessage:ChatFieldMessage):Boolean
		{
			var tokens:Array = chatMessage.message.split(" ");
			tokens.shift() // remove /bbcode
			token = tokens[0];
			switch (token)
			{
				case "color":
					var message:String = "Usage: [color=COLOR_NAME OR COLOR_CODE]text[/color]\n" +
						"Ex:[color=red]Red Text[/color]"
					sendSystemMessage(screenContext, message)
					break;
				default:
					sendSystemMessage(screenContext, "Codes: " + codes.join(", "));

			}



			return true;
		}


		private var codes:Vector.<String> = Vector.<String>([
			"color"]);

		override protected function register():void
		{
			super.register();
			addShortcuts({
					"bbcode":{
						description:"Shows a list of bb codes",
						usage:"/bbcode [code] ex: bbcode OR bbcode color"

					}
				})
		}

	}
}