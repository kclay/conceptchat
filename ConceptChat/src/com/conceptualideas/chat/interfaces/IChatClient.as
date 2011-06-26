package com.conceptualideas.chat.interfaces
{
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.models.ConnectionInfo;
	import com.conceptualideas.chat.models.NotificationMessage;
	
	import flash.events.IEventDispatcher;
	import flash.net.NetConnection;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public interface IChatClient extends IEventDispatcher
	{
		function changeName(name:String):void
		function get globalDispatcher():IEventDispatcher
		function addMessage(message:Object):void
		function updateUserInfo(info:ChatUser):void
		function reconnect():void
		function get roomName():String
		function connectToRoom(connectInfo:ConnectionInfo):void
		function get connection():NetConnection
		function disconnectFromRoom():void
		function sendNotification(notification:NotificationMessage):void
		function call(method:String, callback:Function, ... parameters:Array):void
		function setProperty(user:ChatUser,name:String, value:Object):void
	}

}