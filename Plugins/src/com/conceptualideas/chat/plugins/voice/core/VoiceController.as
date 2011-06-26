package com.conceptualideas.chat.plugins.voice.core
{
	import com.conceptualideas.chat.events.ChatClientManagerEvent;
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.models.ChatUser;
	import com.conceptualideas.chat.models.NotificationMessage;
	import com.conceptualideas.chat.plugins.media.MediaManager;
	import com.conceptualideas.chat.plugins.user.IRoomRoster;
	import com.conceptualideas.chat.plugins.voice.interfaces.IVoiceController;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Microphone;

	/**
	 *
	 * @author cideas
	 *
	 */
	public class VoiceController implements IVoiceController, IDisposable
	{
		private static const FLAG_VOICE_CONNECT:String = "com.conceptualideas.chat.plugins.voice::connect";

		private var dock:Sprite
		private var roster:IRoomRoster

		private var manager:MediaManager
		private var chatClient:IChatClient
		private var isBroadcasting:Boolean
		private var broadCastingStreamName:String
		private var sentNotificationOnce:Boolean
		private var userName:String
		private var microphone:Microphone

		private var currentBroadCastingVolume:Number

		/**
		 *
		 * @param userName
		 * @param chatClient
		 * @param roster
		 * @param dock
		 *
		 */
		public function VoiceController(userName:String,
			chatClient:IChatClient,
			roster:IRoomRoster,
			dock:Sprite)
		{
			this.userName = userName;
			this.chatClient = chatClient
			this.manager = new MediaManager(chatClient.connection);

			this.dock = dock;
			this.roster = roster;
			init();
		}

		/**
		 *
		 * @param direction
		 *
		 */
		public function set volume(direction:Number):void
		{
			var vol:Number = manager.publishingStreamVolume + direction;
			manager.publishingStreamVolume = vol;
		}

		private function getBroadCastingHash():String
		{
			return userName + "-" + (new Date()).time;
		}

		/**
		 *
		 * @param value
		 *
		 */
		public function set broadcast(value:Boolean):void
		{

			if (value)
			{
				microphone = Microphone.getMicrophone();
				if (microphone)
				{
					microphone.rate = 11;
					microphone.setUseEchoSuppression(true);

					manager.setMicrophone(microphone);
					manager.publish(broadCastingStreamName);

					if (!sentNotificationOnce)
					{
						var notification:NotificationMessage = new NotificationMessage();
						notification.flag = FLAG_VOICE_CONNECT;
						notification.data = broadCastingStreamName;
						var users:Vector.<ChatUser> = roster.getUsers();
						var user:ChatUser;
						for each (user in users)
						{
							if (user.name != userName)
							{
								notification.toClientID = user.clientID;
								chatClient.sendNotification(notification);
								sentNotificationOnce = true;

							}

						}


					}
				}
			}
			else
			{
				manager.unpublish();
			}
		}

		private function init():void
		{
			broadCastingStreamName = getBroadCastingHash();
			roster.addEventListener("rosterUpdated", roster_updateHandler);
			chatClient.globalDispatcher.addEventListener(ChatClientManagerEvent.NOTIFICATION,
				chatClient_notificationHandler);

		}

		private function chatClient_notificationHandler(e:ChatClientManagerEvent):void
		{
			var note:NotificationMessage = NotificationMessage(e.data);
			var user:ChatUser = roster.getByName(userName);
			if (!note || note.flag != FLAG_VOICE_CONNECT
				|| !user || user.clientID != note.toClientID)
				return;
			var remoteStreamName:String = String(note.data);
			if (remoteStreamName)
				manager.connect(remoteStreamName);

		}

		private function roster_updateHandler(e:Event):void
		{
			var enabled:Boolean = roster.size == 2;
			if (dock.hasOwnProperty("enabled"))
			{
				dock["enabled"] = enabled;
			}
			else
			{
				dock.mouseEnabled = enabled;
				dock.mouseChildren = enabled;
			}

		}

		/**
		 *
		 * @inherit
		 */
		public function dispose():void
		{
			dock = null;
			roster.removeEventListener("rosterUpdated", roster_updateHandler);
			chatClient.globalDispatcher.removeEventListener(ChatClientManagerEvent.NOTIFICATION,
				chatClient_notificationHandler);
			roster = null;
			microphone = null;
			manager.dispose();
			chatClient = null;
		}
	}
}