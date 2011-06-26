package com.conceptualideas.chat.models
{

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class ChatUser
	{
		public var name:String
		public var ip:String
		public var clientID:String
		public var type:uint
		public var UUID:String
		public var avatar:String
		public var gender:String

		public function ChatUser()
		{

		}

		public function toObject():Object
		{
			return {
					gender:gender,
					name:name,
					ip:ip,
					clientID:clientID,
					type:type,
					UUID:UUID,
					avatar:avatar
				}
		}

	}

}