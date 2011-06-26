package com.conceptualideas.chat.plugins.media
{
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;

	public class MultiMediaManager implements IRemoteMediaManager, IPublishManager
	{
		private var remote:IRemoteMediaManager
		private var publish:IPublishManager

		public function MultiMediaManager(remote:IRemoteMediaManager, publish:IPublishManager=null)
		{
			this.remote = remote;
			this.publish = publish;
		}

		public function set video(value:Video):void
		{
			if (remote)
				remote.video = value;
		}

		public function get video():Video
		{
			return (remote) ? remote.video : null;

		}

		public function set camera(value:Camera):void
		{
			if (remote)
				remote.camera = value; // this will attach the camera to the remote stream so it doesn't waste bw
			if (publish)
				publish.camera = value;
		}

		public function set microphone(value:Microphone):void
		{
			if (publish)
				publish.microphone = value;
			if (value)
				value.setLoopBack(true)


		}

		public function set volume(value:Number):void
		{
			if (remote)
				remote.volume = value;
			if (publish)
				publish.volume = value;
		}

		public function mute():void
		{
			if (remote)
				remote.mute();
			if (publish)
				publish.mute();
		}

		public function unmute():void
		{
			if (remote)
				remote.unmute();
			if (publish)
				publish.unmute();

		}

		public function dispose():void
		{
			if (remote)
				remote.dispose();
			remote = null;
			if (publish)
				publish.dispose();
			publish = null;
		}

		public function connect(stream:String):void
		{
			if (publish)
			{
				publish.connect(stream)
			}
			else if (remote)
			{
				remote.connect(stream);
			}
		}
	}
}