package com.conceptualideas.chat.core
{
	import com.conceptualideas.chat.interfaces.IChatScreen;

	public class ChatScreenFactory
	{
		public function ChatScreenFactory()
		{
		}

		public function create(room:String, createRequest:Boolean=true):IChatScreen
		{

		}


		public function createPrivateChat(request:PrivateMessageRequest):IChatScreen
		{
			
		}

		public function sendPrivateMessageRequest(request:PrivateMessageRequest):IChatScreen
		{

		}


	}
}