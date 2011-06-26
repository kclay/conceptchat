package com.conceptualideas.chat.plugins.style
{

	public interface IStyleManagerPlugin
	{

		function getStyle(styleProp:String):*
		function setStyle(styleProp:String, value:*):void
	}
}