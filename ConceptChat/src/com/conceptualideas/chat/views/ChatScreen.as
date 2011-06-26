package com.conceptualideas.chat.views
{
	import com.conceptualideas.text.AutoCompleteDictionary;
	import com.conceptualideas.text.IAutoCompleteDictionary;
	import com.conceptualideas.text.IAutoCompleteInput;
	import com.conceptualideas.chat.events.ChatScreenEvent;
	import com.conceptualideas.chat.interfaces.IChatScreen;
	import com.conceptualideas.chat.interfaces.IChatWindow;
	import com.conceptualideas.chat.interfaces.IComposerContext;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.interfaces.IDock;
	import com.conceptualideas.chat.interfaces.IDockable;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.skins.ChatScreenSkin;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	import flashx.textLayout.elements.TextFlow;

	import mx.core.IUIComponent;

	import spark.components.SkinnableContainer;
	import spark.components.TextInput;
	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.TextBase;

	[Style(name="enabledEmoticonIcon", type="Boolean")]
	[SkinState("disabled")]
	public class ChatScreen extends SkinnableComponent implements IChatScreen, IDisposable, IDockable, IAutoCompleteInput
	{

		[SkinPart(required="true")]
		public var textInput:TextInput

		[SkinPart(required="false")]
		public var sendButton:ButtonBase

		[SkinPart(required="false")]
		public var dock:IDock

		[SkinPart(required="true")]
		public var chatWindow:IChatWindow



		protected var messagePreHandler:Function
		protected var messagePostHandler:Function






		protected var chatWindowProperties:Object = {};

		public function ChatScreen()
		{


			super();
			setStyle("skinClass", ChatScreenSkin);

		}

		public function getDock(location:String="default"):IDock
		{
			return dock;
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

		public function get dictionary():IAutoCompleteDictionary
		{
			return textInput && textInput is IAutoCompleteInput ? IAutoCompleteInput(textInput).dictionary : _dictionary;
		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == chatWindow)
			{
				if (chatWindowProperties.composerContext)
					chatWindow.composerContext = chatWindowProperties.composerContext;

				//if(chatWindowProperties.addMessage)
				chatWindowProperties = {};

			}
			else if (instance == textInput)
			{
				textInput.addEventListener(MouseEvent.CLICK, textInput_clickHandler);
				dictionary = _dictionary;
			}
			else if (instance == sendButton)
			{
				sendButton.addEventListener(MouseEvent.CLICK, sendButton_clickHandler);
			}
		}


		private function sendButton_clickHandler(e:MouseEvent):void
		{
			sendMessage();
		}

		private function textInput_clickHandler(e:MouseEvent):void
		{
			focusManager.setFocus(textInput);
		}

		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			if (instance == textInput)
			{
				textInput.removeEventListener(MouseEvent.CLICK, textInput_clickHandler);
			}
			else if (instance == sendButton)
			{
				sendButton.removeEventListener(MouseEvent.CLICK, sendButton_clickHandler);
			}
		}


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

		override protected function createChildren():void
		{
			super.createChildren();

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

		override protected function keyUpHandler(event:KeyboardEvent):void
		{
			super.keyUpHandler(event);

			var comp:IUIComponent = focusManager.getFocus() as IUIComponent;

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
			else
				chatWindowProperties.composerContext = value;
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
			else
			{
				if (!chatWindowProperties.appendText)
					chatWindowProperties.appendText = [];
				chatWindowProperties.appendText.push(text);
			}
		}

		public function addMessage(chatMessage:ChatFieldMessage):void
		{
			if (chatWindow)
			{
				chatWindow.addMessage(chatMessage);
			}
			else
			{
				if (!chatWindowProperties.addMessage)
					chatWindowProperties.addMessage = [];
				chatWindowProperties.addMessage.push(chatMessage);
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

		private function handleEmoticons():void
		{

			dispatchEvent(new Event("showEmoticons"));
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

		override protected function getCurrentSkinState():String
		{
			return enabled ? null : "disabled";
		}
	}
}