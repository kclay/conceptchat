package com.conceptualideas.chat.core
{

	import com.conceptualideas.chat.interfaces.IEmoticonMapper;
	import com.conceptualideas.chat.interfaces.IInjector;

	import flash.utils.Dictionary;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class EmoticonMapper implements IEmoticonMapper, IInjector
	{

		private var dict:Dictionary = new Dictionary(true);


		public function EmoticonMapper()
		{

		}

		public function add(text:String, asset:*):void
		{
			dict[text] = asset;
		}

		public function retrive(text:String):*
		{

			return dict[text] || null;
		}

		public function has(text:String):Boolean
		{

			return (dict[text] != undefined) ? true : false;
		}

		public function getMapping():Array
		{
			var emoticons:Array = [];
			var text:String
			for (text in dict)
			{
				emoticons[emoticons.length] = {text:text, image:dict[text], name:""};
			}
			return emoticons;
		}

		/* INTERFACE com.conceptualideas.chat.interfaces.IInjector */

		public function inject(context:Object):void
		{
			var xml:XML = context as XML;
			for each (var emot:XML in xml.emoticons.children())
			{

				add(String(emot.emot), String(emot.url));
			}
		}

	}

}