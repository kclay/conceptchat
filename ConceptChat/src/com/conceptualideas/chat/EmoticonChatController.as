package com.conceptualideas.chat
{
	import com.conceptualideas.chat.events.EmoticonBrowserEvent;
	import com.conceptualideas.chat.interfaces.IChatClient;
	import com.conceptualideas.chat.interfaces.IChatScreen;
	import com.conceptualideas.chat.interfaces.IComposer;
	import com.conceptualideas.chat.models.ChatSettings;
	import com.conceptualideas.chat.parsers.EmoticonParser;
	import com.conceptualideas.chat.views.EmoticonBrowser;
	
	import flash.events.Event;

	public class EmoticonChatController extends BasicChatController
	{
		private var _emoticonFirstUse:Boolean = true;

		private var emoticonBrowser:EmoticonBrowser

		private var hasEmoticons:Boolean



		public function EmoticonChatController(chatScreen:IChatScreen, chatSettings:ChatSettings)
		{
			super(chatScreen, chatSettings);
		}

		override protected function init():void
		{
			Object(chatScreen).includeEmoticons = true;
			emoticonBrowser = new EmoticonBrowser();
			emoticonBrowser.width = chatSettings.browserWidth
			emoticonBrowser.height = chatSettings.browserHeight;

			emoticonBrowser.addEventListener(EmoticonBrowserEvent.SELECTED, emoticon_selectedHandler)
			//emoticonBrowser.sh

			super.init();

		}

		override protected function setupChatClient(roomName:String,client:IChatClient,screen:IChatScreen, title:String=null):void
		{
			super.setupChatClient(roomName,client, screen, title);
			screen.addEventListener("showEmoticons", onEmoticonRequest);
		}

		private function emoticon_selectedHandler(e:EmoticonBrowserEvent):void
		{
			chatScreen.appendText(e.selected);
		}

		private function onEmoticonRequest(e:Event):void
		{

			var activeScreen:IChatScreen = e.target as IChatScreen;
			if (_emoticonFirstUse)
			{
				var composer:IComposer = activeScreen.composerContext.messageComposer;

				var parser:EmoticonParser = composer.getParser(EmoticonParser) as EmoticonParser;
				if (parser)
				{
					emoticonBrowser.emoticons = parser.mapper.getMapping();
					hasEmoticons = true;
				}
				_emoticonFirstUse = false;
			}
			if (hasEmoticons)
			{
				emoticonBrowser.show(e.target.parent, true);
			}
		}
	}
}