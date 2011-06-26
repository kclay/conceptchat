package com.conceptualideas.chat.plugins.room
{
	public class RoomFlags
	{
		public static const NOTIFY_FLAG:String = "room::";
		public static const NOTIFY_INVITE_FLAG:String = NOTIFY_FLAG + "invite";
		public static const NOTIFY_BOOT_FLAG:String = NOTIFY_FLAG + "boot";
		public function RoomFlags()
		{
		}
	}
}