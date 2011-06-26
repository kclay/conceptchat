package com.conceptualideas.chat.views
{
	import com.conceptualideas.chat.core.TLFChatField;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.interfaces.IChatWindow;
	import com.conceptualideas.chat.interfaces.IComposerContext;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import flash.display.Sprite;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class SimpleAbstractChatWindow extends Sprite implements IDisposable, IChatWindow
	{

		private var chatField:TLFChatField


		private var _composerContext:IComposerContext

		private var controller:ContainerController

		public function SimpleAbstractChatWindow()
		{

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

		public function get textInput():Object
		{
			if (textDisplay)
				return textDisplay.textFlow;
			return null;
		}
		public function addMessage(message:ChatFieldMessage):void
		{



			if (!fromColor)

			{
				var colorString:String = "FFFFFF";
				if (!isNaN(getStyle("fromColor")))
				{
					colorString = Number(getStyle("fromColor")).toString(16);
				}
				fromColor = "0x" + colorString;
				colorString = "FFFFFF";
				if (!isNaN(getStyle("messageColor")))
				{
					colorString = Number(getStyle("messageColor")).toString(16);
				}
				messageColor = "0x" + colorString;
				fontSize = getStyle("fontSize");
			}
			if (useSameColors)
			{
				message.fromColor = fromColor;
				message.messageColor = messageColor;
			}

			chatField.addLine(message);


			controller.verticalScrollPosition = controller.getContentBounds().height + 5;

		}

		public function clear():void
		{
			chatField.clear();
		}

		public function dispose():void
		{

			_composerContext = null;

			controller = null;
			if (chatField)
				chatField.dispose();
			chatField = null;
		}

	}

}