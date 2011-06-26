package com.conceptualideas.chat.views
{
	import com.conceptualideas.chat.core.CIChatField;
	import com.conceptualideas.chat.interfaces.IChatWindow;
	import com.conceptualideas.chat.interfaces.IComposerContext;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.utils.TextFlowScrollWatcher;

	import flash.display.DisplayObject;

	import flashx.textLayout.elements.TextFlow;

	public class ChatWindowBase implements IChatWindow
	{
		private var chatField:CIChatField


		private var _composerContext:IComposerContext

		private var _emoticons:IEmoticonMapper
		private var host:DisplayObject
		private var _scroller:Object

		private var _created:Boolean


		private var _height:Number = 0
		private var _width:Number = 0

		public function ChatWindowBase(host:DisplayObject, scoller:Object=null)
		{
			this.host = host;
			this._scoller = scoller;


		}

		public function set scoller(value:Object):void
		{
			
			_scroller = value;
			if (chatField)
				textFlowScrollWatcher = new TextFlowScrollWatcher(value, chatField.getTextFlow())
		}

		private function get scroller():Object
		{
			return _scroller;
		}

		public function set width(value:Number):void
		{
			if (_width == value)
				return;
			_width = value;
			if (chatField)
				chatField.setSize(_width, _height);
		}

		public function get width():Number
		{
			return _width;
		}

		public function set height(value:Number):void
		{
			if (_height == value)
				return;

			_height = value;
			if (chatField)
				chatField.setSize(_width, _height);
		}

		private function get height():void
		{
			return _height;
		}


		public function init():void
		{
			if (_created)
				return;
			var chatOptions:ChatFieldsOptions = new ChatFieldsOptions();

			//chatOptions.fontSize = textDisplay.textFlow.format.fontSize;

			//setStyle("horizontalScrollPolicy", "none");
			//setStyle("verticalScrollPolicy", "auto");
			chatField = new CIChatField(host, width, height, chatOptions);

			if (_composerContext)
				chatField.composerContext = _composerContext;

			if (_scroller)
				scoller = _scroller;

			_created = true;

		}

		public function addMessage(message:ChatFieldMessage):void
		{

			if (chatField)
				chatField.addLine(message);


			//	controller.verticalScrollPosition = controller.getContentBounds().height + 5;

			//textDisplay.verticalScrollPosition=textDisplay.verticalScrollPosition+5;
			//textFlowScrollWatcher.setForceDown(true);
		}

		public function get textInput():TextFlow
		{

			return chatField ? chatField.getTextFlow() : null;
		}

		public function set composerContext(value:IComposerContext):void
		{
			_composerContext = value;
			if (chatField)
				chatField.composerContext = value;
		}

		public function get composerContext():IComposerContext
		{
			return _composerContext;
		}

		public function clear():void
		{
			chatField.clear();
		}
	}
}