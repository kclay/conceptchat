package com.conceptualideas.text.autocomplete
{
	import com.conceptualideas.chat.plugins.media.BaseMediaManager;

	import flash.events.KeyboardEvent;
	import flash.net.NetConnection;

	import flashx.textLayout.elements.TextFlow;

	public class TLFAutoCompleteManager extends BaseAutoCompleteManager
	{
		private var textFlow:TextFlow


		public function TLFAutoCompleteManager(netConnection:NetConnection)
		{
			super(netConnection);
		}

		override protected function computeAnchorPosition(text:String):int
		{
			var anchorPosition:int = textFlow.selectionActivePosition
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

		protected function keyUpHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.TAB && _dictionary)
			{

			}
		}

	}
}