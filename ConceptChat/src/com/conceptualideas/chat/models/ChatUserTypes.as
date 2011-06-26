package com.conceptualideas.chat.models
{

	public class ChatUserTypes
	{
		public static const ADMIN:uint = 1 << 0;
		public static const MODEL:uint = ADMIN << 1;
		public static const REGISTERED_USER:uint = MODEL << 1;
		public static const GUEST:uint = REGISTERED_USER << 1;

	}
}