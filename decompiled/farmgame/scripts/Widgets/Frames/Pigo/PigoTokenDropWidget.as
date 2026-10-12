package Widgets.Frames.Pigo
{
   import Classes.Pigo.PigoEngine;
   import Classes.Pigo.PigoTokenParticle;
   import Widgets.Core.Base.ZwWidget;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public final class PigoTokenDropWidget extends ZwWidget
   {
      
      private static const VELOCITY:Number = 50;
      
      private static const LEFT:String = "left";
      
      private static const RIGHT:String = "right";
      
      private var m_xMin:Number;
      
      private var m_xMax:Number;
      
      private var m_moving:Boolean;
      
      private var m_direction:String = "right";
      
      private var m_lastTime:int;
      
      private var m_tokenSprite:Sprite;
      
      public function PigoTokenDropWidget(element:DisplayObject, xMin:Number, xMax:Number)
      {
         super(element);
         element.cacheAsBitmap = true;
         this.m_xMin = xMin;
         this.m_xMax = xMax;
         x = this.m_xMin;
      }
      
      override public function release() : void
      {
         if(this.m_tokenSprite)
         {
            (m_element as MovieClip).removeChild(this.m_tokenSprite);
            this.m_tokenSprite = null;
         }
         super.release();
      }
      
      public function start() : void
      {
         if(!this.m_moving)
         {
            Global.stage.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this.m_lastTime = GlobalEngine.currentTime;
            this.m_moving = true;
         }
      }
      
      public function stop() : void
      {
         if(this.m_moving)
         {
            Global.stage.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this.m_moving = false;
         }
      }
      
      public function set hasToken(value:Boolean) : void
      {
         if(!this.m_tokenSprite)
         {
            this.m_tokenSprite = new Sprite();
            this.m_tokenSprite.cacheAsBitmap = true;
            PigoTokenParticle.drawToken(this.m_tokenSprite,PigoEngine.TOKEN_RADIUS);
            (m_element as MovieClip).addChild(this.m_tokenSprite);
         }
         this.m_tokenSprite.visible = value;
      }
      
      private function onEnterFrame(event:Event) : void
      {
         var deltaTime:Number = NaN;
         var deltaX:Number = NaN;
         var testXPosition:Number = NaN;
         var finalXPosition:Number = NaN;
         if(m_element)
         {
            deltaTime = (GlobalEngine.currentTime - this.m_lastTime) / 1000;
            this.m_lastTime = GlobalEngine.currentTime;
            deltaX = VELOCITY * deltaTime;
            if(this.m_direction == RIGHT)
            {
               testXPosition = x + deltaX;
               if(testXPosition <= this.m_xMax)
               {
                  finalXPosition = testXPosition;
               }
               else
               {
                  finalXPosition = this.m_xMax - (testXPosition - this.m_xMax);
                  this.m_direction = LEFT;
               }
            }
            else
            {
               testXPosition = x - deltaX;
               if(testXPosition >= this.m_xMin)
               {
                  finalXPosition = testXPosition;
               }
               else
               {
                  finalXPosition = this.m_xMin + (testXPosition - this.m_xMin);
                  this.m_direction = RIGHT;
               }
            }
            x = finalXPosition;
         }
      }
   }
}

