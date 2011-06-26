package com.conceptualideas.chat.plugins.user
{
	import com.conceptualideas.chat.interfaces.IChatClient;
	
	import com.conceptualideas.chat.models.ChatUser;

	public interface IUserManagerPlugin 
	{
		function hasUser(name:String):Boolean
		function getByClientID(clientID:String):ChatUser
		function getByName(userName:String):ChatUser
		function getRoomByClient(client:IChatClient):IRoomRoster
		/**
		 *
		 * @param name
		 * @return
		 *
		 * */
		function getRoomByName(name:String):IRoomRoster
		
	}
}