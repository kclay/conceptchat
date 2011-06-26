package com.conceptualideas.chat.plugins.manage.tasks
{
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.plugins.manage.IUserManagementPlugin;
	import com.conceptualideas.chat.tasks.BaseTask;

	public class IgnoreTask extends BaseTask
	{
		private var chatContext:IChatContext

		public function IgnoreTask(chatContext:IChatContext)
		{
			super();
			this.chatContext = chatContext;
		}

		public function addIgnore(user:ChatUser, timeLimit:int=-1):Boolean
		{
			return getPlugin().addIgnore(user, timeLimit);
		}

		public function removeIgnore(criteria:Object):Boolean
		{
			return getPlugin().removeIgnore(criteria);
		}

		private function getPlugin():IUserManagementPlugin
		{
			return chatContext.getPlugin(IUserManagementPlugin) as IUserManagementPlugin
		}
	}
}