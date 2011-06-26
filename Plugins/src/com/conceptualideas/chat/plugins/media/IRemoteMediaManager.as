package com.conceptualideas.chat.plugins.media
{
	import flash.media.Camera;
	import flash.media.Video;

	public interface IRemoteMediaManager extends IMediaManager
	{
		function set video(value:Video):void
		function get video():Video
		function set camera(value:Camera):void
	}
}