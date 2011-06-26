package com.conceptualideas.chat.interfaces
{
	import com.conceptualideas.chat.plugins.AbstractChatPlugin;
	
	
	import flash.events.IEventDispatcher;

	/**
	 *
	 * @author cideas
	 *
	 */
	[Event(name="nameChanged", type="flash.events.Event")]
	[Event(name="addedScreen", type="com.conceptualideas.chat.events.ChatContextEvent")]
	[Event(name="removedScreen", type="com.conceptualideas.chat.events.ChatContextEvent")]
	[Event(name="init", type="com.conceptualideas.chat.events.ChatContextEvent")]
	public interface IChatContext extends IEventDispatcher
	{
		/**
		 * Retuns main chat application instance aka root
		 * **/
		function get chatApplication():IChatApplication
		/**
		 * Loads a plugin or adds to load que, Plugins are then loaded once
		 * the context has been created, if the context has alrady been
		 * created the plugin will load on demand
		 * @param content Can be of String ( external plugin) or class instance
		 *
		 */
		function loadPlugin(content:Object):void

		
		function hasPlugin(classOrName:*):Boolean
		/**
		 * Retrive an plugin instance either by its class(Interface) or name
		 * @param classOrName
		 * @return
		 *
		 */
		function getPlugin(classOrName:*):AbstractChatPlugin
		/**
		 * Adds a new screen to the chat context for managing
		 * This wil dispatch an ChatContextEvent.ADDED_SCREEN which
		 * can be listened to from the AbstractChatPlugin class
		 * @param screenContext
		 *
		 */
		function addScreen(screenContext:IScreenContext):void

		/**
		 * Returns the number of active screens
		 * @return
		 *
		 */
		function get numOfScreens():Number

		/**
		 * Returns a collection of current IScreenContext
		 * @return
		 *
		 */
		function get chatScreens():Vector.<IScreenContext>
		/**
		 * Retrives an IScreenContext at a given index, will throw and
		 * range error if out of range
		 * @param index
		 * @return
		 *
		 */
		function getScreenAt(index:int):IScreenContext
		/**
		 * Returns the index of the passed screenContext
		 * @param screenContext IScreenContext to find the index of
		 * @return
		 *
		 */
		function getScreenIndex(screenContext:IScreenContext):int
		
			
		function hasScreen(name:String):Boolean
		/**
		 * 
		 * @param name
		 * @return 
		 * 
		 */
		function getScreenByName(name:String):IScreenContext
		function removeScreen(screen:IScreenContext):IScreenContext
		/**
		 * Removes a screen at the passed index, if out of range
		 * an error will be thrown, On removal an ChatChatEvent.REMOVED_SCREEN
		 * @param index  Index to remove
		 * @return
		 *
		 */
		function removeScreenAt(index:int):IScreenContext
		/**
		 * Creates the context and starts the loading process
		 *
		 */
		function create(name:String):void
		/**
		 * Returns the current user name
		 * @return
		 *
		 */
		function get userName():String

		function set composerContext(value:IComposerContext):void

		function isGuest():Boolean
		function get loaded():Boolean

	}
}