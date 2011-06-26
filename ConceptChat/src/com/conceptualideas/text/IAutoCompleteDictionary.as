package com.conceptualideas.text
{
	import flash.events.IEventDispatcher;

	[Event(name="updated", type="com.conceptualideas.chat.events.AutoCompleteDictionaryEvent")]
	public interface IAutoCompleteDictionary extends IEventDispatcher
	{

		function clear():void
		function add(word:String):void
		function addAll(words:Vector.<String>):void
		function complete(fragement:String):Vector.<String>

	}
}