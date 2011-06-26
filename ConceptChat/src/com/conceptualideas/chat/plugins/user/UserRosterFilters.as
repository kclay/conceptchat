package com.conceptualideas.chat.plugins.user
{

	public class UserRosterFilters
	{
		public static const REGISTERED_ONLY:uint = 1 << 0;
		public static const NAMES_ONLY:uint  = REGISTERED_ONLY << 1;
		public static const NAME_AND_GENDER_ONLY:uint = NAMES_ONLY << 1;

	
	}
}