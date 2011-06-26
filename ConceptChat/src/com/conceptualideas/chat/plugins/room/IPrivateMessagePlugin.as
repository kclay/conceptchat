package com.conceptualideas.chat.plugins.room
{
	public interface IPrivateMessagePlugin
	{
		function sendChatRequest(toUserName:String, message:String=null):Boolean
	}
}