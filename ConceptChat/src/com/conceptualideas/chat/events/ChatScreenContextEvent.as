package com.conceptualideas.chat.events
{
	import com.conceptualideas.chat.models.ChatFieldMessage;

	import flash.events.Event;

	public class ChatScreenContextEvent extends Event
	{

		public static const SEND_MESSAGE:String = "screenContextSendMessage";
		public static const MESSAGE_RECIEVED:String = "screenContextMessageRecieved";
		public static const MESSAGE_ADDED:String = "screenContextMessageAdded";
		
		public var chatMessage:ChatFieldMessage


		public function ChatScreenContextEvent(type:String, bubbles:Boolean=false,
			cancelable:Boolean=false, chatMessage:ChatFieldMessage=null)
		{
			this.chatMessage = chatMessage;
			super(type, bubbles, cancelable);
		}

		override public function clone():Event
		{
			return new ChatScreenContextEvent(type, bubbles, cancelable, chatMessage);
		}

	}
}