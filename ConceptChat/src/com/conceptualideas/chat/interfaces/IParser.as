package com.conceptualideas.chat.interfaces {
	
	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public interface IParser {
		/**
		 * Parses a raw string into is correct format by use of its own IFormatter
		 * @param	raw
		 * @return String
		 */
		function parse(raw:String):String
		function get name():String
	}

	

}