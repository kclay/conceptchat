package com.conceptualideas.chat.plugins.manage
{
	import com.conceptualideas.chat.models.ChatUser;

	public interface IUserManagementPlugin
	{
		function addIgnore(user:ChatUser,timelimit:int=-1):Boolean
		function removeIgnore(criteria:Object):Boolean
	}
}