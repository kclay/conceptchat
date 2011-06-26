package com.conceptualideas.chat.utils
{

	public class HTMLTools
	{
		public static const LINK_REGX:RegExp =  /\"?([^\"]+\"?:)?((?:http|ftp|https):\/\/)([a-z0-9_\?\.\-\,\'\/\\\+&%\$#\=~]*)/gi
			//new RegExp("\"?([^\"]+\"?:)?((?:http|ftp|https)://)([\\w-]+.[\\w-]+)([a-z0-9_\?\.\-\,\'/\\+&%\$#\=~]*)", "ig");

		public function HTMLTools()
		{
		}
	}
}