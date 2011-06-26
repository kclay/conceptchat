package com.conceptualideas.chat.views
{
	import com.conceptualideas.chat.core.TLFChatField;
	import com.conceptualideas.chat.interfaces.IChatWindow;
	import com.conceptualideas.chat.interfaces.IComposerContext;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.interfaces.IEmoticonMapper;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.models.ChatFieldsOptions;

	import flashx.textLayout.container.ContainerController;

	import spark.components.TextArea;


	[Style(name="fromColor", type="Number", format="Color", inherit="no")]
	[Style(name="messageColor", type="Number", format="Color", inherit="no")]
	[Style(name="showDateTime", type="Boolean")]
	[Style(name="useSameColors", type="Boolean")]
	public class TLFChatWindow extends TextArea implements IDisposable, IChatWindow
	{

		private var chatField:TLFChatField


		private var _composerContext:IComposerContext

		private var _emoticons:IEmoticonMapper

		private var fontSize:Number
		private var messageColor:String
		private var fromColor:String

		private var useSameColors:Boolean = true;

		private var forceDownNeeded:Boolean = false;




		private var controller:ContainerController

		public function TLFChatWindow()
		{

			super();
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

		override protected function createChildren():void
		{
			super.createChildren()
			var chatOptions:ChatFieldsOptions = new ChatFieldsOptions();

			//chatOptions.fontSize = textDisplay.textFlow.format.fontSize;

			setStyle("horizontalScrollPolicy", "none");
			setStyle("verticalScrollPolicy", "auto");

			chatField = new TLFChatField(textDisplay, width, height, chatOptions);
			chatField.setTextFlow(textDisplay.textFlow);

			if (_composerContext)
				chatField.composerContext = _composerContext;

			controller = textFlow.flowComposer.getControllerAt(0);

			//textFlow.interactionManager.
			textDisplay.mouseChildren = true;

			useSameColors = Boolean(getStyle("useSameColors"));

			//trace(textFlow.interactionManager);

			//	textFlowScrollWatcher = new TextFlowScrollWatcher(scroller.verticalScrollBar, chatField.getTextFlow())

			//	mapper.add(":D","beer.gif");
			//chatField.emoticons = mapper;
		/*super.createChildren();
		   chatView = new UIComponent();
		   chatView.percentHeight=100;
		   chatView.percentWidth=100;
		   addElement(chatView)

		   scrollBar = new ChatWindowScrollBar();
		   addElement(scrollBar)

		   scrollBar.visible = false;

		   var chatOptions:ChatFieldsOptions = new ChatFieldsOptions();

		   chatField = new CIChatField(chatView, width, height, chatOptions);


		 */
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
			//message.fromSize = fontSize;
			//message.messageSize = fontSize;
			chatField.addLine(message);


			controller.verticalScrollPosition = controller.getContentBounds().height + 5;

			//textDisplay.verticalScrollPosition=textDisplay.verticalScrollPosition+5;
			//textFlowScrollWatcher.setForceDown(true);
		}

		public function clear():void
		{
			chatField.clear();
		}

		public function dispose():void
		{

			_composerContext = null;
			_emoticons = null;
			controller = null;
			if (chatField)
				chatField.dispose();
			chatField = null;
		}
	}
}