package com.conceptualideas.chat.composers.composerClasses {
	import com.conceptualideas.chat.composers.composerClasses.StampComposer;
	import com.conceptualideas.chat.formatters.ProfileStampFormatter;
	
	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class ProfileStampComposer extends StampComposer{
		
		public static const PROFILE_CLICKED:String=ProfileStampFormatter.PROFILE_CLICKED;
		public function ProfileStampComposer() {
			formatter = new ProfileStampFormatter(this);
		}
		
		public function get typedFormatter():ProfileStampFormatter {
			return formatter as ProfileStampFormatter;
		}
		
	}

}