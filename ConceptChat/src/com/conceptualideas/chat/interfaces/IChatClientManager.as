package com.conceptualideas.chat.interfaces
{
	import com.conceptualideas.chat.models.ChatRoomInfo;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.models.ConnectionInfo;
	import com.conceptualideas.chat.models.NotificationMessage;
	
	import flash.events.IEventDispatcher;
	import flash.net.NetConnection;

	
	[Event(name="roomInfoRetrived", type="com.conceptualideas.chat.events.ChatClientManagerEvent")]
	[Event(name="newMessage", type="com.conceptualideas.chat.events.ChatClientManagerEvent")]
	[Event(name="userlistUpdated", type="com.conceptualideas.chat.events.ChatClientManagerEvent")]
	public interface IChatClients IEventDispatcher
	{
		/**
		 * Adds an message to that ChatScreen 
		 */		
		function addMessage(message:Object):void
			
		/**
		 * 
		 */
		function connectToRoom(connectInfo:ConnectionInfo):void
		/**
		 * 
		 */
		function call(method:String, callback:Function, ... parameters:Array):void		
		function get connection():NetConnection		
		function updateUserInfo(chatUser:ChatUser):void
		function disconnectFromRoom():void
		function get globalDispatcher():IEventDispatcher
		function sendNotification(notification:NotificationMessage):void
	}
}