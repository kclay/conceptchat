package com.conceptualideas.chat.models
{

	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;


	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	[RemoteClass(alias="ChatFieldMessage")]
	public class ChatFieldMessage
	{
		public var from:String = '#system';
		public var fromColor:String = "0x000000";
		public var fromFont:String = 'Arial'
		public var fromSize:int = 11;
		public var message:String
		public var messageColor:String = '0x333333';
		public var messageFont:String = 'Arial';
		public var messageSize:int = 11;
		public var dateString:String = "";
		public var time:Date = new Date();
		public var isSystemMessage:Boolean = false;
		public var isHistory:Boolean = false;
		public var gender:String
		public var user:Object


		private static const PROPS:Array = [
			"from", "fromColor", "fromFont", "fromSize", "message",
			"messageColor", "messageFont", "messageSize"

			];




		public function ChatFieldMessage(message:String=null)
		{
			this.message = message;
		}


		public function readExternal(input:IDataInput):void
		{
			trace(input);
			//TODO Auto-generated method stub
		}

		public function writeExternal(output:IDataOutput):void
		{
			trace(output);
			//TODO Auto-generated method stub
		}

		public function isAcceptableUser():Boolean
		{
			return from.indexOf("Guest") != 0 && from.indexOf("#system") != 0;
		}

		public function toObject():Object
		{
			return {
					isHistory:isHistory,
					from:from,
					fromColor:fromColor,
					fromFont:fromFont,
					fromSize:fromSize,
					message:message,
					messageColor:messageColor,
					messageFont:messageFont,
					messageSize:messageSize


				}
		}



	}



}