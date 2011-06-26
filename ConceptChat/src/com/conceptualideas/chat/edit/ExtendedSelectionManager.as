package com.conceptualideas.chat.edit
{
	import com.conceptualideas.chat.operations.ExtendedCopyOperation;
	
	import flash.events.Event;
	
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.undo.IUndoManager;
	
	public class ExtendedSelectionManager extends SelectionManager
	{
		public function ExtendedSelectionManager()
		{
			super();
		}
		/** 
		 * @copy IInteractionEventHandler#editHandler()
		 *  We inject our custom ExtendedCopyOperation
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */	
		override public function editHandler(event:Event):void{
			switch(event.type){
				case Event.COPY:
					flushPendingOperations();
					
					doOperation(new ExtendedCopyOperation(getSelectionState()));
					break;
				default:
					super.editHandler(event);
			}
		}
		
	}
}