package com.conceptualideas.chat.interfaces
{
	public interface IEmoticonMapper
	{
		function add(text:String, asset:*):void
		function retrive(text:String):*
		function has(text:String):Boolean
		function getMapping():Array
		
	}
}