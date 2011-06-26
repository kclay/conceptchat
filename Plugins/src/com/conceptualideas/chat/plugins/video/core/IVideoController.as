package com.conceptualideas.chat.plugins.video.core
{

	/**
	 *
	 * @author cideas
	 *
	 */
	public interface IVideoController
	{
		/**
		 *
		 * @param willPublish
		 *
		 */
		function publish(willPublish:Boolean):void
		function togglePublish():void
		function toggleMute():void
		function mute():void
		function unmute():void
		function toggleStreamsVolume():void
		function muteAllStreams():void
		function unmuteAllStreams():void
		function setCamera(name:String):void
		function setMicrophone(index:int=-1):void
	}
}