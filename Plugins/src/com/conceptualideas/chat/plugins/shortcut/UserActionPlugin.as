package com.conceptualideas.chat.plugins.shortcut
{
	import com.conceptualideas.chat.formatters.TemplateFormatter;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.plugins.user.IUserManagerPlugin;
	import com.conceptualideas.chat.tasks.SystemMessageTask;
	import com.conceptualideas.chat.utils.Utils;

	import flash.events.Event;

	public class UserActionPlugin extends AbstractShortcutPlugin
	{

		private var formatter:TemplateFormatter = new TemplateFormatter();

		private var userPlugin:IUserManagerPlugin

		public function UserActionPlugin()
		{
			super();
		}


		override protected function onContextInit():void
		{

			super.onContextInit();
			userPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin;

		}

		/* INTERFACE com.conceptualideas.chat.plugins.shortcut.IShortcutHandler */


		private var colors:Object = {
				male:null,
				female:null

			}

		private var self:ChatUser

		override public function handle(token:String, screenContext:IScreenContext, chatMessage:ChatFieldMessage):Boolean
		{
			var tokens:Array = chatMessage.message.split(" ");
			tokens.shift() // remove /a
			var action:String = tokens[0];
			var target:String = tokens.length == 2 ? tokens[1] : null;

			if (token == "me")
			{


				chatMessage.from = "#system";
				chatMessage.message = chatContext.userName + " " + tokens.join(" ");
				return false;
			}
			switch (action)
			{


				case "help":

					break;
				case "list":
					var list:Array = [];
					for (action in actions)
					{
						list.push(action);
					}
					list.sort();


					sendSystemMessage(screenContext, "Actions:\n" + list.join(", "))

					break;
				default:

					var templates:Object = actions[action];
					if (templates)
					{



						var useTargetTemplate:Boolean  = target && userPlugin.hasUser(target);
						var template:String = useTargetTemplate ? templates["target"] : templates["self"];
						if (template)
						{



							if (!self)
								self = userPlugin.getByName(chatContext.userName);

							var meColor:String = getGenderColor(self);
							var replacements:Object = {
									"me":getBBCode("color", meColor, chatContext.userName)
								}
							if (useTargetTemplate)
							{
								var targetUser:ChatUser = userPlugin.getByName(target);
								var targetColor:String = getGenderColor(targetUser);
								replacements["target"] = getBBCode("color", targetColor, targetUser.name)
							}



							formatter.updateTokens(replacements);
							chatMessage.from="#system";
							chatMessage.message = formatter.format(template);

							formatter.reset();
							return false; // this will all the message to continue on its path
						}
					}

			}




			return true;

		}

		private function getBBCode(type:String, value:String, text:String):String
		{
			if (!value)
				return text;
			return ["[", type, "=", value, "]", text, "[/", type, "]"].join("");
		}

		private function getGenderColor(user:ChatUser):String
		{
			if (!colors.male && !colors.female)
				return null;
			return user.gender = "m" ? colors.male : colors.female

		}


		override protected function register():void
		{
			super.register();
			addShortcuts({
					"a":{
						description:"Apply an action to another user",
						usage:"/a help|list|[action] [username]"
					},
					"me":{
						description:"Tell us what your thinking/doing",
						usage:"/me [text]"
					}
				});
		}


		private var actions:Object = {};


		private var actionCount:int = 0;

		public function addAction(name:String, template:String):void
		{

			if (!actions[name])

				actions[name] = {}

			var ns:String = (template.indexOf("{target}") == -1) ? "self" : "target";
			actions[name][ns] = template;

		}

		public function loadActions(url:String):void
		{
			Utils.makeRequest(url, loader_actionsLoadedHandler);

		}

		private function loader_actionsLoadedHandler(e:Event):void
		{
			var config:XML = new XML(e.target.data);
			var node:XML
			for each (node in config.actions.children())
			{
				addAction(String(node.name()), node.@template);
			}
			for each (node in config.colors.children())
			{
				colors[String(node.name())] = String(node.text());
			}


		}


	}
}