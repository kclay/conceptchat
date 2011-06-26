package com.conceptualideas.chat.views
{
	import com.conceptualideas.chat.interfaces.IChatWindow;
	import com.conceptualideas.chat.interfaces.IComposerContext;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	
	import mx.controls.TextArea;

	public class HTMLChatWindow extends TextArea implements IDisposable, IChatWindow
	{
		private var _composerContext:IComposerContext
		public function HTMLChatWindow()
		{
			super();
		}

		public function clear():void
		{
			htmlText="";
			
			
		}

		public function set composerContext(value:IComposerContext):void
		{
			_composerContext = value;
		
		}
		
		public function get textInput():Object{
			return this;
		}
		public function get composerContext():IComposerContext
		{
			return _composerContext;
		}
		public function addMessage(message:ChatFieldMessage):void{
			
			if(_composerContext){
				var html:String = String(_composerContext.compose(message));
				htmlText+=html+"\n";
			}
		}
		public function dispose():void
		{

		}
	}
}