package com.conceptualideas.chat.plugins.user.views
{

	import com.conceptualideas.chat.plugins.user.IUserDelegator;
	import com.conceptualideas.chat.plugins.user.events.UserListEvent;
	
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.DataGroup;
	import spark.components.List;
	import spark.components.supportClasses.ListBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;

	public class UserListComponent extends SkinnableComponent implements IUserDelegator
	{


		[SkinPart(required="false")]
		public var registeredList:List
		[SkinPart(required="false")]
		public var broadCastingDataGroup:DataGroup

		public function UserListComponent()
		{
			super();


		}


		private var registeredCollection:ArrayCollection = new ArrayCollection();

		private var broadCastingCollection:ArrayCollection = new ArrayCollection();



		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			if(!value){
				includeInLayout = false;
				visible = false;
			}
		}

		public function set list(value:Array):void
		{

			registeredCollection.source = value;

		}

		public function set broadCastingList(value:Array):void
		{
			broadCastingCollection.source = value;

		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == registeredList)
			{

				registeredList.dataProvider = registeredCollection;
				registeredList.addEventListener(IndexChangeEvent.CHANGE, list_indexChangeHandler);

					//registeredDataGroup.addEventListener(RendererExistenceEvent.RENDERER_ADD, dataGroup_setupRendererHandler);
					//registeredDataGroup.addEventListener(RendererExistenceEvent.RENDERER_REMOVE, dataGroup_setupRendererHandler);
			}
			else if (instance == broadCastingDataGroup)
			{
				broadCastingDataGroup.dataProvider = broadCastingCollection;
			}

		}

		private function list_indexChangeHandler(e:IndexChangeEvent):void
		{
			var list:ListBase = ListBase(e.target);

			var point:Point = new Point(mouseX, mouseY);
			point = localToGlobal(point)

			dispatchShowInfo(list.selectedItem.name, point.x, point.y);

		}



		private function dispatchShowInfo(name:String, x:Number, y:Number):void
		{

			if (!hasEventListener(UserListEvent.NAME_CLICKED))
				return;
			var e:UserListEvent  = new UserListEvent(UserListEvent.NAME_CLICKED);


			e.x = x;
			e.y = y;
			e.name = name;
			dispatchEvent(e);

		}



	}
}