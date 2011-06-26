package com.conceptualideas.chat.interfaces
{


	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public interface IDock
	{
		function add(name:String, component:Sprite, callback:Function=null):void
		function remove(name:String):DisplayObject
		function retrive(name:String):DisplayObject



	}
}