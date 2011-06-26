package com.conceptualideas.chat.core
{
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.utils.PluginInjector;

	public class AbstractConfigReader
	{
		protected var chatContext:IChatContext

		

		public function AbstractConfigReader(context:IChatContext)
		{
			this.chatContext = context;
		}

		final public function startup(settings:Object):void
		{

			setupComposerContext(settings);
			setupPlugins(settings)


		}

		protected function setupPlugins(config:Object):void
		{
			
		}

		protected function setupComposerContext(config:Object):void
		{

		}

	}

}