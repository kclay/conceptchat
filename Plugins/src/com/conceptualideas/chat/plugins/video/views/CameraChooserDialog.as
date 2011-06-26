package com.conceptualideas.chat.plugins.video.views
{
	import flash.media.Camera;



	public class CameraChooserDialog extends ChooserDialogBase
	{



		public function CameraChooserDialog()
		{
			super();
			this.styleName = "cameraChooserDialog";

		}


		override protected function getDataProviderForDataGroup():Array
		{
			var cameraData:Array = [null];

			var cameraNames:Array = Camera.names;
			var len:int = cameraNames.length;
			for (var i:int = 0; i < len; i++)
			{
				cameraData.push({cameraIndex:String(i), name:cameraNames[i]});
			}
			return cameraData;
		}

		override protected function handleItemClick(target:Object):void
		{

			setData(target.data ? target.data.cameraIndex : "noCameraAtAllDamit");

		}



	}
}