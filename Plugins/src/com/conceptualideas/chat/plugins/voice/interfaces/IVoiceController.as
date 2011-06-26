package com.conceptualideas.chat.plugins.voice.interfaces
{
	import com.conceptualideas.chat.interfaces.IDisposable;
	
	import flash.events.IEventDispatcher;

	public interface IVoiceController 
	{
		function set broadcast(value:Boolean):void
		function set volume(direction:Number):void
	}
}