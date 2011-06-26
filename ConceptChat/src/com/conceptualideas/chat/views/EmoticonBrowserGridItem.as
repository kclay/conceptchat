package com.conceptualideas.chat.views
{

	import com.conceptualideas.chat.events.EmoticonBrowserEvent;


	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.core.ScrollPolicy;
	import mx.events.FlexEvent;

	import spark.components.BorderContainer;
	import spark.components.Group;

	[Style(name="maxImageWidth", type="Number", format="Number", inherit="no")]
	[Style(name="maxImageHeight", type="Number", format="Number", inherit="no")]
	[Style(name="maxWidth", type="Number", format="Number", inherit="no")]
	[Style(name="maxHeight", type="Number", format="Number", inherit="no")]
	public class EmoticonBrowserGridItem extends BorderContainer
	{
		private var _emoticonInfo:Object
		private var _image:String;
		private var _text:String;
		private var _display:String;
		private var contentHolder:Image

		public function EmoticonBrowserGridItem(image:String, text:String, display:String)
		{
			_image = image;
			_text = text;
			_display = display;
			
			super();


		}

		override public function initialize():void
		{
			super.initialize();
			buttonMode = true;
			useHandCursor = true;


			addEventListener(MouseEvent.CLICK, onMouseClicked, false, 0, true);

		}

		private function onMouseClicked(e:MouseEvent):void
		{
			dispatchEvent(new EmoticonBrowserEvent(EmoticonBrowserEvent.SELECTED, _text.split(",")[0]));
		}

		private function onImageLoaded(e:FlexEvent):void
		{
			contentHolder.removeEventListener(FlexEvent.UPDATE_COMPLETE, onImageLoaded);
			contentHolder.setStyle("horizontalCenter", 0);
			contentHolder.setStyle("verticalCenter", 0);
			contentHolder.x = width / 2 - contentHolder.width / 2
			contentHolder.y = height / 2 - contentHolder.height / 2;
			//Drawing.fit(contentHolder, width, height);
			//Bitmap(contentHolder.content).smoothing = true;


		}

		override protected function createChildren():void
		{
			maxHeight = getStyle("maxHeight")
			maxWidth=getStyle("maxWidth");
			super.createChildren();
			contentHolder = new Image();
			contentHolder.maxHeight = getStyle("maxImageHeight");
			contentHolder.maxWidth = getStyle("maxImageWidth");
			contentHolder.addEventListener(FlexEvent.UPDATE_COMPLETE, onImageLoaded);
			addElement(contentHolder);
			contentHolder.source = _image;

		}

		public function destory():void
		{
			if (contentHolder.hasEventListener(FlexEvent.UPDATE_COMPLETE))
			{
				contentHolder.removeEventListener(FlexEvent.UPDATE_COMPLETE, onImageLoaded);
			}
			contentHolder.unloadAndStop();
			removeElement(contentHolder);

			contentHolder = null;
		}

	}
}