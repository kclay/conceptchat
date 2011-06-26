package com.conceptualideas.chat.utils
{
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IScreenContext;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.plugins.tab.ITabManagerPlugin;
	import com.conceptualideas.chat.plugins.user.IUserManagerPlugin;

	public class Helpers
	{
		public function Helpers()
		{


		}

		public static function getUserByName(chatContext:IChatContext, name:String):ChatUser
		{
			var plug:IUserManagerPlugin = chatContext.getPlugin(IUserManagerPlugin) as IUserManagerPlugin;
			return (plug) ? plug.getByName(name) : null;
		}

		public static function getActiveScreen(chatContext:IChatContext):IScreenContext
		{
			var plug:ITabManagerPlugin = (chatContext.getPlugin(ITabManagerPlugin) as ITabManagerPlugin);
			return (plug) ? plug.getActiveTab() : null;
		}

	}
}