package com.conceptualideas.chat.plugins.media
{
	import flash.media.Camera;
	import flash.media.Microphone;

	public interface IPublishManager extends IMediaManager
	{
		function set microphone(value:Microphone):void
		function set camera(value:Camera):void
	}
}