package com.conceptualideas.chat.plugins.video
{
	import flash.media.Camera;

	public class VideoBlockModel
	{
		public var camera:Camera
		public var currentState:String = "preview";

		public function VideoBlockModel()
		{
		}
	}
}