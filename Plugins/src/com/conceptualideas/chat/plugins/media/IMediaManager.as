package com.conceptualideas.chat.plugins.media
{
	import flash.media.Video;

	public interface IMediaManager
	{
		function set volume(value:Number):void
		function mute():void
		function unmute():void
		function dispose():void
		function connect(stream:String):void
	}
}