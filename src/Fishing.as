package
{
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.utils.Color;

	public class Fishing extends Sprite
	{
		// data varialbe.
		public var _this:Fishing;
		private var arr_targetIdx:Array;
		private var arr_targetImg:Array;
		private var targetRemovePoint:int;
		
		// ui varialbe.
		[Embed(source = "assets/texture/fish0.png")]
		private static const Fish0Bmp:Class;
		[Embed(source = "assets/texture/fish1.png")]
		private static const Fish1Bmp:Class;
		private var fish0Texture:Texture;
		private var fish1Texture:Texture;
		private var bt_left:Button;
		private var bt_right:Button;
		private var qd_processBar:Quad;
		private var qd_bg_processBar:Quad;
		
		public function Fishing()
		{
			// init data varialbe.
			_this = this;
			arr_targetIdx = new Array();
			arr_targetImg = new Array();
			targetRemovePoint = 0;
					
			// init texture.
			fish0Texture = Texture.fromEmbeddedAsset(Fish0Bmp);
			fish1Texture = Texture.fromEmbeddedAsset(Fish1Bmp);
			
			initTargetData();
			
			// init ui varialbe.
			bt_left = new Button(fish0Texture);
			bt_right = new Button(fish1Texture);
			bt_left.x = EWindowConst.DEFAULT_WINDOW_WIDTH * 0.5 - fish0Texture.width - 50;
			bt_left.y = EWindowConst.DEFAULT_PAGE_HEIGHT - EWindowConst.DEFAULT_BUTTON_WIDTH - 50;
			bt_right.x = EWindowConst.DEFAULT_WINDOW_WIDTH * 0.5 + 50;
			bt_right.y = EWindowConst.DEFAULT_PAGE_HEIGHT - EWindowConst.DEFAULT_BUTTON_WIDTH - 50;
			qd_bg_processBar = new Quad(EWindowConst.DEFAULT_WINDOW_WIDTH * 0.5, 20, Color.WHITE);
			qd_bg_processBar.x = EWindowConst.DEFAULT_WINDOW_WIDTH * 0.25;
			qd_bg_processBar.y = EWindowConst.DEFAULT_PAGE_HEIGHT * 0.25;
			qd_processBar = new Quad(0.1, 20, Color.GRAY);
			qd_processBar.x = EWindowConst.DEFAULT_WINDOW_WIDTH * 0.25;
			qd_processBar.y = EWindowConst.DEFAULT_PAGE_HEIGHT * 0.25;
			
			// add child.
			addChild(bt_left);
			addChild(bt_right);
			addChild(qd_bg_processBar);
			addChild(qd_processBar);
						
			// add listener.
			bt_left.addEventListener(TouchEvent.TOUCH, onClickLeft);
			bt_right.addEventListener(TouchEvent.TOUCH, onClickRight);
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		private function onAdded(e:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			// press "A"
			if (event.keyCode == 65) {
				if (arr_targetIdx[targetRemovePoint] == EFishConst.FISH_0) {
					removeTarget();
				}
			}
			// press "D";
			else if (event.keyCode == 68) {
				if (arr_targetIdx[targetRemovePoint] == EFishConst.FISH_1) {
					removeTarget();
				}
			}
		}
		
		private function onClickLeft(event:TouchEvent):void {
			var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
			if (touch)
			{
				if (arr_targetIdx[targetRemovePoint] == EFishConst.FISH_0) {
					removeTarget();
				}
			}
		}
		
		private function onClickRight(event:TouchEvent):void {
			var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
			if (touch)
			{
				if (arr_targetIdx[targetRemovePoint] == EFishConst.FISH_1) {
					removeTarget();
				}
			}
		}
		
		private function removeTarget():void {
			if (!isEmptyTarget()) {
				// perform tween.
				var fish_tw:Tween = new Tween(arr_targetImg[targetRemovePoint], 1.0, Transitions.EASE_OUT_BOUNCE);
				fish_tw.moveTo(arr_targetImg[targetRemovePoint].x, arr_targetImg[targetRemovePoint].y - 70);
				Starling.juggler.add(fish_tw);
				fish_tw.onCompleteArgs = [targetRemovePoint];
				fish_tw.onComplete = function(_targetRemovePoint:int):void
				{
					if (_targetRemovePoint == EFishConst.MAX_FISH - 1) {
						fish_tw.target.removeFromParent(true);
						
						// remove window.
						if (isEmptyTarget()) {
							bt_left.removeEventListeners();
							bt_right.removeEventListeners();
							
							_this.parent.parent.parent.removeFromParent(true);
						}
					}
				}
				targetRemovePoint++;
				
				// change processBar value.
				qd_processBar.width += EWindowConst.DEFAULT_WINDOW_WIDTH * 0.5 / 6;
			}
		}
		private function onComplete(fish:Quad):void {
			fish.removeFromParent(true);
		}
		private function isEmptyTarget():Boolean {
			if (targetRemovePoint == EFishConst.MAX_FISH)
				return true;
			else 
				return false;
		}
		
		private function initTargetData():void {
			// init fishing target array.
			for (var idx:int = 0; idx < EFishConst.MAX_FISH; idx++){
				arr_targetIdx.push(Math.round(Math.random()));		
			}
			
			// init fishing target image.
			for (idx = 0; idx < EFishConst.MAX_FISH; idx++){	
				var qd:Quad;
				if (arr_targetIdx[idx] == EFishConst.FISH_0) {
					qd = new Quad(fish0Texture.width * 0.5, fish0Texture.height * 0.5);
					qd.texture = fish0Texture;
				}
				else if (arr_targetIdx[idx] == EFishConst.FISH_1) {
					qd = new Quad(fish1Texture.width * 0.5, fish1Texture.height * 0.5);
					qd.texture = fish1Texture;
				}
				
				qd.x = idx * 60 + 30;
				qd.y = EWindowConst.DEFAULT_TITLE_HEIGHT + EWindowConst.DEFAULT_PAGE_HEIGHT * 0.5;
				addChild(qd);
				arr_targetImg.push(qd);
			}
		}
	}
}