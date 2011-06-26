package com.conceptualideas.chat.plugins.tab
{
	import flash.display.DisplayObject;

	public interface ITabProxy
	{
		
		function getTabAt(index:int):DisplayObject
		function getTabContentAt(index:int):DisplayObject
		
	}
}