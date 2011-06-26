package com.conceptualideas.chat.views
{
	import com.conceptualideas.chat.events.ChatScreenEvent;
	import com.conceptualideas.chat.interfaces.IChatScreen;
	import com.conceptualideas.chat.interfaces.IChatWindow;
	import com.conceptualideas.chat.interfaces.IComposerContext;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.interfaces.IDockable;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.text.AutoCompleteDictionary;
	import com.conceptualideas.text.IAutoCompleteDictionary;
	import com.conceptualideas.text.IAutoCompleteInput;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class SimpleAbstractChatScreen extends Sprite implements IChatScreen, IDisposable, IDockable, IAutoCompleteInput
	{

		protected var textInput:Object
		protected var chatWindow:IChatWindow
		public function SimpleAbstractChatScreen()
		{
			createChildren();

		}
		private var _dictionary:IAutoCompleteDictionary = new AutoCompleteDictionary();

		public function set dictionary(value:IAutoCompleteDictionary):void
		{
			if (textInput && textInput is IAutoCompleteInput)
			{
				IAutoCompleteInput(textInput).dictionary = value;
				_dictionary = null
			}
			else
			{
				_dictionary = value;
			}


		}
		protected var messagePreHandler:Function
		protected var messagePostHandler:Function
		private var history:Vector.<String> = new Vector.<String>();

		private var historyIndex:int = -1;

		private var _maxHistoryLength:int = 20;

		public function set maxHistoryLength(value:int):void
		{
			_maxHistoryLength = value;
			addHistory();

		}


		protected function addHistory(text:String=null):void
		{
			historyIndex = history.push(text);

			var diff:int = clamp(history.length - _maxHistoryLength, 0, history.length);
			if (diff)
				history.splice(0, diff);

		}

		private function truncateHistory():void
		{

		}

		protected function createChildren():void
		{


			if (!hasEventListener(KeyboardEvent.KEY_UP))
				addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false);

		}



		public function setHandlers(messagePreHandler:Function, messagePostHandler:Function):void
		{
			this.messagePreHandler = messagePreHandler;
			this.messagePostHandler = messagePostHandler;
		}

		public function clear():void
		{
			if (chatWindow)
				chatWindow.clear();

		}

		public function get textInputObject():Object
		{
			if (chatWindow)
				return chatWindow.textInput;
			return null;

		}

		protected function keyUpHandler(event:KeyboardEvent):void
		{



			var comp:InteractiveObject = stage.focus

			var inputHasFocus:Boolean = comp == textInput;
			if (!inputHasFocus)
				return;
			if (event.keyCode == Keyboard.ENTER)
			{
				sendMessage();
			}
			else if ((event.keyCode == Keyboard.UP || event.keyCode == Keyboard.DOWN) && historyIndex != -1)
			{
				historyIndex += event.keyCode == Keyboard.UP ? 1 : -1;
				historyIndex = clamp(historyIndex, 0, history.length - 1);

				textInput.text = history[historyIndex];
				var len:int = history[historyIndex].length;
				textInput.selectRange(len, len);

			}
		}


		private function clamp(val:Number, min:int, max:int):int
		{

			return Math.max(min, Math.min(max, val));

		}

		public function set composerContext(value:IComposerContext):void
		{
			if (chatWindow)
				chatWindow.composerContext = value;

		}

		public function get composerContext():IComposerContext
		{
			if (!chatWindow)
				return null;
			return chatWindow.composerContext;
		}



		public function appendText(text:String):void
		{
			if (textInput)
			{
				textInput.appendText(text);
			}

		}

		public function addMessage(chatMessage:ChatFieldMessage):void
		{
			if (chatWindow)
			{
				chatWindow.addMessage(chatMessage);
			}


		}

		public function dispatchMessage(message:String):Boolean
		{


			if (hasEventListener(ChatScreenEvent.PRE_SEND_MESSAGE))
				if (!dispatchEvent(new ChatScreenEvent(ChatScreenEvent.PRE_SEND_MESSAGE, true, true)))
					return false;
			if (messagePreHandler != null)
				message = messagePreHandler(message);
			if (message == "")
				return false;

			var chatMessage:ChatFieldMessage = new ChatFieldMessage();
			chatMessage.message = message;
			if (messagePostHandler != null)
				messagePostHandler(chatMessage);

			return true;

		}

		private function sendMessage():void
		{
			var text:String = textInput.text;
			if (dispatchMessage(text))
			{
				addHistory(text);

				textInput.text = ""
			}


		}
		public function dispose():void
		{
			removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false);
			messagePreHandler = null;
			messagePostHandler = null;
			if (chatWindow && chatWindow is IDisposable)
			{

				IDisposable(chatWindow).dispose();
			}
			history = null;
			chatWindowProperties = null
		}
		public function resize(width:Number, height:Number):void
		{

		}


	}

}