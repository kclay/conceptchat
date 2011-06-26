package com.conceptualideas.chat.plugins.video.views
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import spark.components.DataGroup;
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.ButtonBase;
	
	public class ChooserDialogBase extends SkinnableContainer implements IChooserDialog
	{
		[SkinPart(required="true")]
		public var dataGroup:Object
		
		
		[SkinPart(required="true")]
		public var closeButton:ButtonBase
		private var _data:Object
		public function ChooserDialogBase()
		{
			super();
		}
		
		public function get data():Object
		{
			return _data;
		}
		protected function setData(value:Object):void{
			if(_data == value) return;
			_data = value;
			dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE))
		}
		
		protected function handleItemClick(target:Object):void{
			
		}
		private function item_clickHandler(e:Event):void{
			handleItemClick(e.target);
			
		}
		protected function getDataProviderForDataGroup():Array{
			return null;
		}
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == dataGroup)
			{
				
				dataGroup.addEventListener("itemClicked", item_clickHandler, false, 0, true);
				
				
				dataGroup.dataProvider = new ArrayCollection(getDataProviderForDataGroup());
				
			}
			else if (instance == closeButton)
			{
				closeButton.addEventListener(MouseEvent.CLICK, closeButton_clickHandler);
			}
		}
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			if (instance == dataGroup)
			{
				dataGroup.removeEventListener("itemClicked", item_clickHandler);
			}
			else if (instance == closeButton)
			{
				closeButton.removeEventListener(MouseEvent.CLICK, closeButton_clickHandler);
			}
		}
		
		protected function closeButton_clickHandler(e:MouseEvent):void{
			dispatchEvent(new Event(Event.CLOSE));
		}
		
	}
}