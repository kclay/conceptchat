package com.conceptualideas.text
{
	import com.conceptualideas.chat.events.AutoCompleteDictionaryEvent;

	import flash.events.EventDispatcher;

	public class AutoCompleteDictionary extends EventDispatcher implements IAutoCompleteDictionary
	{

		private var words:Vector.<String>
		private var lowerCase:Vector.<String>

		private var doDispatchEvents:Boolean = true;

		public function AutoCompleteDictionary()
		{
			words = new Vector.<String>();
			lowerCase = new Vector.<String>();
		}

		public function add(word:String):void
		{

			if (lowerCase.indexOf(word.toLowerCase()) == -1)
			{
				words.push(word)
				words.sort(Array.CASEINSENSITIVE);
				lowerCase.push(word.toLowerCase());
				lowerCase.sort(Array.CASEINSENSITIVE);
			}
			if (doDispatchEvents)
				internalDispatch(AutoCompleteDictionaryEvent.UPDATED)
		}

		public function addAll(words:Vector.<String>):void
		{
			doDispatchEvents = false;

			for each(var word:String in words)
			{
				add(word);
			}
			doDispatchEvents = true;
			internalDispatch(AutoCompleteDictionaryEvent.UPDATED);

		}

		private function internalDispatch(event:String):void
		{
			if (hasEventListener(event))
				dispatchEvent(new AutoCompleteDictionaryEvent(event));
		}

		public function clear():void
		{
			words.length = 0;
			lowerCase.length = 0;
		}



		public function complete(fragment:String):Vector.<String>
		{
			var currentComplete:Vector.<String> = new Vector.<String>;
			if (words)
			{

				// TODO : look into a binary search on first letter
				fragment = fragment.toLowerCase();
				var len:int = lowerCase.length;
				var word:String
				var found:Boolean
				for (var i:int = 0; i < len; i++)
				{
					word = lowerCase[i];
					if (word.indexOf(fragment) == 0)
					{
						found = true;
						currentComplete.push(words[i]);
					}
					else if (found)
					{
						break;
					}


				}


			}
			return currentComplete;
		}

	}
}