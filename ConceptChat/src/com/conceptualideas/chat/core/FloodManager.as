package com.conceptualideas.chat.core
{

	import com.conceptualideas.chat.models.ChatFieldMessage;


	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class FloodManager
	{

		private var lastMessage:String = null;
		private var maxWords:int;
		private var occuranceCount:int;
		private var maxWordLength:int = 30;

		public function FloodManager(maxWords:int=100, occuranceCount:int=4)
		{
			this.maxWords = maxWords || 100;
			this.occuranceCount = occuranceCount;
		}

		public function isFlood(chatMessage:ChatFieldMessage):Boolean
		{

			var message:String = chatMessage.message;
			if (message.indexOf("/") == 0)
				return false;
			var words:Vector.<String> = Vector.<String>(message.split(" "));
			if (words.length > maxWords ||
				lastMessage == message ||
				isOverOccurance(message) /*||
				 words.filter(filterByMaxWordLength).length*/)
			{

				return true;
			}
			lastMessage = message;
			return false;

		}

		private function filterByMaxWordLength(word:String, index:int, vec:Vector.<String>):Boolean
		{
			return (word.length >= 20) ? true : false;
		}

		private function isOverOccurance(str:String):Boolean
		{
			var words:Vector.<String> = Vector.<String>(str.split(" "));
			var lookup:Object = {};
			var word:String
			while (word = words.pop())
			{
				if (!lookup[word])
					lookup[word] = 0;
				lookup[word]++;
				if (lookup[word] > occuranceCount)
					return true;
			}
			return false;
		}



	}

}