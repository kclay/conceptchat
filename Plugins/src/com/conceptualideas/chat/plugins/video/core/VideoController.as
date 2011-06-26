package com.conceptualideas.chat.plugins.video.core
{
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.interfaces.IDock;
	import com.conceptualideas.chat.plugins.media.IMediaManager;
	import com.conceptualideas.chat.plugins.media.IPublishManager;
	import com.conceptualideas.chat.plugins.media.MultiMediaManager;
	import com.conceptualideas.chat.plugins.media.PublishMediaManager;
	import com.conceptualideas.chat.plugins.media.RemoteMediaManager;
	import com.conceptualideas.chat.plugins.user.IRoomRoster;
	import com.conceptualideas.chat.plugins.video.views.VideoBlock;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SyncEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;

	/**
	 *
	 * @author cideas
	 *
	 */
	public class VideoController extends EventDispatcher implements IDisposable, IVideoController
	{










		private var myStreamName:String;

		private var chatClient:IChatClient

		private var dock:IDock



		private var blockedCameras:Object = {};
		private var userManagerMapping:Dictionary = new Dictionary();

		private static const FLAG_PREFIX:String = "plugins.videochat::";


		private static const FLAG_EMPTY:uint = 1 << 0;
		private static const FLAG_STREAM_ADDED:uint = 1 << 1;

		private static const FLAG_STREAM_REMOVED:uint = 1 << 2

		private static const FLAG_HAS_CAMERA:uint = 1 << 3
		private static const FLAG_NO_CAMERA:uint = 1 << 4;

		private var fromChatRoom:String

		private var sharedObject:SharedObject

		private static const FLAG_TYPE_PRESENCE:String = "presence";
		private static const FLAG_TYPE_CAMERA:String = "camera";
		private static const FLAG_TYPE_MICROPHONE:String = "microphone";







		private var currentFlags:Object = {
				"presence":FLAG_EMPTY,
				"camera":FLAG_EMPTY,
				"microphone":FLAG_EMPTY
			}




		private var roster:IRoomRoster

		/**
		 *
		 * @param userName
		 * @param roster
		 * @param chatClient
		 * @param dock
		 *
		 */
		public function VideoController(userName:String,
			roster:IRoomRoster,
			chatClient:IChatClient,
			dock:IDock, blockWidth:Number=160, blockHeight:Number=120
			)
		{
			this.roster = roster;
			fromChatRoom = roster.name;
			_username = userName;


			this.dock = dock;
			this.chatClient = chatClient;
			this.blockHeight = blockHeight;
			this.blockWidth = blockWidth;

			init();
		}






		private var _maxVideoCount:Number = -1;

		private var currentVideoCount:Number = 0;

		public function set maxVideoCount(value:Number):void
		{
			_maxVideoCount = value;
		}

		public function set cameraQuality(value:Number):void
		{
			if (_cameraQuality == value)
				return;
			_cameraQuality = value;
			//if(
		}

		private var _cameraQuality:Number = 85;
		private var blockWidth:Number = 162;
		private var blockHeight:Number = 120;

		/**
		 * Resize all video blocks
		 * @param width
		 * @param height
		 *
		 */
		public function resizeVideoBlocks(width:Number, height:Number):void
		{
			var block:VideoBlock
			for (var user:String in userManagerMapping)
			{
				block = VideoBlock(dock.retrive(user));
				block.width = width;
				block.height = height;
			}
			blockWidth = width;
			blockHeight = height;

		}

		/**
		 *
		 *
		 */
		public function mute():void
		{

			getManagerForUser(_username).mute()

			//TODO Auto-generated method stub
		}

		private var isMute:Boolean

		/**
		 *
		 *
		 */
		public function toggleMute():void
		{
			isMute = !isMute;
			(isMute) ? mute() : unmute()
		}

		private var isPublishing:Boolean

		/**
		 *
		 *
		 */
		public function togglePublish():void
		{
			isPublishing = !isPublishing;
			publish(isPublishing);
			//TODO Auto-generated method stub
		}



		/**
		 *
		 *
		 */
		public function unmute():void
		{
			getManagerForUser(_username).unmute();


			//TODO Auto-generated method stub
		}




		/**
		 *
		 *
		 */
		private var isStreamsMuted:Boolean = false;

		public function toggleStreamsVolume():void
		{
			//TODO Auto-generated method stub
			isStreamsMuted = !isStreamsMuted;
			(isStreamsMuted) ? muteAllStreams() : unmuteAllStreams();

		}

		/**
		 *
		 *
		 */
		public function muteAllStreams():void
		{
			for (var name:String in userManagerMapping)
			{
				if (name == _username)
					continue;
				getManagerForUser(name).mute();

			}
			//TODO Auto-generated method stub
		}

		/**
		 *
		 *
		 */
		public function unmuteAllStreams():void
		{
			for (var name:String in userManagerMapping)
			{
				if (name == _username)
					continue;
				getManagerForUser(name).unmute();
			}
		}



		private var firstRun:Boolean = true;

		private function init():void
		{

			myStreamName = getStreamNameForUser(_username);
			sharedObject = SharedObject.getRemote(fromChatRoom + "-streams", chatClient.connection.uri);
			sharedObject.addEventListener(SyncEvent.SYNC, sharedObject_syncHandler);

			sharedObject.connect(chatClient.connection);

			/*chatClient.globalDispatcher.addEventListener(ChatClientManagerEvent.NOTIFICATION,
			 global_notificationHandler);*/
			// user close browser without closing the active screen first so we clean up
			roster.addEventListener("rosterUpdated", roster_updatedHandler);
		}



		private function roster_updatedHandler(e:Event):void
		{
			for (var user:String in userManagerMapping)
			{
				if (!roster.hasUser(user))
				{
					deatchVideoStream(user);

				}
			}
		}

		private function hasFlags(base:uint, flags:uint):Boolean
		{
			return (base & flags) > 0;
		}



		private function sharedObject_syncHandler(e:SyncEvent):void
		{

			/*if (firstRun)
			   {
			   notifyFlagsChange()
			   firstRun = false;
			 }*/
			var data:Object = sharedObject.data;
			var flags:uint
			var user:String

			for (user in data)
			{

				if (user == _username)
					continue;
				flags = data[user];



				if (hasFlags(flags, FLAG_STREAM_ADDED) && _maxVideoCount &&
					currentVideoCount != _maxVideoCount)
				{

					if (userManagerMapping[user] || blockedCameras[user])
						continue;
					currentVideoCount++;
					setupVideoStream(user, true);
					updateHasCameraForBlock(user, hasFlags(flags, FLAG_HAS_CAMERA));


				}
				else if (hasFlags(flags, FLAG_STREAM_REMOVED))
				{

					if (!userManagerMapping[user])
						continue;
					currentVideoCount--;
					deatchVideoStream(user);
				}
			}


		}

		private function updateHasCameraForBlock(name:String, hasCamera:Boolean):void
		{
			var block:VideoBlock = dock.retrive(name) as VideoBlock;
			if (block)
				block.hasCamera = hasCamera;
		}

		private function getStreamNameForUser(name:String):String
		{
			return [name, fromChatRoom, "videochatstream"].join("-");
		}



		private function attachVideoStream(name:String):MultiMediaManager
		{


			var block:VideoBlock = new VideoBlock();
			block.addEventListener(Event.CLOSE, videoBlock_closeHandler);
			var manager:MultiMediaManager = getManagerForUser(name);
			block.manager = manager;
			block.width = blockWidth;
			block.height = blockHeight;
			dock.add(name, block);
			block.label = name;

			return manager;

		}

		private function getManagerForUser(name:String):MultiMediaManager
		{

			var manager:MultiMediaManager = userManagerMapping[name];
			if (manager)
				return manager;

			var publish:IPublishManager = (name == _username) ? new PublishMediaManager(chatClient.connection) : null;
			manager = userManagerMapping[name] = new MultiMediaManager(
				new RemoteMediaManager(chatClient.connection), publish);
			if (name == _username)
			{
				setCamera(activeCamera);
				setMicrophone(activeMicrophone);

			}

			return manager;

		}

		/**
		 * Setups a video stream
		 * @param name User name to setup
		 * @param remote Weather the stream to setup is one of remote(connect to) or local(publish to users)
		 *
		 */
		public function setupVideoStream(name:String, remote:Boolean):void
		{

			var streamName:String = getStreamNameForUser(name);
			var manager:IMediaManager = attachVideoStream(name);
			manager.connect(streamName);
		}

		private function deatchVideoStream(name:String):void
		{
			if (!userManagerMapping[name])
				return;
			var panel:VideoBlock = VideoBlock(dock.remove(name));
			var manager:MultiMediaManager = userManagerMapping[name];
			manager.dispose();
			userManagerMapping[name] = null;
			delete userManagerMapping[name];
			if (panel is IDisposable)
				IDisposable(panel).dispose();
			panel.removeEventListener(Event.CLOSE, videoBlock_closeHandler);
			delete blockedCameras[name];
		}

		private function videoBlock_closeHandler(e:Event):void
		{
			var block:VideoBlock = VideoBlock(e.target);
			var username:String = block.label;

			if (username == _username) // stop publishing our stream
			{
				publish(false);
			}
			else
			{
				deatchVideoStream(username);
				blockedCameras[username] = true;
			}

		}



		private var activeCamera:String = null

		/**
		 *
		 * @param name
		 *
		 */
		public function setCamera(name:String):void
		{


			activeCamera = name;
			var camera:Camera = Camera.getCamera(name);

			var manager:MultiMediaManager = getManagerForUser(_username);
			manager.camera = camera;




			notifyFlagsChange(camera ?
				FLAG_HAS_CAMERA : FLAG_NO_CAMERA,
				FLAG_TYPE_CAMERA)

			if (camera)
			{

				camera.setQuality(0, _cameraQuality);
					//	camera.setMode(320, 240, 30, false)
			}


		}





		private function notifyFlagsChange(flags:int=0, type:String=null):void
		{
			if (type)
				currentFlags[type] = flags;
			var combinedFlags:uint = FLAG_EMPTY;
			for each (flags in currentFlags)
				combinedFlags |= flags;
			sharedObject.setProperty(_username, combinedFlags);
			if (type == FLAG_TYPE_CAMERA)
			{
				updateHasCameraForBlock(_username, hasFlags(combinedFlags, FLAG_HAS_CAMERA))
			}



		}

		private var activeMicrophone:int = -1;

		/**
		 *
		 * @param index
		 *
		 */
		public function setMicrophone(index:int=-1):void
		{

			activeMicrophone = index;
			getManagerForUser(_username).microphone = Microphone.getMicrophone(index);



		}

		/**
		 *
		 * @param willPublish
		 *
		 */
		public function publish(willPublish:Boolean):void
		{
			if (!willPublish)
			{

				deatchVideoStream(_username);
				notifyFlagsChange(FLAG_STREAM_REMOVED, FLAG_TYPE_PRESENCE);
			}
			else
			{

				setupVideoStream(_username, false);
				notifyFlagsChange(FLAG_STREAM_ADDED, FLAG_TYPE_PRESENCE);
			}
			isPublishing = willPublish;



		}
		/**
		 * Current user thats going to dispatch
		 * */
		private var _username:String

		public function set username(value:String):void
		{
			var rePublish:Boolean
			if (_username == value)
				return;
			if (userManagerMapping[_username])
			{
				publish(false)
				rePublish = true;
			}

			myStreamName = getStreamNameForUser(value);
			_username = value;
			if (rePublish)
			{
				publish(true);
			}
		}

		/**
		 *
		 *
		 */
		public function dispose():void
		{
			notifyFlagsChange(FLAG_STREAM_REMOVED, FLAG_TYPE_PRESENCE);
			for (var user:String in userManagerMapping)
			{
				deatchVideoStream(user);
			}

			dock = null;
			roster.removeEventListener("rosterUpdated", roster_updatedHandler);
			roster = null;
			/*chatClient.globalDispatcher.removeEventListener(ChatClientManagerEvent.NOTIFICATION,
			 global_notificationHandler);*/
			chatClient = null;
			sharedObject.removeEventListener(SyncEvent.SYNC, sharedObject_syncHandler);
			sharedObject = null;


		}
	}
}