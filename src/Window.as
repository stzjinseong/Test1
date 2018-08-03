package
{
	import flash.geom.Point;
	import flash.sampler.getSize;
	import flash.utils.setInterval;
	
	import starling.display.Button;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	public class Window extends DisplayObjectContainer
	{		
		private var game:Os;
				
		// data variable.
		public var depth:int;
		private var parent:Window;
		private var arr_child:Array;
		private var nowDragPos:Point;
		private var preDragPos:Point;
		
		// ui varialbe.
		[Embed(source = "assets/texture/button_30x30.png")]
		private static const WindowButtonBmp:Class;
		[Embed(source = "assets/texture/buttonHover_30x30.png")]
		private static const WindowButtonHoverBmp:Class;
		private var qd_bg_title:Quad;
		private var qd_bg_page:Quad;
		private var spr_window:Sprite;
		private var spr_title:Sprite;
		private var spr_page:Sprite;
		private var qd_titleBar:Quad;
		private var qd_page:Quad;
		private var tf_titleText:TextField;
		private var bt_minimize:Button;
		private var bt_close:Button;

		public function Window(_game:Os) {
			// init data variable..
			game = _game;
			arr_child = new Array();
			
			// init texture.
			var btTexture:Texture = Texture.fromEmbeddedAsset(WindowButtonBmp);
			var btHoverTexture:Texture = Texture.fromEmbeddedAsset(WindowButtonHoverBmp);
			
			// init ui varialbe.
			qd_bg_title = new Quad(EWindowConst.DEFAULT_WINDOW_WIDTH + 2, EWindowConst.DEFAULT_TITLE_HEIGHT + 2, Color.SILVER);
			qd_bg_title.x -= 1;
			qd_bg_title.y -= 1;
			qd_bg_page = new Quad(EWindowConst.DEFAULT_WINDOW_WIDTH + 2, EWindowConst.DEFAULT_PAGE_HEIGHT + 1, Color.SILVER);
			qd_bg_page.x -= 1;
			qd_bg_page.y += EWindowConst.DEFAULT_TITLE_HEIGHT;
			spr_window = new Sprite();
			spr_title = new Sprite();
			spr_page = new Sprite();
			qd_titleBar = new Quad(EWindowConst.DEFAULT_WINDOW_WIDTH, EWindowConst.DEFAULT_TITLE_HEIGHT, Color.WHITE);
			tf_titleText = new TextField(EWindowConst.DEFAULT_WINDOW_WIDTH, EWindowConst.DEFAULT_TITLE_HEIGHT, "Window");
			tf_titleText.touchable = false;
			qd_page = new Quad(EWindowConst.DEFAULT_WINDOW_WIDTH, EWindowConst.DEFAULT_PAGE_HEIGHT, Color.WHITE);
			qd_page.y = qd_titleBar.height;
			bt_minimize = new Button(btTexture, "-");
			bt_close = new Button(btTexture, "X");
			bt_minimize.overState = btHoverTexture;
			bt_close.overState = btHoverTexture;
			bt_minimize.x = qd_titleBar.width - EWindowConst.DEFAULT_BUTTON_WIDTH * 2;
			bt_close.x = qd_titleBar.width - EWindowConst.DEFAULT_BUTTON_WIDTH;
			
			// add child.
			qd_bg_title.touchable = false;
			spr_title.addChild(qd_bg_title);
			spr_page.addChild(qd_bg_page);
			spr_title.addChild(qd_titleBar);
			spr_title.addChild(tf_titleText);
			spr_title.addChild(bt_minimize);
			spr_title.addChild(bt_close);
			spr_page.addChild(qd_page);
			spr_page.addChild(new Fishing());
			spr_window.addChild(spr_title);
			spr_window.addChild(spr_page);
			addChild(spr_window);
						
			// add listeners.
			qd_titleBar.addEventListener(TouchEvent.TOUCH, onDragStart);
			qd_titleBar.addEventListener(TouchEvent.TOUCH, onDragging);
			qd_titleBar.addEventListener(TouchEvent.TOUCH, onDragEnd);
			spr_window.addEventListener(TouchEvent.TOUCH, onHover);	
			bt_minimize.addEventListener(TouchEvent.TOUCH, onClickMinimize);
			bt_close.addEventListener(TouchEvent.TOUCH, onClickClose);
		}
		private function onHover(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this, TouchPhase.HOVER);
			if (touch)
			{
				// drag&drop된 윈도우 객체가 없는가? 
				if (game.nowSelectedWindow == null){	
					return;
				}
					// drag&drop된 윈도우 객체가 this인가?
				else if (game.nowSelectedWindow == this) {
					trace("Hover: 자신이라 셀렉팅 윈도우 소멸");
					game.nowSelectedWindow = null;
				}
					// drag&drop된 윈도우 객체가 자식리스트에 없고 drag&drop된 윈도우 객체의 자식리스트에 this가 없는가? 
				else if(!isContain(game.nowSelectedWindow) 
					&& !game.nowSelectedWindow.isContain(this) 
					&& game.nowSelectedWindow.parent == null){
					trace("Hover: 셀렉팅 윈도우를 자식으로 붙임");
					// regist selected windows to child-array.
					addChildWindow();
					game.nowSelectedWindow = null;
				}
			}
		}
		private function onDragStart(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);		
			if (touch)
			{
				// move to top-layer.
				if (parent == null){
					game.setChildIndex(this, 0);
				}			
				preDragPos = touch.getLocation(this);
				game.nowSelectedWindow = this;
				
			}
		}
		private function onDragging(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this, TouchPhase.MOVED);
			if (touch)
			{
				// update now drag position.
				nowDragPos = touch.getLocation(this);
				
				// move child.
				updatePos(preDragPos, nowDragPos);
				
				// save pre dragging position.
				preDragPos = nowDragPos
			}
		}
		private function onDragEnd(event:TouchEvent):void {
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
			if (touch)
			{				
				if (parent != null) {
					parent.setChildIndex(this, parent.numChildren);
				}
			}
		}
		private function onClickMinimize(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
			if (touch)
			{
				if (spr_page.visible) {
					spr_page.visible = false;
				}
				else if (!spr_page.visible){
					spr_page.visible = true;
				}
			}
		}
		private function onClickClose(event:TouchEvent):void {
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
			if (touch)
			{
				// 부모 윈도우 객체로부터 참조를 없앤다.
				if (parent != null) {
					var idx:int = parent.arr_child.indexOf(this);
					if (idx != -1) {
						parent.arr_child.removeAt(parent.arr_child.indexOf(this));
					}
				}
				
				// this 객체 리소스 해제.
				this.removeFromParent();
				this.dispose();
			}
		}
		
		public function isContain(obj:Window):Boolean {
			if (arr_child.indexOf(obj) == -1)
				return false;
			else 
				return true;
		}
		public function setParent(_parent:Window):void
		{
			parent = _parent;
		}
		private function addChildWindow():void {
			// 
			game.nowSelectedWindow.depth = depth;
			game.setChildIndex(game.nowSelectedWindow, game.nowSelectedWindow.depth);
			
			// push.
			addChild(game.nowSelectedWindow);
			arr_child.push(game.nowSelectedWindow);
			game.nowSelectedWindow.setParent(this);
			game.nowSelectedWindow = null;
		}
		private function updatePos(prePos:Point, nowPos:Point):void {
			// own.
			moveWindow(prePos, nowPos);
			
			// child.
			for (var idx:int = 0; idx < arr_child.length; idx++) {
				arr_child[idx].updatePos(prePos, nowPos);
			}
		}
		public function moveWindow(prePos:Point, nowPos:Point):void {
			spr_title.x += (nowPos.x - prePos.x);
			spr_title.y += (nowPos.y - prePos.y);
			spr_page.x += (nowPos.x - prePos.x);
			spr_page.y += (nowPos.y - prePos.y);
		}
	}
} 