package com.conceptualideas.chat.composers.composerClasses
{
	import com.conceptualideas.chat.composers.composerClasses.AbstractComposer;
	import com.conceptualideas.chat.formatters.MessageFormatter;


	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class MessageComposer extends AbstractComposer
	{

		public function MessageComposer()
		{
			formatter = new MessageFormatter(this);

		}

	}

}