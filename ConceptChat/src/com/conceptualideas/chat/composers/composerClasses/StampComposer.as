package com.conceptualideas.chat.composers.composerClasses
{
	import com.conceptualideas.chat.formatters.BasicStampFormatter;
	import com.conceptualideas.chat.interfaces.IComposer;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class StampComposer extends AbstractComposer
	{

		public function StampComposer()
		{
			formatter = new BasicStampFormatter();
		}

	}

}