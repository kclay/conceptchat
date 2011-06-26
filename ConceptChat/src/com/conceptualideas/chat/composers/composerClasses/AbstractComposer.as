package com.conceptualideas.chat.composers.composerClasses
{
	import com.conceptualideas.chat.interfaces.IComposer;
	import com.conceptualideas.chat.interfaces.IComposerContext;
	import com.conceptualideas.chat.interfaces.IFormatter;
	import com.conceptualideas.chat.interfaces.IParser;
	import com.conceptualideas.chat.models.ChatFieldMessage;

	

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class AbstractComposer implements IComposer
	{

		public function get context():IComposerContext
		{
			return _context;
		}

		public function set context(value:IComposerContext):void
		{
			_context = value;
		}
		private var _context:IComposerContext
		/**
		 * Instance of formatter to be used for this composer
		 */
		public function set formatter(value:IFormatter):void{
			_formatter = value;
			_formatter.parent = this;
		}
		public function get formatter():IFormatter{
			return _formatter;
		}
		private var _formatter:IFormatter
		/**
		 * List of parsers
		 */
		private var parsers:Vector.<IParser>

		public function AbstractComposer()
		{

			parsers = new Vector.<IParser>();
		}

		/**
		 * Check to see if composer has a paser of clazz instance
		 * @param	clazz
		 * @return
		 */
		public function hasParser(clazz:Class):Boolean
		{
			for each (var parser:IParser in parsers)
				if (parser is clazz)
					return true;
			return false;
		}

		public function getParser(nameOrClass:*):IParser
		{
			var byName:Boolean = nameOrClass is String;
			var parserName:String = nameOrClass as String;
			var parserClass:Class = nameOrClass as Class;

			for each (var parser:IParser in parsers)
				if (byName && parser.name == nameOrClass ||
					!byName && parser is parserClass)
				{
					return parser;
				}
			return null;
		}

		/**
		 * Add an paser to current composer
		 * @param	parser
		 */
		public function addParser(parser:IParser):void
		{
			if (parsers.indexOf(parser) == -1)
				parsers.push(parser);
		}

		/* INTERFACE com.conceptualideas.chat.interfaces.IComposer */

		/**
		 * Main entry point to compose current content
		 * @param	content
		 * @param	format
		 * @return
		 */
		public function compose(content:Object, format:String="default"):String
		{
			formatter.reset();
			var finalContent:String = "";

			switch (format)
			{

				case ComposeFormats.SELF:
					finalContent = formatter.formatSelf(content);
					break;
				case ComposeFormats.SYSTEM:
					finalContent = formatter.formatSystem(content);
					break;
				default:
					finalContent = formatter.format(content);

			}
			var parser:IParser
			for each (parser in parsers)
				finalContent = parser.parse(finalContent);

			return finalContent;
		}

		public function newFormatter(clazz:Class):IFormatter
		{
			var formatter:IFormatter

			try
			{
				formatter = new clazz();
				formatter.parent = this;
			}
			catch (e:Error)
			{
				trace(e);
				formatter = null;
			}
			return formatter;
		}

	}

}