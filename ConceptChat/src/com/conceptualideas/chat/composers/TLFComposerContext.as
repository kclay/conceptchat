package com.conceptualideas.chat.composers
{
	import com.conceptualideas.chat.composers.composerClasses.ComposeFormats;
	import com.conceptualideas.chat.composers.composerClasses.ContainerComposer;
	import com.conceptualideas.chat.composers.composerClasses.MessageComposer;
	import com.conceptualideas.chat.composers.composerClasses.StampComposer;
	import com.conceptualideas.chat.filters.FilterTypes;
	import com.conceptualideas.chat.filters.StripBadsFilter;
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IComposer;
	import com.conceptualideas.chat.interfaces.IComposerContext;
	import com.conceptualideas.chat.interfaces.IComposerFilter;
	import com.conceptualideas.chat.models.ChatFieldMessage;

	import flash.utils.Dictionary;

	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.TextFlow;


	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class TLFComposerContext implements IComposerContext
	{



		public function TLFComposerContext(chatContext:IChatContext=null)
		{
			_chatContext = chatContext;
			init();

		}
		private var _stampComposer:IComposer = new StampComposer();

		/**
		 * @inheritDoc
		 * */
		public function get stampComposer():IComposer
		{
			return _stampComposer;
		}

		/**
		 * @inheritDoc
		 * */
		public function set stampComposer(value:IComposer):void
		{
			_stampComposer = value;
			_stampComposer.context = this;
		}
		private var _messageComposer:IComposer = new MessageComposer();
		protected var containerComposer:ContainerComposer = new ContainerComposer();
		private var composingSelfMessage:Boolean;

		private var importer:ITextImporter

		protected var filters:Dictionary = new Dictionary();

		protected var textFlow:TextFlow

		private var _chatContext:IChatContext


		public function get chatContext():IChatContext
		{
			return _chatContext;
		}

		public function set chatContext(value:IChatContext):void
		{
			_chatContext = value;
		}




		public function newComposer(clazz:Class):IComposer
		{
			var composer:IComposer;
			try
			{
				composer = new clazz();
				composer.context = this;
			}
			catch (e:Error)
			{
				composer = null;
			}
			return composer;
		}

		private function init():void
		{

			createFilter(FilterTypes.INIT);
			createFilter(FilterTypes.POST_STAMP);
			createFilter(FilterTypes.POST_MESSAGE);
			createFilter(FilterTypes.POST_TEXT_FLOW);
			addFilter(new StripBadsFilter(), FilterTypes.INIT, Number.MAX_VALUE);
		}

		private function createFilter(type:String):void
		{
			filters[type] = new Vector.<IComposerFilter>();
		}

		public function addFilter(filter:IComposerFilter, type:String, priority:int=0):void
		{
			// TODO : Implement priority filtering
			filters[type].push(filter);
		}



		public function set config(v:IConfiguration):void
		{

			importer = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT, v);
		}

		public function get messageComposer():IComposer
		{
			return _messageComposer;
		}

		public function set messageComposer(value:IComposer):void
		{
			_messageComposer = value;
		}


		protected function prep(message:String):String
		{
			if (message.indexOf("/me") === 0)
			{
				composingSelfMessage = true;

				return message.replace("/me", "");
			}
			return message;
		}

		/**
		 * Composes a FlowElement for a given ChatFieldMessage
		 * */
		public function compose(chatMessage:ChatFieldMessage):Object
		{


			var markup:String


			var composeFormat:String = composingSelfMessage ? ComposeFormats.SELF : chatMessage.isSystemMessage ? ComposeFormats.SYSTEM : ComposeFormats.DEFAULT;

			chatMessage = runFilter(FilterTypes.INIT, chatMessage);

			markup = composeStamp(chatMessage);
			markup += composeMessage(chatMessage);

			markup = composeContainer(chatMessage, markup);

			textFlow = importer.importToFlow(markup);

			if (importer.errors)
			{
				for each (var error:String in importer.errors)
				{
					trace("addLine:: Error", error);

				}
				return null;
			}
			//composingSelfMessage = false;
			return textFlow.getElementByID('container').deepCopy();




		}


		protected function composeStamp(chatMessage:ChatFieldMessage):String
		{
			var markup:String = "";
			if (stampComposer)
				markup = stampComposer.compose(chatMessage);
			return markup;
		}

		protected function composeMessage(chatMessage:ChatFieldMessage):String
		{

			return (messageComposer) ? messageComposer.compose(chatMessage) : "";
		}

		protected function composeContainer(chatMessage:ChatFieldMessage, markup:String):String
		{
			var tokens:Object = chatMessage.toObject();

			tokens.message = markup.replace(/\n/g, "<flow:br/>"); // add line breaks
			containerComposer.tokens = tokens;
			return containerComposer.compose(markup);
		}

		public function runFilter(type:String, content:*):*
		{
			const composerFilters:Vector.<IComposerFilter> = filters[type];
			if (!composerFilters.length)
				return content;
			var composerFilter:IComposerFilter
			for each (composerFilter in composerFilters)
			{
				content = composerFilter.filter(content);
			}
			return content;

		}







	}

}