package com.conceptualideas.chat.plugins.admin.events
{
	import flash.events.Event;

	public class BanWindowEvent extends Event
	{

		public static const ADD_BAN:String = "addban";
		public static const CANCEL:String = "cancel"

		public var username:String
		public var banType:int
		public var timelimit:int

		public function BanWindowEvent(type:String, username:String=null, banType:int=0, timelimit:int=-1)
		{
			super(type, false, false);

			this.username = username;
			this.banType = banType;
			this.timelimit = timelimit;
		}
	}
}