package com.conceptualideas.chat.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public class Disposer
	{
		public function Disposer()
		{
		}

		public static function dispose(object:Object):void
		{
			if (!object)
				return;
			if (object is Bitmap)
			{
				dispose(Bitmap(object).bitmapData);
			}
			else if (object is BitmapData)
			{
				BitmapData(object).dispose();
			}
			else if (object.hasOwnProperty("source"))
			{
				dispose(object.source);
			}
			else if ("dispose" in object)
			{
				object.dispose();
			}
		}
	}
}