package
{
	import com.conceptualideas.chat.plugins.IPluginFactory;
	import com.conceptualideas.chat.plugins.PluginInfo;
	import com.conceptualideas.chat.plugins.video.VideoChatPlugin;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;

	import flash.system.Security;

	[Frame(factoryClass="VideoChat")]
	public class VideoChat extends Sprite implements IPluginFactory
	{
		public function VideoChat()
		{
			Security.allowDomain("*");
		}

		public function getPlugins():Vector.<PluginInfo>
		{
			return Vector.<PluginInfo>([new PluginInfo(VideoChatPlugin)
				]);
		}
	/*	override public function create(... params):Object
		{
			if (params.length > 0 && !(params[0] is String))
				return super.create.apply(this, params);

			var mainClassName:String = params.length == 0 ? "VideoChat" : String(params[0]);
			var mainClass:Class = Class(getDefinitionByName(mainClassName));
			if (!mainClass)
				return null;

			var instance:Object = new mainClass();
		
			return instance;
		}*/
	}
}