package com.conceptualideas.chat.utils
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

	public class Convert
	{
		public function Convert()
		{
		}

		public static function convertToObject(classObject:*, data:*):*
		{
			var obj:* = new classObject();

			for (var prop:String in data)
			{
				if (obj.hasOwnProperty(prop))
				{
					try
					{
						obj[prop] = data[prop];
					}
					catch (e:Error)
					{
						try
						{
							var info:XML = describeType(obj[prop])
							var classRef:Class = getDefinitionByName(info.type.@name) as Class;
							obj[prop] = convertToObject(classRef, data[prop]);
						}
						catch (err:Error)
						{

						}
					}
				}

			}
			return obj;

		}
	}
}