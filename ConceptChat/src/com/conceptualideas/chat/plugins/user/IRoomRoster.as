package com.conceptualideas.chat.plugins.user
{
	import com.conceptualideas.chat.models.ChatUser;
	
	import flash.events.IEventDispatcher;


	/**
	 *
	 * @author cideas
	 *
	 */
	[Event(name="rosterUpdated", type="flash.events.Event")]
	public interface IRoomRoster extends IEventDispatcher
	{
		/**
		 *
		 * @return
		 *
		 */
		function getUserNames():Vector.<String>
		/**
		 *
		 * @param clientID
		 * @return
		 *
		 */
		function getByClientID(clientID:String):ChatUser
		/**
		 *
		 * @param userName
		 * @return
		 *
		 */
		function getByName(userName:String):ChatUser

	
		/**
		 *
		 * @return
		 *
		 */
		function get size():int
		/**
		 *
		 * @return
		 *
		 */
		function hash():String
		/**
		 *
		 * @return
		 *
		 */
		function getUsers():Vector.<ChatUser>
		/**
		 *
		 * @return
		 *
		 */
		function get name():String
			
		function hasUser(name:String):Boolean
			
		function getFilterList(flags:uint):Vector.<Object>

	}
}