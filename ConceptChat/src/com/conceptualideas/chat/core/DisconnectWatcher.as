package com.conceptualideas.chat.core
{
	import com.conceptualideas.chat.events.ChatClientManagerEvent;
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.models.ConnectionInfo;
	
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.utils.Timer;

	internal class DisconnectWatcher
	{

		protected static var dispatchedDisconnected:Boolean

		private var netConnection:NetConnection
		private var connectionInfo:ConnectionInfo

		protected var connectedOnce:Boolean;
		protected var inReconnectMode:Boolean

		private var reconnectDelayTimer:Timer
		private var connectArgs:Array
		private var dispatcher:IEventDispatcher



		public function DisconnectWatcher(dispatcher:IEventDispatcher,
			netConnection:NetConnection,
			connectArgs:Array)
		{
			this.dispatcher = dispatcher;
			this.connectArgs = connectArgs;
			this.netConnection = netConnection;


			netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}

		public function dispose():void
		{
			netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			netConnection = null;

			connectionInfo = null;
			connectArgs = null;
			cleanReconnectDelayTimer()

		}

		protected function cleanReconnectDelayTimer():void
		{
			if (!reconnectDelayTimer)
				return;
			reconnectDelayTimer.stop()
			reconnectDelayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerCompleted);
			reconnectDelayTimer = null;

		}

		private function onTimerCompleted(e:TimerEvent):void
		{
			cleanReconnectDelayTimer()
			reconnect();
		}

		protected function startReconnectDelay():void
		{
			if (!dispatchedDisconnected)
			{
				dispatchedDisconnected = true;
				dispatcher.dispatchEvent(new ChatClientManagerEvent(ChatClientManagerEvent.DISCONNECTED));
			}
			reconnectDelayTimer = new Timer(5000, 1);
			reconnectDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerCompleted);

			reconnectDelayTimer.start();
		}

		protected function reconnect():void
		{

			inReconnectMode = true;
			netConnection.connect.apply(netConnection, connectArgs);
		}

		private function onNetStatus(e:NetStatusEvent):void
		{
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":

					cleanReconnectDelayTimer();
					if (inReconnectMode)
					{
						inReconnectMode = false;

						if (dispatchedDisconnected)
						{
							dispatchedDisconnected = false;
							dispatcher.dispatchEvent(new ChatClientManagerEvent(ChatClientManagerEvent.RE_CONNECTED));
						}



					}
					break;
				case "NetConnection.Connect.Failed":
					if (inReconnectMode)
					{
						startReconnectDelay();
					}
					break;

				case "NetConnection.Connect.Closed":

					if (!inReconnectMode)
					{
						dispatcher.dispatchEvent(new ChatClientManagerEvent(ChatClientManagerEvent.DISCONNECTED))
						startReconnectDelay();
					}
					break;
			}
		}

	}
}