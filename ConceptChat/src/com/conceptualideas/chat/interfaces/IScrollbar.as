package com.conceptualideas.chat.interfaces
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public interface IScrollbar
	{

		function set visible(value:Boolean):void
		/**
		 *  @private
		 *  Turn off buttons, or turn on buttons and resync thumb.
		 */
		function set enabled(value:Boolean):void;
		/**
		 *  The number of lines equivalent to one page.
		 *
		 *  @default 0
		 */
		function get pageSize():Number;
		/**
		 *  @private
		 */
		function set pageSize(value:Number):void;
		/*@default 0
		 */
		function get minScrollPosition():Number;
		/**
		 *  @private
		 */

		function set minScrollPosition(value:Number):void;

		/**
		 *  Amount to scroll when an arrow button is pressed, in pixels.
		 *
		 *  @default 1
		 */
		function get lineScrollSize():Number;
		/**
		 *  @private
		 */
		function set lineScrollSize(value:Number):void;
		/// Registers an event listener object with an EventDispatcher object so that the listener receives notification of an event.
		function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;

		/// Dispatches an event into the event flow.
		function dispatchEvent(event:Event):Boolean;

		

		/// Checks whether the EventDispatcher object has any listeners registered for a specific type of event.
		function hasEventListener(type:String):Boolean;

		/// Removes a listener from the EventDispatcher object.
		function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;

		function toString():String;

		/// Checks whether an event listener is registered with this EventDispatcher object or any of its ancestors for the specified event type.
		function willTrigger(type:String):Boolean;

		function set scrollPosition(value:Number):void

		function get maxScrollPosition():Number
		function set maxScrollPosition(value:Number):void
	}

}