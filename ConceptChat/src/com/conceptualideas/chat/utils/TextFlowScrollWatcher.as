package com.conceptualideas.chat.utils
{
	import com.conceptualideas.chat.interfaces.IScrollbar;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.TextLayoutEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.events.ScrollEvent;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class TextFlowScrollWatcher
	{
		private var _scrollbar:IScrollbar;
		private var _flow:TextFlow
		private var _controller:ContainerController

		public static const SCROLL_VERT:String = "vert";
		private var _direction:String = SCROLL_VERT;
		private var _forceDown:Boolean = false;
		private const DEFAULT_LINE_HEIGHT:Number = 18;
		private var _lineHeight:Number = DEFAULT_LINE_HEIGHT;

		public function TextFlowScrollWatcher(scrollbar:Object, flow:TextFlow):void
		{
			
			_scrollbar = scrollbar;
			_flow = flow;
			_controller = flow.flowComposer.getControllerAt(0);
			setupTextFlow();
			setupScrollBar();
		}

		public function setForceDown(down:Boolean):void
		{
			_forceDown = down;
		}

		public function setLineHeight(height:Number):void
		{
			_lineHeight = height;
		}

		private function get composeVertical():Boolean
		{
			return (_direction == SCROLL_VERT);
		}

		private function setupScrollBar():void
		{
			_scrollbar.addEventListener(ScrollEvent.SCROLL, onScrollBarScroll);
		}

		private function setupTextFlow():void
		{
			_flow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, onFlowCompositionUpdated);

			_flow.addEventListener(TextLayoutEvent.SCROLL, onFlowScrollEvent);
		}




		private function onFlowScrollEvent(e:TextLayoutEvent):void
		{
			setScrollBarPosition(composeVertical ? _controller.verticalScrollPosition : _controller.horizontalScrollPosition);
		}

		private function setScrollBarPosition(position:Number):void
		{
			_scrollbar.removeEventListener(ScrollEvent.SCROLL, onScrollBarScroll);
			_scrollbar.scrollPosition = position;
			_scrollbar.addEventListener(ScrollEvent.SCROLL, onScrollBarScroll);
		}

		private function onScrollBarScroll(e:ScrollEvent):void
		{
			setFlowScrollPosition(e.position);
		}

		private function setFlowScrollPosition(position:Number):void
		{
			_flow.removeEventListener(TextLayoutEvent.SCROLL, onFlowScrollEvent);
			_controller[composeVertical ? "verticalScrollPosition" : "horizontalScrollPosition"] = position;
			_flow.addEventListener(TextLayoutEvent.SCROLL, onFlowScrollEvent);
		}



		private function commitScrollChanges():void
		{
			var textWidthHeight:Number = Math.ceil(_controller.getContentBounds()[composeVertical ? "height" : "width"]);




			var compositionWidthHeight:Number = _controller[composeVertical ? "compositionHeight" : "compositionWidth"];
			if (textWidthHeight < compositionWidthHeight)

			{
				_scrollbar.enabled = false;
				_scrollbar.visible = false;
			}
			else
			{
				_scrollbar.enabled = true;
				_scrollbar.visible = true;

				_scrollbar.minScrollPosition = 0;
				_scrollbar.lineScrollSize = _lineHeight + 2;
				_scrollbar.maxScrollPosition = textWidthHeight - compositionWidthHeight;
				_scrollbar.pageSize = compositionWidthHeight;


			}
			if (_forceDown)
			{
				_forceDown = false;
				setFlowScrollPosition(_scrollbar.maxScrollPosition + 5);
				setScrollBarPosition(_scrollbar.maxScrollPosition + 5);

			}

		}


		private function onFlowCompositionUpdated(e:UpdateCompleteEvent):void
		{
			commitScrollChanges();
		}


	}

}