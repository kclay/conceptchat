package com.conceptualideas.chat.plugins.media
{
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;

	public class PublishMediaManager extends BaseMediaManager implements IPublishManager
	{


		private var _microphone:Microphone
		private var _camera:Camera
		private var timerClosePublish:Timer

		private var createPublishStream:Boolean

		public function PublishMediaManager(netConnection:NetConnection)
		{
			super(netConnection);
		}



		/**
		 *
		 * @param mic
		 *
		 */
		public function set microphone(value:Microphone):void
		{
			if (_microphone == value)
				return;
			_microphone = value;
			if (hasNetStream)
				netStream.attachAudio(value);

		}

		/**
		 *
		 * @param camera
		 *
		 */
		public function set camera(value:Camera):void
		{
			if (_camera == value)
				return;
			_camera = value;

			if (hasNetStream)
				netStream.attachCamera(value);
		}

		override protected function connectToStream():void
		{


			if (!streamName)
				return;
			if (hasNetStream)
			{
				createPublishStream = true;
				unpublish();
				return;
			}

			if (!timerClosePublish)
			{
				timerClosePublish = new Timer(250);
				timerClosePublish.addEventListener(TimerEvent.TIMER, onTimerTick);
			}




			var stream:NetStream = netStream;

			var metaData:Object = {description:streamName};


			stream.bufferTime = 0;

			stream.send("@setDataFrame", "onMetaData", metaData);

			stream.attachCamera(_camera);
			stream.attachAudio(_microphone);
			stream.publish(streamName);
			volume = 100;
		}

		public function unpublish():void
		{
			if (!hasNetStream)
				return;
			var stream:NetStream = netStream;
			stream.attachCamera(null);
			stream.attachAudio(null);
			var buffer:Number = stream.bufferLength;
			if (buffer > 0)
			{
				timerClosePublish.start();
			}
			else
			{
				finishClosingPublishStream();
			}
		}

		private function finishClosingPublishStream():void
		{
			netStream.publish();
			destroyNetStream();
			if (createPublishStream)
			{
				connectToStream();
				createPublishStream = false;
			}
		}

		private function onTimerTick(e:TimerEvent):void
		{

			if (netStream.bufferLength == 0)
			{
				timerClosePublish.stop();
				timerClosePublish.reset();

				finishClosingPublishStream();

			}
		}

		override public function mute():void
		{
			if (hasNetStream)
				netStream.attachAudio(null);
		}

		override public function unmute():void
		{
			if (hasNetStream)
				netStream.attachAudio(_microphone);
		}

		override public function set volume(value:Number):void
		{
			super.volume = value;
			if (_microphone)
				_microphone.soundTransform = soundTransform;
		}

		override public function dispose():void
		{
			if (netStream)
			{

				netStream.attachCamera(null);
				netStream.attachAudio(null);
				netStream.publish();


			}
			

			_microphone = null;
			_camera = null;

			if (timerClosePublish)
			{
				timerClosePublish.stop();
				timerClosePublish.removeEventListener(TimerEvent.TIMER, onTimerTick)
				timerClosePublish = null;
			}

			super.dispose()

		}

	}
}