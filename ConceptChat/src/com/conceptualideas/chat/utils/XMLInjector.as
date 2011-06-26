package com.conceptualideas.chat.utils
{
	import com.conceptualideas.chat.interfaces.IChatContext;
	import com.conceptualideas.chat.interfaces.IInjector;
	
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class XMLInjector
	{

		protected var extras:Dictionary = new Dictionary(true);

		public function XMLInjector()
		{

		}

		public function inject(chatContext:IChatContext, xml:XML):void
		{

		}

		protected function processXML(list:XMLList, callback:Function=null):void
		{
			var node:XML
			var className:String
			var clazz:*
			var classInstance:*
			var classProp:XML
			var classPropName:String
			var classPropValue:*
			var injectTarget:Object

			for each (node in list)
			{
				className = node.@className;
				if (!className.length)
					continue;

				classInstance = isResolveAble(className) ? resolveValue(className) : getClass(className);
				if (!classInstance || classInstance is String)
					continue;
				if (classInstance is Class)
					classInstance = new classInstance();

				
				if (classInstance is IInjector)
				{

					IInjector(classInstance).inject(node);

				}
				else 
				{
					for each (classProp in node.prop)
					{
						injectTarget = classInstance;
						classPropName = String(classProp.@path);
						classPropValue = String(classProp.@value);
						if (classPropName.indexOf(".") != -1)
						{
							var parts:Array = classPropName.split(".");
							classPropName = parts.pop();
							var p:String

							while (p = parts.shift())
							{
								if (!injectTarget.hasOwnProperty(p))
								{
									parts.unshift(p);
									break
								};
								injectTarget = injectTarget[p];
							}
							if (parts.length)
								break; // didnt complete
						}
						classPropValue = resolveValue(classPropValue);
						/*if (classProp.@useExtra == "true")
						 classPropValue = extras[classPropValue];*/


						if (injectTarget.hasOwnProperty(classPropName))
						{
							try
							{
								injectTarget[classPropName] = classPropValue;
							}
							catch (e:Error)
							{
								try
								{
									var args:Array = [classPropValue]
									if (classPropValue.indexOf(","))
										args = classPropValue.split(",");

									injectTarget[classPropName].apply(null, args)
								}
								catch (e:Error)
								{
									trace(e);
								}
							}


						}
					}

				}
				if (callback != null)
					callback(classInstance, node.@name);


			}

		}

		protected function isResolveAble(value:String):Boolean
		{
			return false;
		}

		protected function resolveValue(value:String):*
		{
			return (extras[value]) ? extras[value] : value;

		}

		protected function resolveName(name:String):String
		{
			return name;
		}

		protected function getClass(className:String):Class
		{
			try
			{
				return getDefinitionByName(className) as Class;
			}
			catch (e:Error)
			{

			}
			return null;

		}

	}

}