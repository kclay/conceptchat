package com.conceptualideas.chat.filters
{
	import com.conceptualideas.chat.interfaces.IChatMessageFilter;
	import com.conceptualideas.chat.interfaces.IComposerFilter;
	
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

	public class MaxLineFilter implements IComposerFilter
	{
		private var _maxLines:int = 3;


		public function MaxLineFilter()
		{

		}


		public function set maxLines(value:int):void
		{
			_maxLines = value;
		}

		public function filter(content:*):*
		{

			
			var textFlow:TextFlow = content as TextFlow;
			
			var para:ParagraphElement = textFlow.getElementByID("container") as ParagraphElement;
			
			var flowWidth:Number = textFlow.flowComposer.getControllerAt(0).compositionWidth;
			
			var rawText:String = para.getText();
			var cachedTextFlow:TextFlow = content.cachedTextFlow as TextFlow;
			if (!cachedTextFlow)
				return content;

			var composingTextFlow:TextFlow = content.composingTextFlow;
			var realParagraph:ParagraphElement = composingTextFlow.getElementByID("container") as ParagraphElement;
			var clonedParagraph:ParagraphElement = realParagraph.deepCopy() as ParagraphElement

			if (!clonedParagraph)
				return content;
			var previousLineCount:int = cachedTextFlow.flowComposer.numLines;
			cachedTextFlow.addChild(clonedParagraph);
			cachedTextFlow.flowComposer.updateAllControllers();
			//if (par.textLength > _maxLines)
			//{
			var totalParagraphLines:int = clonedParagraph.getTextFlow().flowComposer.numLines - previousLineCount;
			if (totalParagraphLines > _maxLines)
			{
				var textBlock:TextBlock = clonedParagraph.getTextBlock();
				var counter:int = 0;
				
				for (var textLine:TextLine = textBlock.firstLine; textLine != null; textLine = textLine.nextLine)
				{
					
					if (counter++ <= _maxLines)
					{
						trace(textLine.dump());
						//textBlock.releaseLines(textLine, textBlock.lastLine);
						break;
					}
				}
				
			}

			//composingTextFlow.addChild(par);
			return content;


		}
	}
}