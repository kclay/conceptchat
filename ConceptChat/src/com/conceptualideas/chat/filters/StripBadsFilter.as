package com.conceptualideas.chat.filters
{

	import com.conceptualideas.chat.interfaces.IComposerFilter;
	import com.conceptualideas.chat.models.ChatFieldMessage;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class StripBadsFilter implements IComposerFilter
	{

		public function StripBadsFilter()
		{

		}


		/* INTERFACE com.conceptualideas.chat.interfaces.IComposerFilter */

		public function filter(content:*):*
		{
			var cleanMessage:String = "";
			if (content is ChatFieldMessage)
			{
				cleanMessage = ChatFieldMessage(content).message
			}
			else if (content is String)
			{
				cleanMessage = content as String;
			}
			else
			{
				return content;
			}
			//if(_filter)
			//	cleanMessage.replace(
			// decode if encoded somehow
			//cleanMessage = decodeURIComponent(cleanMessage)

			cleanMessage = cleanMessage.replace(/\<|\>/g, '');
			cleanMessage = cleanMessage.replace("\\n", "\n");

			if (content is ChatFieldMessage)
			{
				ChatFieldMessage(content).message = cleanMessage;
				return content;
			}
			return cleanMessage;


		}


	}
}