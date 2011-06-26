package com.conceptualideas.chat.plugins.media
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class BaseMediaManager extends EventDispatcher implements IMediaManager
	{



		private var _netStream:NetStream
		private var netConnection:NetConnection

		private var _soundTransform:SoundTransform


		private var _streamName:String

		public function BaseMediaManager(netConnection:NetConnection)
		{
			this.netConnection = netConnection;
		}

		protected function get soundTransform():SoundTransform
		{
			if (!_soundTransform)
				_soundTransform = new SoundTransform();
			return _soundTransform;
		}

		protected function get hasNetStream():Boolean
		{
			return _netStream != null;
		}

		protected function attachObjects():void
		{

		}

		protected function destroyNetStream():void
		{
			if (hasNetStream)
			{

				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				_netStream.close();
				_netStream = null;
			}
		}

		protected function get netStream():NetStream
		{
			if (!_netStream)
			{
				_netStream = new NetStream(netConnection);
				_netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			}
			return _netStream;
		}

		final public function connect(stream:String):void
		{
			_streamName = stream;
			connectToStream();
		}



		public function get streamName():String
		{
			return _streamName;
		}

		protected function connectToStream():void
		{

		}


		private var _volume:Number

		public function get volume():Number
		{
			return _volume;
		}

		public function set volume(value:Number):void
		{


			value = Math.max(0, Math.min(100, value))
			value = value / 100;
			if (_volume == value && hasNetStream)
			{
				netStream.soundTransform = soundTransform;
				return;
			}
			_volume = value;
			soundTransform.volume = value;
			if (hasNetStream)
				netStream.soundTransform = soundTransform;

		}

		/**
		 * Passed in 0-100 range
		 * */
		private function setVolume(soundTransform:SoundTransform, vol:Number=NaN):void
		{
			vol = Math.max(0, Math.min(100, vol))
			if (isNaN(vol))
				vol = soundTransform.volume * 100;
			soundTransform.volume = vol / 100;


		}

		public function mute():void
		{
			//TODO Auto-generated method stub
			throw new IllegalOperationError("unmute not implemitate")
		}

		public function unmute():void
		{
			throw new IllegalOperationError("unmute not implemetated")
		}

		public function dispose():void
		{


			destroyNetStream()
			_soundTransform = null;
			netConnection = null;

		}

		protected function netStatusHandler(e:NetStatusEvent):void
		{


			switch (e.info.code)
			{

				case "NetStream.Play.UnpublishNotify":
				case "NetStream.Play.StreamNotFound":
					dispatchEvent(new MediaManagerEvent(MediaManagerEvent.DISCONNECTED, _streamName));

					break;

				case "NetStream.Play.Start":
				case "NetStream.Publish.Start":


					dispatchEvent(new MediaManagerEvent(MediaManagerEvent.CONNECTED, _streamName));

					break;


			}
		}
	}
}