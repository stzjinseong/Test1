package
{
	import flash.display.Sprite;
	
	import starling.core.Starling;
	
	[SWF(width="2000", height="1000", backgroundColor="#222222", frameRate="60")]
	public class Test1 extends Sprite
	{
		private var _starling:Starling;
		
		public function Test1()
		{
			_starling = new Starling(Os, stage);
			//_starling.showStats = true;
			_starling.start();
		}
	}
}