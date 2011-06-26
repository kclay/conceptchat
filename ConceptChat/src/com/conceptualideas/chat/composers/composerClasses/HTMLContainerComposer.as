package com.conceptualideas.chat.composers.composerClasses
{
	import com.conceptualideas.chat.interfaces.IComposer;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class HTMLContainerComposer extends ContainerComposer implements IComposer
	{

		private static const TEMPLATE:String = 
		"<p><font  size='{messageSize}' face='{messageFont}'>{message}</font></p>";
		

		public function HTMLContainerComposer()
		{

		}

		override public function compose(content:Object, format:String=ComposeFormats.DEFAULT):String
		{
			if (_tokens.isHistory)
			{
				_tokens.messageColor = _historyColor;
			}
			if (_tokens.from == "#system")
			{
				_tokens.messageColor = _systemColor;
			}

			var finalTemplate:String = TEMPLATE;
			var italic:Boolean = (_historyItalicize && _tokens.isHistory || _tokens.from == "#system") ? 'italic' : 'normal';
			if (italic){
				finalTemplate = "<i>" + finalTemplate + "</i>";
			}
			templateFormatter.tokens = _tokens;
			_tokens = null;
			return templateFormatter.format(finalTemplate);
		}

	}

}