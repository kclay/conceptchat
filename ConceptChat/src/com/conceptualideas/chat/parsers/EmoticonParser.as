package com.conceptualideas.chat.parsers
{
	import com.conceptualideas.chat.interfaces.IParser;
	import com.conceptualideas.chat.interfaces.IEmoticonMapper;

	public class EmoticonParser implements IParser
	{
		private var _mapper:IEmoticonMapper

		public function get name():String{
			return "emoticon";
		}
		public function EmoticonParser()
		{
			
		}

		public function set mapper(value:IEmoticonMapper):void
		{
			_mapper = value;
		}
		public function get mapper():IEmoticonMapper{
			return _mapper;
		}

		public function set emoticonWeightSize(value:*):void
		{
			_emoticonWeightSize = value;
		}

		public function set emoticonHeightSize(value:*):void
		{
			_emoticonHeightSize = value;
		}

		public function set emoticonShift(value:Number):void
		{
			_emoticonShift = value;
		}
		public function parse(raw:String):String
		{
			if (!_mapper)
				return raw;
			return raw.replace(EMOTICON_REGX, replaceEmoticonCallback);
		}

		private function replaceEmoticonCallback(emoticon:String, offset:int, index:int, string:String, somthing:Object=null):String
		{

			if (_mapper.has(emoticon))
			{

				return '<flow:img height="' + _emoticonHeightSize + '" width="' + _emoticonWeightSize + '" source="' + _mapper.retrive(emoticon) + '" float="none" id="'+emoticon+'"/>'
			}
			return emoticon;
		}

		private const EMOTICON_REGX:RegExp = /lol|(:[A-Za-z]+:)|([:;8][',"=-]?-?(?:[sSdDpPcCoO#@*$\|]|\)\)?|\(\(?)=?)/g
		private var _emoticonWeightSize:* = "auto"
		private var _emoticonHeightSize:* = "auto";
		private var _emoticonShift:Number = 0;
	}
}