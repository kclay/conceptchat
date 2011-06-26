package com.conceptualideas.chat.operations
{
	import com.conceptualideas.chat.edit.ExtendedTextClipboard;
	
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.edit.TextScrap;
	import flashx.textLayout.operations.CopyOperation;
	
	public class ExtendedCopyOperation extends CopyOperation
	{
		public function ExtendedCopyOperation(operationState:SelectionState)
		{
			super(operationState);
			
		}
		override public function doOperation():Boolean{
			if (originalSelectionState.activePosition != originalSelectionState.anchorPosition)
				ExtendedTextClipboard.setContents(TextScrap.createTextScrap(originalSelectionState));		
			return true;
		}
	}
}