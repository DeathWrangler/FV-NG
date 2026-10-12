package Widgets.Core.ProgressBars
{
   import Widgets.Core.Base.ZwWidget;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import gs.TweenLite;
   
   public class ZwAbstractProgressBar extends ZwWidget
   {
      
      public static const DIRECTION_RIGHT:String = "right";
      
      public static const DIRECTION_LEFT:String = "left";
      
      public static const DIRECTION_UP:String = "up";
      
      public static const DIRECTION_DOWN:String = "down";
      
      private static const TWEEN_TIME:Number = 0.25;
      
      protected var m_bar:DisplayObject;
      
      protected var m_glow:DisplayObject;
      
      protected var m_initialPosition:Object = new Object();
      
      protected var m_initialSize:Object = new Object();
      
      protected var m_progress:Number = 0;
      
      protected var m_oldProgress:Number = 0;
      
      protected var m_maximum:Number = 100;
      
      protected var m_minimum:Number = 0;
      
      protected var m_direction:String = "right";
      
      protected var m_animated:Boolean = false;
      
      protected var m_tweenTime:Number;
      
      protected var m_currentTween:TweenLite = null;
      
      public function ZwAbstractProgressBar(element:DisplayObject)
      {
         super(element);
         this.m_bar = this.getBarInstanceMC();
         this.m_initialPosition.x = this.m_bar.x;
         this.m_initialPosition.y = this.m_bar.y;
         this.m_initialSize.width = this.m_bar.width;
         this.m_initialSize.height = this.m_bar.height;
         this.m_tweenTime = TWEEN_TIME;
         this.update();
      }
      
      override public function release() : void
      {
         this.m_bar = null;
         this.m_initialPosition = null;
         this.m_initialSize = null;
         super.release();
      }
      
      public function reset() : void
      {
         this.m_progress = this.m_minimum;
         this.m_bar.x = this.m_initialPosition.x;
         this.m_bar.y = this.m_initialPosition.y;
         this.m_bar.width = this.m_initialSize.width;
         this.m_bar.height = this.m_initialSize.height;
         this.update();
      }
      
      public function getBarInstanceMC() : DisplayObject
      {
         return m_element[this.getBarInstanceName()];
      }
      
      public function get animated() : Boolean
      {
         return this.m_animated;
      }
      
      public function set animated(value:Boolean) : void
      {
         this.m_animated = value;
         if(value == true)
         {
            if(this.m_glow)
            {
               this.m_glow = m_element["glow_mc"];
               this.m_glow.visible = false;
            }
         }
         else
         {
            this.m_glow = null;
         }
      }
      
      public function get progress() : Number
      {
         return this.m_progress;
      }
      
      public function set progress(value:Number) : void
      {
         if(value > this.m_maximum)
         {
            value = this.m_maximum;
         }
         else if(value < this.m_minimum)
         {
            value = this.m_minimum;
         }
         if(this.m_progress != value)
         {
            this.m_oldProgress = this.m_progress;
            this.m_progress = value;
            this.update();
         }
      }
      
      public function get maximum() : Number
      {
         return this.m_maximum;
      }
      
      public function set maximum(value:Number) : void
      {
         if(value > this.m_minimum)
         {
            this.m_maximum = value;
            this.reset();
         }
      }
      
      public function get minimum() : Number
      {
         return this.m_minimum;
      }
      
      public function set minimum(value:Number) : void
      {
         if(value < this.m_maximum)
         {
            this.m_minimum = value;
            this.reset();
         }
      }
      
      public function get direction() : String
      {
         return this.m_direction;
      }
      
      public function set direction(value:String) : void
      {
         if(this.m_direction != value)
         {
            this.m_direction = value;
            this.reset();
         }
      }
      
      public function get tweenTime() : Number
      {
         return this.m_tweenTime;
      }
      
      public function set tweenTime(value:Number) : void
      {
         this.m_tweenTime = value;
      }
      
      public function get percentComplete() : Number
      {
         return Math.floor((this.m_progress - this.m_minimum) / this.m_maximum * 100);
      }
      
      public function getBarInstanceName() : String
      {
         throw new Error("Error: Abstract Function: Need to override ZwAbstractProgressBar:getBarInstanceName.");
      }
      
      protected function update() : void
      {
         var currentPercentComplete:Number;
         var desiredWidth:Number;
         var desiredHeight:Number;
         var desiredX:Number;
         var desiredY:Number;
         if(this.m_currentTween)
         {
            TweenLite.removeTween(this.m_currentTween);
            this.m_currentTween = null;
         }
         currentPercentComplete = (this.m_progress - this.m_minimum) / this.m_maximum;
         desiredWidth = this.m_bar.width;
         desiredHeight = this.m_bar.height;
         desiredX = this.m_bar.x;
         desiredY = this.m_bar.y;
         switch(this.m_direction)
         {
            case DIRECTION_LEFT:
               desiredWidth = Math.floor(currentPercentComplete * this.m_initialSize.width);
               desiredX = this.m_initialPosition.x + this.m_initialSize.width - desiredWidth;
               break;
            case DIRECTION_UP:
               desiredHeight = Math.floor(currentPercentComplete * this.m_initialSize.height);
               desiredY = this.m_initialPosition.y + this.m_initialSize.height - desiredHeight;
               break;
            case DIRECTION_DOWN:
               desiredHeight = Math.floor(currentPercentComplete * this.m_initialSize.height);
               break;
            case DIRECTION_RIGHT:
            default:
               desiredWidth = Math.floor(currentPercentComplete * this.m_initialSize.width);
         }
         if(this.animated)
         {
            this.m_currentTween = TweenLite.to(this.m_bar,this.m_tweenTime,{
               "width":desiredWidth,
               "height":desiredHeight,
               "x":desiredX,
               "y":desiredY,
               "onComplete":function():void
               {
                  m_currentTween = null;
                  dispatchEvent(new Event(Event.COMPLETE));
               }
            });
            this.flashProgressBar();
         }
         else
         {
            this.m_bar.width = desiredWidth;
            this.m_bar.height = desiredHeight;
            this.m_bar.x = desiredX;
            this.m_bar.y = desiredY;
         }
      }
      
      protected function flashProgressBar(numFlashes:Number = 1, duration:Number = 0.7) : void
      {
         if(this.m_glow)
         {
            this.m_glow.visible = true;
            if(numFlashes > 0)
            {
               TweenLite.to(this.m_glow,duration,{
                  "alpha":1,
                  "onComplete":this.glowTweendown,
                  "onCompleteParams":[numFlashes - 1,duration]
               });
            }
            else
            {
               this.m_glow.visible = false;
            }
         }
      }
      
      private function glowTweendown(numFlashes:Number, duration:Number) : void
      {
         TweenLite.to(this.m_glow,duration,{
            "alpha":0.1,
            "onComplete":this.flashProgressBar,
            "onCompleteParams":[numFlashes,duration]
         });
      }
   }
}

