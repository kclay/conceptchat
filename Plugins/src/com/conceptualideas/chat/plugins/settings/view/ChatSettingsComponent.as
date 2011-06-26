package com.conceptualideas.chat.plugins.settings.view
{
	import com.conceptualideas.chat.interfaces.IDock;

	import spark.components.SkinnableContainer;

	public class ChatSettingsComponent extends SkinnableContainer
	{
		[SkinPart(required="true")]
		public var dock:IDock

		public function ChatSettingsComponent()
		{
			super();
		}
		
	}
}