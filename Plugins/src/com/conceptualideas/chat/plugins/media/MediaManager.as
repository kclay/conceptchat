package com.conceptualideas.chat.plugins.media
{
	import com.conceptualideas.chat.plugins.voice.events.VoiceManagerEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;

	/**
	 *
	 * @author cideas
	 *
	 */
	public class MediaManager extends EventDispatcher implements IMediaManager
	{
		private var video:Video

		private var remoteStream:NetStream

		private var publishStream:NetStream

		private var _streamName:String
		private var _remoteStreamName:String

		private var timerClosePublish:Timer

		private var mic:Microphone

		private var camera:Camera

		private var createPublishStream:Boolean = false;

		private var remoteSoundTransform:SoundTransform = new SoundTransform();
		private var publishSoundTransform:SoundTransform = new SoundTransform();

		private var willAcceptOrPublishCamera:Boolean = true;

		private var willAcceptOrPublishAudio:Boolean = true;

		/**
		 *
		 */
		public var _slot:Number = 0;

		private const FLAG_PENDING:uint = 1 << 0;

		private const FLAG_CONNECTED_BUT_NO_STREAM:uint = 1 << 1

		private const FLAG_CONNECTED_WITH_STREAM:uint = 1 << 2;

		private var _currentState:uint = FLAG_PENDING;


		//private const chatClient:ChatClient = ChatClient.getInstance();
		//private var mediaManager:MediaManager


		private var netConnection:NetConnection



		/**
		 *
		 * @param netConnection
		 *
		 */
		public function MediaManager(netConnection:NetConnection):void
		{

			this.netConnection = netConnection;
			//this.mediaManager = mediaManager;
			//chatClient.addEventListener(ChatClientEvent.NOTIFY, chat_notifyHandler);

		}


		/*private function chat_notifyHandler(e:ChatClientEvent):void
		   {

		   switch (e.data.type)
		   {
		   case NotifyMessages.VIDEO_STATUS_CHANGED:
		   {

		   var sendingCamera:Boolean = e.data.sendingCamera;
		   if (e.data.slot == slot)
		   {
		   changeFlagState(sendingCamera ? FLAG_CONNECTED_WITH_STREAM : FLAG_CONNECTED_BUT_NO_STREAM);
		   }

		   break;
		   }
		   case NotifyMessages.KICK_SLOT:
		   {

		   if (e.data.slot == slot) // only connected room
		   {
		   dispatchEvent(new VideoRoomEvent(VideoRoomEvent.KICKED));
		   mediaManager.refresh();
		   }

		   break;
		   }
		   case NotifyMessages.SLOT_INFO_UPDATED:
		   {

		   var isSlotOpen:Boolean = e.data["slot_" + slot];
		   if (!pending)
		   changeFlagState(FLAG_PENDING);
		   break;
		   }
		   }
		 }*/




		[Bindable(name="currentStateChanged")]
		/**
		 *
		 * @return
		 *
		 */
		public function get isConnected():Boolean
		{
			return _currentState != FLAG_PENDING;
		}

		[Bindable(name="currentStateChanged")]
		/**
		 *
		 * @return
		 *
		 */
		public function get pending():Boolean
		{
			return _currentState == FLAG_PENDING;
		}


		[Bindable(name="currentStateChanged")]
		/**
		 *
		 * @return
		 *
		 */
		public function get isConnectedNoStream():Boolean
		{
			return _currentState == FLAG_CONNECTED_BUT_NO_STREAM;
		}

		[Bindable(name="currentStateChanged")]
		/**
		 *
		 * @return
		 *
		 */
		public function get isConnectedWithStream():Boolean
		{
			return _currentState == FLAG_CONNECTED_WITH_STREAM;
		}

		/**
		 *
		 * @param v
		 *
		 */
		public function set streamName(v:String):void
		{
			if (remoteStream)
			{
				remoteStream.close();
			}
			_streamName = v;
		}

		/**
		 *
		 * @param video
		 *
		 */
		public function bind(video:Video):void
		{
			this.video = video;

			updateVideoBindings();

		}

		private function updateVideoBindings():void
		{
			if (remoteStream && video)
			{
				video.attachNetStream(remoteStream);
			}
			else if (video)
			{
				video.attachCamera(camera);
				
			}


		}

		/**
		 *
		 * @param remoteStreamName
		 *
		 */
		public function connect(remoteStreamName:String):void
		{


			changeFlagState(FLAG_PENDING);
			if (remoteStream)
			{
				remoteStream.close();
				remoteStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				remoteStream = null;
			}
			remoteStream = new NetStream(netConnection);
			remoteStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			remoteStream.client = {
					onMetaData:function(info:Object):void
				{

				}
				};
			remoteStream.bufferTime = 0;

			remoteStream.play(remoteStreamName);


			updateReciveOptions();
			remoteStreamVolume = 100;
			updateVideoBindings();



		}



		/**
		 *
		 *
		 */
		public function unpublish():void
		{
			if (!publishStream)
				return;
			publishStream.attachCamera(null);
			publishStream.attachAudio(null);
			var buffer:Number = publishStream.bufferLength;
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
			publishStream.publish();
			publishStream = null;
			if (createPublishStream)
			{
				publish();
				createPublishStream = false;
			}
		}

		/**
		 *
		 * @param mic
		 *
		 */
		public function setMicrophone(mic:Microphone):void
		{
			this.mic = mic;
			if (publishStream)
				publishStream.attachAudio(mic);

		}

		/**
		 *
		 * @param camera
		 *
		 */
		public function setCamera(camera:Camera):void
		{
			this.camera = camera;
			updateVideoBindings();
			if (publishStream)
				publishStream.attachCamera(camera);



		}

		/**
		 *
		 * @param v
		 *
		 */
		public function acceptOrPublishCamera(v:Boolean):void
		{
			willAcceptOrPublishCamera = v;
			updateVideoOptions();


		}

		/**
		 *
		 * @param v
		 *
		 */
		public function acceptOrPublishAudio(v:Boolean):void
		{
			willAcceptOrPublishAudio = v;
			updateAudioOptions();
		}

		private function updateAudioOptions():void
		{
			setReceiveAudio(remoteStream, willAcceptOrPublishAudio);
			setReceiveAudio(publishStream, willAcceptOrPublishAudio);
		}

		private function updateVideoOptions():void
		{
			setReceiveVideo(remoteStream, willAcceptOrPublishCamera);
			setReceiveVideo(publishStream, willAcceptOrPublishCamera);

		/*if (publishStream)
		   {
		   // Notify other users about this change

		   chatClient.notify(NotifyMessages.VIDEO_STATUS_CHANGED, {
		   slot:_slot,
		   sendingCamera:willAcceptOrPublishCamera
		   });
		 }*/

		}

		private function updateReciveOptions():void
		{
			updateVideoOptions();
			updateAudioOptions();

		}

		private function setReceiveVideo(stream:NetStream, flag:Boolean):void
		{
			if (!stream)
				return;
			if (stream == remoteStream)
				stream.receiveVideo(flag);
			else
				stream.attachCamera(flag ? camera : null);
		}

		private function setReceiveAudio(stream:NetStream, flag:Boolean):void
		{
			if (!stream)
				return;
			if (stream == remoteStream)
				stream.receiveAudio(flag);
			else
				stream.attachAudio(flag ? mic : null);

		}

		/**
		 *
		 * @param streamName
		 *
		 */
		public function publish(streamName:String=null):void
		{

			if (streamName != null)
				_streamName = streamName;
			if (!_streamName)
				return;
			if (publishStream)
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




			publishStream = new NetStream(netConnection);

			var metaData:Object = {description:_streamName};

			publishStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			publishStream.bufferTime = 0;

			publishStream.send("@setDataFrame", "onMetaData", metaData);

			publishStream.attachCamera(camera);
			publishStream.attachAudio(mic);
			publishStream.publish(_streamName);

			updateReciveOptions()
			publishingStreamVolume = 100;

		}

		private function onTimerTick(e:TimerEvent):void
		{

			if (publishStream.bufferLength == 0)
			{
				timerClosePublish.stop();
				timerClosePublish.reset();

				finishClosingPublishStream();

			}
		}

		private function changeFlagState(flag:uint):void
		{
			if (_currentState == flag)
				return;
			_currentState = flag
			dispatchEvent(new Event("currentStateChanged"));
		}



		/*private function checkIfSlotOpen():void
		   {
		   if (slotCheckWorking)
		   return;
		   slotCheckWorking = true;
		   chatClient.isSlotOpen(chatClient.currentRoom, _slot, chat_slotOpenHandler);
		   }

		   private function chat_slotOpenHandler(open:Boolean):void
		   {

		   slotCheckWorking = false;
		   changeFlagState(open ? FLAG_PENDING : FLAG_CONNECTED_BUT_NO_STREAM);

		 }*/


		private function onNetStatus(e:NetStatusEvent):void
		{


			switch (e.info.code)
			{

				case "NetStream.Play.UnpublishNotify":
				case "NetStream.Play.StreamNotFound":
					// new room connected via .connect() but stream wasn't found
					//for this we check on more time to see if slot is open but user isn't sending video
					/*if (pending)
					 checkIfSlotOpen();*/

					changeFlagState(FLAG_CONNECTED_BUT_NO_STREAM);

					dispatchEvent(new VoiceManagerEvent(VoiceManagerEvent.DISCONNECTED,
						false, false, _streamName));
					break;

				case "NetStream.Play.Start":
				case "NetStream.Publish.Start":
					changeFlagState(FLAG_CONNECTED_WITH_STREAM);

					dispatchEvent(new VoiceManagerEvent(VoiceManagerEvent.CONNECTED,
						false, false, _streamName));
					break;


			}
		}

		public function get remoteStreamVolume():Number
		{
			return remoteSoundTransform.volume * 100;
		}

		public function set remoteStreamVolume(vol:Number):void
		{
			setVolume(remoteSoundTransform, vol)
			if (remoteStream)
				remoteStream.soundTransform = remoteSoundTransform;
		}

		public function get publishingStreamVolume():Number
		{
			return publishSoundTransform.volume * 100;
		}

		public function set publishingStreamVolume(vol:Number):void
		{
			setVolume(publishSoundTransform, vol)
			if (mic)
				mic.soundTransform = publishSoundTransform;
			//if (publishStream)
			//publishStream.soundTransform = publishSoundTransform;
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
		}

		public function unmute():void
		{
			//TODO Auto-generated method stub
		}

		public function set volume(value:Number):void
		{
			remoteStreamVolume = value;
			publishingStreamVolume = value;

			//TODO Auto-generated method stub
		}

		/**
		 *
		 *
		 */
		public function dispose():void
		{
			if (publishStream)
			{
				publishStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				publishStream.attachCamera(null);
				publishStream.attachAudio(null);
				publishStream.publish();
				publishStream = null;

			}
			if (remoteStream)
			{
				remoteStream.close();
				remoteStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				remoteStream = null;
			}
			mic = null;
			camera = null;
			video = null;
			if (timerClosePublish)
			{
				timerClosePublish.stop();
				timerClosePublish.removeEventListener(TimerEvent.TIMER, onTimerTick)
				timerClosePublish = null;
			}
			netConnection = null;
			remoteSoundTransform = null;
			publishSoundTransform = null;
		}
	}
}