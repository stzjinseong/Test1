package
{
	
	import flash.geom.Point;
	
	import starling.display.Button;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	public class Os extends Sprite
	{
		// data variable.
		public var nowSelectedWindow:Window;
		public var isSelecting:Boolean;
				
		// ui varialbe.
		[Embed(source = "assets/texture/icon.png")]
		private static const WindowIconBmp:Class;
		[Embed(source = "assets/texture/iconBar.png")]
		private static const WindowIconBarBmp:Class;
		private var icon:Button;
		
		
		public function Os(){			
			// ui variable.
			var iconBarTexture:Texture = Texture.fromEmbeddedAsset(WindowIconBarBmp);
			var iconTexture:Texture = Texture.fromEmbeddedAsset(WindowIconBmp);
			var iconBar:Quad = new Quad(2000, iconBarTexture.height);
			iconBar.texture = iconBarTexture;
			iconBar.y = 1000 - iconBarTexture.height;
			icon = new Button(iconTexture);
			icon.y = iconBar.y;
			
			// add child.
			addChild(iconBar);
			addChild(icon);
			
			// add listener.
			icon.addEventListener(TouchEvent.TOUCH, onClickWindow);
		}
		override public function dispose():void {
			icon.removeEventListeners();
		}
		private function onClickWindow(event:TouchEvent):void {
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
			if (touch) {
				// Create Window Object;
				var window1:Window = new Window(this);
				addChild(window1);
				var idx:int = getChildIndex(window1);
				window1.moveWindow(new Point(0,0), new Point((30 * idx) % 1500, (30 * idx) % 500));
			}
		}
	}
}