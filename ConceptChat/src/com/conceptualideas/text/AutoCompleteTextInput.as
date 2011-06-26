package com.conceptualideas.text
{
	import com.conceptualideas.chat.events.AutoCompleteDictionaryEvent;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import flashx.textLayout.edit.ISelectionManager;

	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;

	import spark.components.TextInput;

	public class AutoCompleteTextInput extends TextInput implements IAutoCompleteInput
	{
		public function AutoCompleteTextInput()
		{
			super();
			_dictionary = new AutoCompleteDictionary();

		}




		private var _dictionary:IAutoCompleteDictionary

		public function set dictionary(value:IAutoCompleteDictionary):void
		{
			if (_dictionary)
			{
				_dictionary.removeEventListener(AutoCompleteDictionaryEvent.UPDATED, dictionary_updatedHandler);
			}
			_dictionary = value;
			if (value)
				value.addEventListener(AutoCompleteDictionaryEvent.UPDATED, dictionary_updatedHandler, false, 0, true);

		}

		private function dictionary_updatedHandler(e:AutoCompleteDictionaryEvent):void
		{
			lastAnchorPosition = -1;
			lastResolvedComplete = null;
			lastEndAnchorPosition = int.MAX_VALUE;
			lastResolvedCompleteIndex = -1;

		}

		public function get dictionary():IAutoCompleteDictionary
		{
			return _dictionary
		}


		private var lastAnchorPosition:int = -1

		private var lastResolvedComplete:Vector.<String>
		private var lastResolvedCompleteIndex:int = -1;

		private var lastEndAnchorPosition:int = int.MAX_VALUE



		private function get activePosition():int
		{
			return textDisplay ? textDisplay.selectionActivePosition : -1;

		}

		private function computeAnchorPosition(currentText:String):int
		{



			var anchorPosition:int = selectionActivePosition
			var textLength:int = text.length;
			// make sure that the current selection position is of space

			if (anchorPosition != textLength && currentText.charAt(anchorPosition) != " ")
				return -1;
			while (--anchorPosition > 0)
			{
				if (currentText.charAt(anchorPosition) == " ")
					break;

			}

			return anchorPosition ? anchorPosition + 1 : 0;
		}


		private var autoCompleteChanged:Boolean

		override protected function keyUpHandler(event:KeyboardEvent):void
		{
			if (focusManager && focusManager.getFocus() == this
				&& event.keyCode == Keyboard.TAB && _dictionary)
			{


				var currentText:String = this.text;

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
						
						lastResolvedComplete = _dictionary.complete(partialText);
						
					}

				}
				else
				{
					canComplete = false;
				}

				if (canComplete && lastResolvedComplete)
				{

					var begin:String = currentText.substr(0, anchorPosition);
					var lastSuggestion:String = lastResolvedCompleteIndex == -1 ? null :
						lastResolvedComplete && lastResolvedComplete.length ? lastResolvedComplete[lastResolvedCompleteIndex] :""

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

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (focusManager && autoCompleteChanged)
			{
				autoCompleteChanged = true;
				focusManager.showFocus();

			}
		}



	}
}