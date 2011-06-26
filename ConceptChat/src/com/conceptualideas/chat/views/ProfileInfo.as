package com.conceptualideas.chat.views
{
	import com.conceptualideas.chat.interfaces.IDock;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import mx.core.FlexGlobals;
	import mx.core.IDataRenderer;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;

	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.TextBase;

	public class ProfileInfo extends SkinnableComponent implements IDock
	{



		[SkinPart(required="true")]
		public var title:TextBase

		[SkinPart(required="true")]
		public var dock:IVisualElementContainer
		[SkinPart(required="false")]
		public var image:IDataRenderer

		[SkinPart(required="false")]
		public var closeButton:ButtonBase
		private var callbacks:Dictionary = new Dictionary(true);



		private var rollOverDelayTimeoutID:Number
		private static const DELAY:int = 2000;

		public function ProfileInfo()
		{
			super();
		}





		override protected function createChildren():void
		{
			super.createChildren();
			addEventListener(MouseEvent.ROLL_OVER, rollOverOutHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOverOutHandler);
		}

		private function rollOverOutHandler(e:MouseEvent):void
		{

			if (isShowing && e.type == MouseEvent.ROLL_OUT)
			{
				startRollOverDelayTimeout();
			}
			else if (e.type == MouseEvent.ROLL_OVER)
			{
				clearTimeout(rollOverDelayTimeoutID);
			}
		}

		private function startRollOverDelayTimeout():void
		{
			clearTimeout(rollOverDelayTimeoutID);
			rollOverDelayTimeoutID = setTimeout(close, DELAY);
		}



		private var _guest:Boolean

		public function set guest(value:Boolean):void
		{
			if (_guest == value)
				return;
			_guest = value;
			dispatchEvent(new Event("guestChanged"));
		}

		public function get guest():Boolean
		{
			return _guest;
		}

		private var isShowing:Boolean

		public function show():void
		{

			clearTimeout(rollOverDelayTimeoutID);
			if (!isShowing)
			{


				PopUpManager.addPopUp(this, DisplayObject(FlexGlobals.topLevelApplication),
					false, PopUpManagerChildList.APPLICATION);
				PopUpManager.bringToFront(this);

				isShowing = true;
			}
		}

		public function close():void
		{
			PopUpManager.removePopUp(this);
			isShowing = false;
			dispatchEvent(new Event(Event.CLOSE));
		}
		private var _username:String

		public function set username(name:String):void
		{
			if (_username == name)
				return;
			_username = name;
			if (title)
				title.text = name;

		}

		public function get username():String
		{
			return _username;
		}

		private var _avatar:String

		public function set avatar(value:String):void
		{
			if (_avatar == value)
				return;
			_avatar = value;
			if (image)
				image.data = value;
		}

		public function get avatar():String
		{
			return _avatar;
		}




		private var dockElements:Vector.<IVisualElement> = new Vector.<IVisualElement>();



		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == dock)
			{

				var element:IVisualElement
				while (element = dockElements.shift())
				{
					dock.addElement(element);
				}
				dockElements = null;
				validateSize(true);
			}
			else if (instance == title)
			{

				if (_username)
					title.text = _username;

			}
			else if (instance == image)
			{

				if (_avatar)
					image.data = _avatar;
			}


		}


		public function add(name:String, component:Sprite, callback:Function=null):void
		{

			var el:IVisualElement = component as IVisualElement;
			if (!el)
				return;

			component.name = name;


			if (callback != null)
			{
				callbacks[el] = callback;
				el.addEventListener(MouseEvent.CLICK, clickHandler);
			}
			if (dock)
			{
				dock.addElement(el);
				validateSize(true);
			}
			else
			{
				dockElements.push(el);
			}

		}

		public function retrive(name:String):DisplayObject
		{

			if (dock)
				return DisplayObjectContainer(dock).getChildByName(name)

			for (var obj:* in callbacks)
			{
				if (obj.name == name)
					return DisplayObject(obj);
			}
			return null;
		}

		public function remove(name:String):DisplayObject
		{

			var display:DisplayObject = retrive(name);
			if (display)
			{

				dock.removeElement(IVisualElement(display));
				callbacks[display] = null;
				delete callbacks[display];

				display.removeEventListener(MouseEvent.CLICK, clickHandler);
			}
			return display;
		}

		private function clickHandler(e:MouseEvent):void
		{
			callbacks[e.target](_username);
		}
	}
}