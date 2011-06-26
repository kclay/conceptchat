package com.conceptualideas.chat.plugins.media
{
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class RemoteMediaManager extends BaseMediaManager implements IRemoteMediaManager
	{
		public function RemoteMediaManager(netConnection:NetConnection)
		{
			super(netConnection);
		}


		private var _video:Video

		private var videoChanged:Boolean = false

		public function set video(value:Video):void
		{
			if (_video == value)
				return;
			if (_video)
				_video.attachNetStream(null);
			_video = value;

			videoChanged = true;
			attachObjects()
			//dispatchEvent(new Event("videoChanged"));


		}
		private var _camera:Camera

		public function set camera(value:Camera):void
		{
			if (_camera == value)
				return;

			_camera = value;
			videoChanged = true;
			attachObjects()

		}

		public function get video():Video
		{
			return _video;
		}

		override public function mute():void
		{
			if (hasNetStream)
				netStream.receiveAudio(false);
		}

		override public function unmute():void
		{
			if (hasNetStream)
				netStream.receiveAudio(true);
		}


		override protected function attachObjects():void
		{
			if (videoChanged)
			{
				if (_video && _camera)
				{
					_video.attachNetStream(null);
					_video.attachCamera(_camera);

				}
				else if (_video && hasNetStream)
				{
					_video.attachNetStream(netStream);
				}
				videoChanged = false;
			}

		}

		override protected function connectToStream():void
		{

			if (hasNetStream)
			{
				destroyNetStream();
			}

			var stream:NetStream = netStream;

			stream.client = {
					onMetaData:function(info:Object):void
				{

				}
				};
			stream.bufferTime = 0;

			stream.play(streamName);

			volume = 100;
		}

		override public function dispose():void
		{
			if (_video)
			{
				_video.attachCamera(null);
				_video.attachNetStream(null);
			}
			_video = null;
			_camera = null;
			super.dispose();
		}
	}
}