package com.conceptualideas.chat.core
{
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.utils.ComposerContextInjector;
	import com.conceptualideas.chat.utils.PluginInjector;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class XMLConfigReader extends AbstractConfigReader
	{

		protected var pluginDefaults:Array

		public function XMLConfigReader(context:IChatContext)
		{
			super(context);
		}

		override protected function setupComposerContext(config:Object):void
		{
			new ComposerContextInjector().inject(chatContext, XML(config));
		}

		override protected function setupPlugins(config:Object):void
		{

			new PluginInjector(pluginDefaults).inject(chatContext, XML(config));
		}

	}

}