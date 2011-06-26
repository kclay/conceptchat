package com.conceptualideas.chat.plugins.video.views
{
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.plugins.media.IRemoteMediaManager;
	import com.conceptualideas.chat.plugins.video.skins.VideoBlockSkin;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.Video;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElementContainer;
	import mx.managers.PopUpManager;
	
	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.SliderBase;
	import spark.components.supportClasses.ToggleButtonBase;

	[SkinState("uninitialized")]
	[SkinState("preview")]
	[SkinState("selectNoCamera")]
	[SkinState("publishNoCamera")]
	[SkinState("publishCamera")]
	[Event(name="close", type="flash.events.Event")]
	public class VideoBlock extends SkinnableComponent implements IDisposable
	{




		[SkinPart(required="false")]
		public var videoContainer:DisplayObjectContainer

		[SkinPart(required="false")]
		public var fullScreenButton:ButtonBase

		[SkinPart(required="false")]
		public var closeButton:ButtonBase

		[SkinPart(required="false")]
		public var volumeSlider:SliderBase

		[SkinPart(required="false")]
		public var volumeToggleButton:ToggleButtonBase






		private var currentBlockState:String = "uninitialized";

		public function VideoBlock()
		{

			super();
			setStyle("skinClass", VideoBlockSkin);
			//addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
		}

		override protected function createChildren():void
		{
			super.createChildren();
			video.smoothing = true;
		}


		private var _hasCamera:Boolean
		private var hasCameraChanged:Boolean

		public function set hasCamera(value:Boolean):void
		{

			if (_hasCamera == value)
				return;

			_hasCamera = value;
			hasCameraChanged = true;
			invalidateProperties();

		}
		private var _manager:IRemoteMediaManager

		public function get manager():IRemoteMediaManager
		{
			return _manager;
		}

		private var managerChanged:Boolean

		public function set manager(value:IRemoteMediaManager):void
		{
			if (_manager == value)
				return;
			if (_manager)
				_manager.video = null;
			_manager = value;
			managerChanged = true;
			invalidateProperties()
		}
		private var _video:Video = new Video();

		public function get video():Video
		{
			return _video;
		}


		private var _label:String


		public function set label(value:String):void
		{
			if (_label == value)
				return;
			_label = value;
			dispatchEvent(new Event("labelChanged"));
		}

		[Bindable(event="labelChanged")]
		public function get label():String
		{
			return _label;
		}



		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == videoContainer)
			{
				videoContainer.addChild(_video)

			}
			else if (instance == fullScreenButton)
			{
				fullScreenButton.addEventListener(MouseEvent.CLICK, fullScreenButton_clickHandler)
			}
			else if (instance == volumeSlider)
			{
				volumeSlider.minimum = 0;
				volumeSlider.maximum = 100;
				volumeSlider.value = 100;
				volumeSlider.addEventListener(Event.CHANGE, volumeSlider_changeHandler);
			}
			else if (instance == volumeToggleButton)
			{
				volumeToggleButton.addEventListener(MouseEvent.CLICK, volumeToggleButton_clickHandler);
			}
			else if (instance == closeButton)
			{
				closeButton.addEventListener(MouseEvent.CLICK, closeButton_clickHandler);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void{
			super.partRemoved(partName,instance);
			if (instance == videoContainer)
			{
				if(_video)
					videoContainer.addChild(_video)
				
			}
			else if (instance == fullScreenButton)
			{
				fullScreenButton.removeEventListener(MouseEvent.CLICK, fullScreenButton_clickHandler)
			}
			else if (instance == volumeSlider)
			{
				
				volumeSlider.removeEventListener(Event.CHANGE, volumeSlider_changeHandler);
			}
			else if (instance == volumeToggleButton)
			{
				volumeToggleButton.removeEventListener(MouseEvent.CLICK, volumeToggleButton_clickHandler);
			}
			else if (instance == closeButton)
			{
				closeButton.removeEventListener(MouseEvent.CLICK, closeButton_clickHandler);
			}
		}



		private function closeButton_clickHandler(e:MouseEvent):void
		{
			dispatchEvent(new Event(Event.CLOSE));
		}
		private var fullScreen:Boolean

		private var beforeFullScreenInfo:Object


		override public function set currentState(value:String):void
		{
			if (currentBlockState == value)
				return;
			currentBlockState = value;
			invalidateSkinState();
		}

		private function volumeToggleButton_clickHandler(e:MouseEvent):void
		{
			if (_manager)
			{
				if (volumeToggleButton.selected)
				{
					_manager.mute()
				}
				else
				{
					_manager.unmute();
				}

			}

		}

		private function volumeSlider_changeHandler(e:Event):void
		{
			if (_manager)
				_manager.volume = volumeSlider.value;
		}

		private function fullScreenButton_clickHandler(e:MouseEvent):void
		{
			if (!fullScreen)
			{

				if (!systemManager.getTopLevelRoot()) // check to see if we can go into fullscreen
					return;

				var screenBounds:Rectangle = getScreenBounds();
				fullScreen = true;

				// let's get it off of our layout system so it doesn't interfere with 
				// the sizing and positioning. Then let's resize it to be 
				// the full size of our screen.  Then let's position it off-screen so
				// there are no other elements in the way.
				beforeFullScreenInfo = {parent:this.parent,
						x:this.x,
						y:this.y,
						explicitWidth:this.explicitWidth,
						explicitHeight:this.explicitHeight};



				// remove from old parent
				if (parent is IVisualElementContainer)
				{
					var ivec:IVisualElementContainer = IVisualElementContainer(parent);
					beforeFullScreenInfo.childIndex = ivec.getElementIndex(this);
					ivec.removeElement(this);
				}
				else
				{
					beforeFullScreenInfo.childIndex = parent.getChildIndex(this);
					parent.removeChild(this);
				}


				// add as a popup
				PopUpManager.addPopUp(this, FlexGlobals.topLevelApplication as DisplayObject);

				// Resize the component to be the full screen of the stage.
				// Push the component at (0,0).  It should be on top of everything 
				// at this point because it was added as a popup
				setLayoutBoundsSize(screenBounds.width, screenBounds.height, true);
				// set the explicit width/height to make sure this value sticks regardless 
				// of any other code or layout passes.  Calling setLayoutBoundsSize() before hand
				// allows us to use postLayout width/height
				this.explicitWidth = width;
				this.explicitHeight = height;
				setLayoutBoundsPosition(0, 0, true);


				// this is for video performance reasons, but sometimes the videoObject isn't there
				// if the source is null
				if (video)
				{
					beforeFullScreenInfo.smoothing = video.smoothing;
					beforeFullScreenInfo.deblocking = video.deblocking;
					video.smoothing = false;
					video.deblocking = 0;
				}


				this.validateNow();

				systemManager.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);

				// TODO (rfrishbe): Should we make this FULL_SCREEN_INTERACTIVE if in AIR?
				systemManager.stage.displayState = StageDisplayState.FULL_SCREEN;

			}
			else
			{
				systemManager.stage.displayState = StageDisplayState.NORMAL;
			}

		}

		/**
		 *  @private
		 *  Handles when coming out the full screen mode
		 */
		private function fullScreenEventHandler(event:FullScreenEvent):void
		{
			// going in to full screen is handled by the 
			// fullScreenButton_clickHandler
			if (event.fullScreen)
				return;



			// set the fullScreen variable back to false and remove this event listener
			fullScreen = false;
			systemManager.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);




			// reset it so we're re-included in the layout
			this.x = beforeFullScreenInfo.x;
			this.y = beforeFullScreenInfo.y;
			this.explicitWidth = beforeFullScreenInfo.explicitWidth;
			this.explicitHeight = beforeFullScreenInfo.explicitHeight;


			// sometimes there's no video object currently or there might not've been a 
			// video object when we went in to fullScreen mode.  There may be no videoObject
			// if the source hasn't been set.
			if (video && beforeFullScreenInfo.smoothing !== undefined)
			{
				video.smoothing = beforeFullScreenInfo.smoothing;
				video.deblocking = beforeFullScreenInfo.deblocking;
			}



			// remove from top level application:
			PopUpManager.removePopUp(this);

			// add back to original parent
			if (beforeFullScreenInfo.parent is IVisualElementContainer)
				beforeFullScreenInfo.parent.addElementAt(this, beforeFullScreenInfo.childIndex);
			else
				beforeFullScreenInfo.parent.addChildAt(this, beforeFullScreenInfo.childIndex);



			beforeFullScreenInfo = null;

			invalidateSkinState();
			invalidateSize();
			invalidateDisplayList();
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (video)
			{
				
				video.width = unscaledWidth;
				video.height = unscaledHeight;

			}
		}



		/**
		 *  @private
		 *  Returns the screen bounds.
		 *  If we are on the AIR Player, we need to work around AIR Player bug #2503351
		 *  We check if the flash.display.Screen class is defined. If so, then
		 *  we are running on the AIR Player and can access this API.
		 */
		private function getScreenBounds():Rectangle
		{

			/*if (screenClass)
			   {
			   // Get the screen where the application resides
			   var nativeWindowBounds:Rectangle = stage["nativeWindow"]["bounds"];
			   var currentScreen:Object = screenClass["getScreensForRectangle"](nativeWindowBounds)[0];

			   // Return the bounds of that screen
			   return currentScreen["bounds"];
			   }
			   else
			 {*/
			return new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
			//}
		}

		override protected function commitProperties():void
		{

			super.commitProperties();
			if (managerChanged)
			{
				if (_manager)
				{
					_manager.video = video;

					managerChanged = false;
				}
			}
			if (hasCameraChanged)
			{



				currentBlockState = (_hasCamera) ? "publishCamera" : "publishNoCamera";
				invalidateSkinState()

				hasCameraChanged = false;

			}



		}

		override protected function getCurrentSkinState():String
		{
			return currentBlockState;
		}

		public function dispose():void
		{
			if (_manager)
				_manager.dispose();
			_manager = null;

			if (_video)
			{
				_video.attachCamera(null);
				_video.attachNetStream(null);
			}
			_video = null;

		/*if (uiMicBitmap && uiMicBitmap is Bitmap)
		 Bitmap(uiMicBitmap.source).bitmapData.dispose();*/

		}



		private function removeFromStageHandler(e:Event):void
		{
			removeEventListener(e.type, removeFromStageHandler);
			dispose();
		}
	}
}