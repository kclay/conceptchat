package com.conceptualideas.text.autocomplete
{
	import flash.events.KeyboardEvent;

	public class BaseAutoCompleteManager
	{

		private var lastAnchorPosition:int = -1

		private var lastResolvedComplete:Vector.<String>
		private var lastResolvedCompleteIndex:int = -1;

		private var lastEndAnchorPosition:int = int.MAX_VALUE

		public function BaseAutoCompleteManager()
		{


		}

		protected function processTab():Boolean
		{

		}

		protected function get text():String
		{
			return "";
		}

		protected function computeAnchorPosition(text:String):int
		{

		}

		protected function keyUpHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.TAB && _dictionary)
			{




				var currentText:String = text;

				var anchorPosition:int = computeAnchorPosition(currentText);
				var endAnchorPosition:int
				var canComplete:Boolean = true;
				if (anchorPosition > -1)
				{
					if (lastAnchorPosition != anchorPosition)
					{

						lastAnchorPosition = anchorPosition;
						endAnchorPosition = currentText.indexOf(" ", anchorPosition);

						if (endAnchorPosition == -1)
						{ // nothing found at the end
							endAnchorPosition = int.MAX_VALUE;
						}
						var partialText:String = currentText.substring(anchorPosition, endAnchorPosition);

						lastEndAnchorPosition = endAnchorPosition;
						var results:Vector.<String> = _dictionary.complete(partialText);
						if (results.length)
						{
							lastResolvedComplete = results;
						}
					}

				}
				else
				{
					canComplete = false;
				}

				if (canComplete && lastResolvedComplete)
				{

					var begin:String = currentText.substr(0, anchorPosition);
					var lastSuggestion:String = lastResolvedCompleteIndex == -1 ? null : lastResolvedComplete[lastResolvedCompleteIndex];

					var tail:String =  currentText.substr(lastEndAnchorPosition);


					lastResolvedCompleteIndex++;
					if (lastResolvedCompleteIndex >= lastResolvedComplete.length)
					{
						lastResolvedCompleteIndex = 0;
					}
					var newSuggestion:String = lastResolvedComplete[lastResolvedCompleteIndex];
					// compose new line, using an array to caculate the new endAnchorPosition for selectRange


					endAnchorPosition = begin.length + newSuggestion.length;
					lastEndAnchorPosition = endAnchorPosition;
					autoCompleteChanged = true;
					text = begin + newSuggestion + tail;
					textDisplay.selectRange(endAnchorPosition, endAnchorPosition);

				}

			}
		}
	}
}