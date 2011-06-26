package com.conceptualideas.chat.plugins.video.views
{
	import flash.media.Microphone;
	
	import spark.components.SkinnableContainer;

	public class MicrophoneChooserDialog extends ChooserDialogBase
	{


		public function MicrophoneChooserDialog()
		{
			super();
			styleName = "microphoneChooserDialog";
		}

		override protected function getDataProviderForDataGroup():Array{
			var names:Array = Microphone.names;
			var len:int = names.length;
			var data:Array = [];
			for(var i:int = 0;i<len;i++){
				data.push({name:names[i],index:i});
			}
			return data;
		}
		override protected function handleItemClick(target:Object):void
		{
			setData(target.selectedItem.index);
		}

	}
}