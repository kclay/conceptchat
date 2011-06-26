package com.conceptualideas.chat.interfaces
{
	import flashx.textLayout.elements.FlowElement;

	public interface IChatMessageFilter
	{
		public function filter(flowElement:FlowElement):FlowElement
	}
}