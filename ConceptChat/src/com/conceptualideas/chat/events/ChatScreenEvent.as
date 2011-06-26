package com.conceptualideas.chat.events
{
	import com.conceptualideas.chat.models.ChatFieldMessage;
	
	import flash.events.Event;
	
	public class ChatScreenEvent extends Event
	{
		public static const PRE_SEND_MESSAGE:String="preSendMessage"
		private var _message:ChatFieldMessage
		public function ChatScreenEvent(type:String, 
										bubbles:Boolean=false, 
										cancelable:Boolean=false,message:ChatFieldMessage=null)
		{
			super(type, bubbles, cancelable);
			_message = message;
		}
	}
}