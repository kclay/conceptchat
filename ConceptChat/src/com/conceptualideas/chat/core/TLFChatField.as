package com.conceptualideas.chat.core
{
	import com.conceptualideas.chat.composers.TLFComposerContext;
	import com.conceptualideas.chat.interfaces.IComposerContext;
	import com.conceptualideas.chat.interfaces.IDisposable;
	import com.conceptualideas.chat.models.ChatFieldMessage;
	import com.conceptualideas.chat.models.ChatFieldsOptions;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.formats.LeadingModel;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	import org.bytearray.gif.events.FileTypeEvent;
	import org.bytearray.gif.events.GIFPlayerEvent;
	import org.bytearray.gif.player.GIFPlayer;

	use namespace tlf_internal;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class TLFChatField extends EventDispatcher implements IDisposable, IChatField
	{

		private var _width:Number
		private var _height:Number
		private var flow:TextFlow;

		private var controller:ContainerController;


		// Taken from SmileyRender


		private var lineContent:Array
		private var _view:Sprite
		private var _options:ChatFieldsOptions
		private var _composerContext:IComposerContext = new TLFComposerContext();


		private const GIF_ID_PREFIX:String = "animatedGIF_";

		private var orphanGifs:Dictionary = new Dictionary(true);
		private var cachedTextFlow:TextFlow





		public function TLFChatField(view:Sprite, width:Number, height:Number, options:ChatFieldsOptions=null)
		{
			_width = width;
			_height = height;
			_view = view;
			_options = (options) ? options : new ChatFieldsOptions();
			init();


		}

		public function set composerContext(value:IComposerContext):void
		{
			_composerContext = value;
			_composerContext.config = flow.configuration;
		}

		public function setTextFlow(newFlow:TextFlow):void
		{

			destroyTextFlow();
			flow = newFlow;
			setupTextFolow()
			

			//flow.hostFormat = getTextLayoutFormat();
		}

		public function getTextFlow():TextFlow
		{
			return flow;
		}

		private function setupTextFolow():void
		{

			flow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, onGraphicStatusChange);
			flow.hostFormat = getTextLayoutFormat();
			controller = flow.flowComposer.getControllerAt(0);
			var config:Configuration = flow.configuration as Configuration;
			config.inlineGraphicResolverFunction = resolverInlineGraphic;
			_composerContext.config = config;
			//flow.interactionManager = new ExtendedSelectionManager();




		}

		private function resolverInlineGraphic(inlineGraphic:InlineGraphicElement):*
		{
			if (inlineGraphic.source is String && inlineGraphic.source.indexOf(".gif") != -1)
			{
				var graphicID:String = "animatedGIF_" + (new Date().getTime());
				var textRepresentation:String = inlineGraphic.id;
				inlineGraphic.id = graphicID
				inlineGraphic.width = "auto";
				inlineGraphic.height = "auto";
				createGifPlayer(graphicID, inlineGraphic.source as String, textRepresentation);
			}
			return inlineGraphic.source;
		}

		private function createGifPlayer(id:String, source:String, textRepresentation:String):void
		{
			var gif:GIFPlayer = new GIFPlayer();
			gif.textRepresentation = textRepresentation;
			gif.name = id;
			gif.addEventListener(GIFPlayerEvent.COMPLETE, gif_completeHandler);
			gif.addEventListener(FileTypeEvent.INVALID, gif_invalidHandler);
			gif.load(new URLRequest(source));
			orphanGifs[id] = {
					source:true,
					textRepresentation:textRepresentation
				}

		}

		private function disposeGifPlayer(gif:GIFPlayer):void
		{
			gif.dispose();
			gif.removeEventListener(GIFPlayerEvent.COMPLETE, gif_completeHandler);
			gif.removeEventListener(FileTypeEvent.INVALID, gif_invalidHandler);
		}

		private function gif_completeHandler(e:GIFPlayerEvent):void
		{
			var gif:GIFPlayer = e.target as GIFPlayer;

			orphanGifs[gif.name].source = gif;

			var inlineGraphic:InlineGraphicElement = flow.getElementByID(gif.name) as InlineGraphicElement;

			if (inlineGraphic && inlineGraphic.status == InlineGraphicElementStatus.READY)
			{

				applyGifToInlineGraphicElement(inlineGraphic);
			}

		}



		private function applyGifToInlineGraphicElement(elem:InlineGraphicElement):void
		{
			//var frameRect:Rectangle = e.frame.bitmapData.rect;
			if (orphanGifs[elem.id] && orphanGifs[elem.id].source is GIFPlayer)
			{
				elem.source = orphanGifs[elem.id].source;
				if(!elem.getBlockElement().userData){
					elem.getBlockElement().userData={};
				}
				elem.getBlockElement().userData.text = orphanGifs[elem.id].textRepresentation;
				//disposeGifPlayer(orphanGifs[elem.id].source);
				//elem.id = orphanGifs[elem.id].textRepresentation;
				/*if(elem.getBlockElement()﷯){
				   elem.getBlockElement().userData =
				 }*/

				orphanGifs[elem.id] = null;
			}
		}

		private function gif_invalidHandler(e:FileTypeEvent):void
		{
			disposeGifPlayer(GIFPlayer(e.target));

		}

		private function destroyTextFlow():void
		{

		}

		private function getTextLayoutFormat():TextLayoutFormat
		{

			var format:TextLayoutFormat = new TextLayoutFormat(flow.format);

			format.leadingModel = LeadingModel.ROMAN_UP

			if (!isNaN(_options.columnGap))
				format.columnGap = _options.columnGap
			if (!isNaN(_options.fontSize))
				format.fontSize = _options.fontSize;
			if (!isNaN(_options.lineHeight))
				format.lineHeight = _options.lineHeight;
			// for some reason the first line if off by the line height creating a empty line
			format.firstBaselineOffset = 0; //-_options.lineHeight;
			return format;
		}

		private function init():void
		{

			flow = new TextFlow();


			//flow.baselineShift = 10;
			flow.interactionManager = new SelectionManager();
			createController();
			setupTextFolow()

		}


		private function createController():void
		{
			controller = new ContainerController(_view, _width, _height);
			flow.flowComposer.addController(controller);

		}

		private function updateControllers():void
		{

			flow.flowComposer.updateAllControllers();

		}

		private function onGraphicStatusChange(e:StatusChangeEvent):void
		{

			var ilg:InlineGraphicElement
			if (e.status == InlineGraphicElementStatus.READY)
			{
				ilg = e.element as InlineGraphicElement;
				if (ilg)
				{
					applyGifToInlineGraphicElement(ilg);
				}
				updateControllers();
			}


		}

		/**
		 * Sets the container size
		 * @param	width
		 * @param	height
		 */
		public function setSize(width:Number, height:Number):void
		{

			_width = width;
			_height = height;
			controller.setCompositionSize(_width, _height);
			updateControllers();
		}





		public function clear():void
		{
			//var elem:FlowElement
			while (flow.numChildren > 0)
			{
				flow.removeChildAt(0);
					//while(elem.deepCopy(
			}
			updateControllers();
		}

		public function addLine(message:ChatFieldMessage):void
		{

			/*if (!cachedTextFlow){
			   cachedTextFlow = flow.shallowCopy() as TextFlow;
			   cachedTextFlow.flowComposer.addControllerAt(flow.flowComposer.getControllerAt(0),0);
			 }*/
			if (message.message == '/clear')
			{
				clear();
				return;
			}

			var newElement:FlowElement = FlowElement(_composerContext.compose(message));

			if (newElement)
			{
				flow.addChild(newElement)
			}
			if (flow.numChildren + 1 == _options.maxMessages)
			{
				flow.removeChildAt(0);
			}
			updateControllers();



		}

		public function dispose():void
		{
			clear();
			
			_composerContext = null;
			controller = null;
			flow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, onGraphicStatusChange);
			flow = null;


		}



	}
}