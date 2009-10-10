package com.mikechambers.pewpew.engine.gameobjects
{
	import com.mikechambers.pewpew.engine.events.FireEvent;
	import com.mikechambers.pewpew.utils.MathUtil;
	
	import com.mikechambers.pewpew.engine.events.TickEvent;		
	import com.mikechambers.pewpew.ui.GameController;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.DisplayObject;
	
	import flash.geom.Point;

	public class Ship extends GameObject
	{
		private var speed:Number = 3.0;
		//private var bounds:Rectangle;
		
		//private var target:Target;
		
		private var timer:Timer;
		private static const FIRE_INTERVAL:Number = 300;
		
		private var missileSound:PewSound;
		
		private var gameController:GameController;
		
		//Should we have this extend enemy? and rename it?
		public function Ship(bounds:Rectangle, 
										target:DisplayObject = null, 
										modifier:Number = 1,
										gameController:GameController = null)
		{
			
			super(bounds, target, modifier);
			
			
			this.gameController = gameController;
		}
		
		protected override function onStageAdded(e:Event):void
		{
			trace("onStageAdded");
			super.onStageAdded(e);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 
																	0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0,
																		true);

			timer = new Timer(FIRE_INTERVAL);
			timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
		}
		
		protected override function onStageRemoved(e:Event):void
		{
			trace("onStageRemoved");
			super.onStageRemoved(e);

			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			if(timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer = null;
			}
		}
		
		public function destroy():void
		{
			var s:ExplosionSound = new ExplosionSound();
			s.play();
		}
		
		protected override function onTick(e:TickEvent):void
		{			

			//hack to work around bug where extra event is broadcast even
			//after listener is removed
			if(!timer)
			{
				return;
			}

			
			if(!mouseDown)
			{
				return;
			}
			
			var radians:Number = gameController.angle;
			this.rotation = MathUtil.radiansToDegrees(radians);
			
			var vx:Number = Math.cos(radians) * speed;
			var vy:Number = Math.sin(radians) * speed;
	
			var tempX:Number = this.x + vx;
			var tempY:Number = this.y + vy;	
	
			if(tempX < bounds.left ||
				tempX > bounds.right ||
				tempY < bounds.top ||
				tempY > bounds.bottom)
			{
				trace("over");
				return;
			}					
						
			this.x += vx;
			this.y += vy;	
		}		
		
		public override function dealloc():void
		{
			trace("ship dealloc");
			super.dealloc();
			//removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			//removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			//removeEventListener(Event.REMOVED_FROM_STAGE, onStageRemoved);
			
			
			if(timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer = null;
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			target = null;
		}
		
		private var mouseDown:Boolean = false;
		private function onMouseDown(e:MouseEvent):void
		{			
			mouseDown = true;
			if(!timer.running)
			{
				timer.start();
			}
		}
		
		private function onMouseUp(e:MouseEvent):void
		{					
			mouseDown = false;	
			timer.stop();
		}		
		
		private function fire():void
		{
			if(!missileSound)
			{
				missileSound = new PewSound();
			}
			
			missileSound.play();
			
			var m:Missile = new Missile(this.rotation, bounds);
			var e:FireEvent = new FireEvent(FireEvent.FIRE);
			e.projectile = m;
			dispatchEvent(e);
		}
		
		var p1:Point = new Point();
		var p2:Point = new Point();
		private function getAngleToTarget():Number
		{			
			p1.x = __target.x;
			p1.y = __target.y;
			p2.x = this.x;
			p2.y = this.y;
			
			return MathUtil.getAngleBetweenPoints(p1, p2);
		}			
		
		private function onTimer(e:TimerEvent):void
		{
			fire();
		}
	}
}