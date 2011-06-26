package com.conceptualideas.chat.models
{

	public class PrivateMessageRequest
	{
		public var fromClientID:String
		public var toClientID:String
		public var chatMessage:ChatFieldMessage
		public var chatRoomName:String

		public function PrivateMessageRequest(fromClientID:String=null, toClientID:String=null)
		{
			this.fromClientID = fromClientID;
			this.toClientID = toClientID;
			this.chatRoomName = ["private", fromClientID, toClientID].join("-");
		}
	}
}