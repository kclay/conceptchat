package com.conceptualideas.chat.models {

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class ConnectionInfo{
			
		public var chatRoom:String
		public var userInfo:ChatUser = new ChatUser();
		public var request:PrivateMessageRequest
		public function ConnectionInfo() {
			
		}
		
	}

}