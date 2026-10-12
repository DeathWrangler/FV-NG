package zasp.Classes
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import zasp.Display.FullRedrawForcer;
   import zasp.Display.FunkySpinner;
   import zasp.Util.CircularBuffer;
   import zasp.Util.SumSampler;
   
   public class ZaspTrackerDebug
   {
      
      protected var spinnerF2F:FunkySpinner = null;
      
      protected var spinnerEMA:FunkySpinner = null;
      
      protected var spinnerOEF:FunkySpinner = null;
      
      protected var fullRedraw:FullRedrawForcer = null;
      
      protected var keysActive:Boolean = false;
      
      protected var m_sprite:Sprite = null;
      
      protected var baseTracker:ZaspTrackerBase = null;
      
      protected var useSpinnerOef:Boolean = false;
      
      public function ZaspTrackerDebug(param1:ZaspTrackerBase, param2:Boolean = false)
      {
         super();
         CircularBuffer.test();
         SumSampler.test();
         this.baseTracker = param1;
         this.useSpinnerOef = param2;
         this.m_sprite = new Sprite();
         this.m_sprite.addEventListener(Event.ADDED_TO_STAGE,this.added_to_stage,false,0,true);
      }
      
      public function sample(param1:Number, param2:Number) : void
      {
         if(null != this.spinnerF2F)
         {
            this.spinnerF2F.sample(param1);
         }
         if(null != this.spinnerEMA)
         {
            this.spinnerEMA.sample(this.baseTracker.f2f);
         }
         if(null != this.spinnerOEF)
         {
            this.spinnerOEF.sample(param2);
         }
      }
      
      private function added_to_stage(param1:Event) : void
      {
         this.m_sprite.removeEventListener(Event.ADDED_TO_STAGE,this.added_to_stage,false);
         this.m_sprite.addEventListener(Event.REMOVED_FROM_STAGE,this.removed_from_stage,false,0,true);
         this.m_sprite.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.key_down,false,0,true);
      }
      
      private function removed_from_stage(param1:Event) : void
      {
         this.m_sprite.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.key_down,false);
         this.m_sprite.removeEventListener(Event.REMOVED_FROM_STAGE,this.removed_from_stage,false);
         this.m_sprite.addEventListener(Event.ADDED_TO_STAGE,this.added_to_stage,false,0,true);
      }
      
      private function key_down(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(param1.keyCode == 219)
         {
            this.keyCapture = !this.keyCapture;
            if(this.keyCapture)
            {
            }
         }
         if(!this.keyCapture)
         {
            return;
         }
         switch(param1.keyCode)
         {
            case 82:
               this.baseTracker.log_report();
               break;
            case 49:
               _loc2_ = this.recurse(this.m_sprite.stage,this.isCacheAsBitmap,this.disable_CacheAsBitmap);
               break;
            case 50:
               _loc2_ = this.recurse(this.m_sprite.stage,this.isAnything,this.enable_CacheAsBitmap);
               break;
            case 51:
               _loc2_ = this.recurse(this.m_sprite.stage,this.isShape,this.toggle_CacheAsBitmap);
               break;
            case 52:
               _loc2_ = this.recurse(this.m_sprite.stage,this.isSprite,this.toggle_CacheAsBitmap);
               break;
            case 54:
               if(this.areSpinnersActive)
               {
                  this.deactivateSpinners();
               }
               else
               {
                  this.activateSpinners();
               }
               break;
            case 55:
               if(this.isFullRedrawActive)
               {
                  this.deactivateFullRedraw();
               }
               else
               {
                  this.activateFullRedraw();
               }
               break;
            case 56:
               if(this.m_sprite.parent != null)
               {
                  this.m_sprite.parent.setChildIndex(this.m_sprite,this.m_sprite.parent.numChildren - 1);
               }
               break;
            case 48:
               _loc2_ = this.recurse(this.m_sprite.stage,this.isEmpty,this.log);
               break;
            case 86:
               _loc2_ = this.recurse(this.m_sprite.stage,this.isAnything,this.prune_empties);
               break;
            case 57:
               _loc3_ = this.recurse(this.m_sprite.stage,this.isAnything,this.nothing);
               _loc4_ = this.recurse(this.m_sprite.stage,this.isCacheAsBitmap,this.nothing);
               _loc5_ = this.recurse(this.m_sprite.stage,this.isNotCacheAsBitmap,this.nothing);
               _loc6_ = this.recurse(this.m_sprite.stage,this.isShape,this.nothing);
               _loc7_ = this.recurse(this.m_sprite.stage,this.isSprite,this.nothing);
               _loc8_ = this.recurse(this.m_sprite.stage,this.isEmpty,this.nothing);
         }
      }
      
      public function log_report() : void
      {
      }
      
      private function log(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(null != _loc2_)
         {
         }
      }
      
      private function recurse(param1:DisplayObject, param2:Function, param3:Function) : int
      {
         var _loc6_:int = 0;
         if(null == param1)
         {
            return 0;
         }
         var _loc4_:int = 0;
         if(param2(param1))
         {
            _loc4_ += 1;
            param3(param1);
         }
         var _loc5_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(null != _loc5_)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc5_.numChildren)
            {
               _loc4_ += this.recurse(_loc5_.getChildAt(_loc6_),param2,param3);
               _loc6_++;
            }
         }
         return _loc4_;
      }
      
      private function isShape(param1:DisplayObject) : Boolean
      {
         return param1 is Shape;
      }
      
      private function isSprite(param1:DisplayObject) : Boolean
      {
         return param1 is Sprite;
      }
      
      private function isCacheAsBitmap(param1:DisplayObject) : Boolean
      {
         return param1.cacheAsBitmap;
      }
      
      private function isNotCacheAsBitmap(param1:DisplayObject) : Boolean
      {
         return !this.isCacheAsBitmap(param1);
      }
      
      private function isFunkySpinner(param1:DisplayObject) : Boolean
      {
         return param1 is FunkySpinner;
      }
      
      private function isAnything(param1:DisplayObject) : Boolean
      {
         return param1 != this.m_sprite.stage;
      }
      
      private function togleVisibility(param1:DisplayObject) : void
      {
         param1.visible = !param1.visible;
      }
      
      private function toggle_CacheAsBitmap(param1:DisplayObject) : void
      {
         param1.cacheAsBitmap = !param1.cacheAsBitmap;
      }
      
      private function enable_CacheAsBitmap(param1:DisplayObject) : void
      {
         param1.cacheAsBitmap = true;
      }
      
      private function disable_CacheAsBitmap(param1:DisplayObject) : void
      {
         param1.cacheAsBitmap = false;
      }
      
      private function nothing(param1:DisplayObject) : void
      {
      }
      
      public function get areSpinnersActive() : Boolean
      {
         if(null != this.spinnerF2F)
         {
            return true;
         }
         if(null != this.spinnerEMA)
         {
            return true;
         }
         if(null != this.spinnerOEF)
         {
            return true;
         }
         return false;
      }
      
      public function get sprite() : Sprite
      {
         return this.m_sprite;
      }
      
      public function activateSpinners() : void
      {
         var r:Number;
         var x:Number;
         var y:Number;
         if(this.areSpinnersActive)
         {
            return;
         }
         this.deactivateSpinners();
         r = 50;
         x = 475;
         y = 5 + r;
         this.spinnerEMA = new FunkySpinner(x,y,r);
         x += 1.4 * r;
         this.spinnerF2F = new FunkySpinner(x,y,r);
         x += 1.4 * r;
         if(this.useSpinnerOef)
         {
            this.spinnerOEF = new FunkySpinner(x,y,r);
         }
         try
         {
            this.m_sprite.addChild(this.spinnerF2F);
            this.m_sprite.addChild(this.spinnerEMA);
            if(null != this.spinnerOEF)
            {
               this.m_sprite.addChild(this.spinnerOEF);
            }
         }
         catch(err:Error)
         {
            spinnerF2F = null;
            spinnerEMA = null;
            spinnerOEF = null;
            throw err;
         }
      }
      
      public function deactivateSpinners() : void
      {
         if(null != this.spinnerF2F)
         {
            this.m_sprite.removeChild(this.spinnerF2F);
         }
         if(null != this.spinnerEMA)
         {
            this.m_sprite.removeChild(this.spinnerEMA);
         }
         if(null != this.spinnerOEF)
         {
            this.m_sprite.removeChild(this.spinnerOEF);
         }
         this.spinnerF2F = null;
         this.spinnerEMA = null;
         this.spinnerOEF = null;
      }
      
      public function get isFullRedrawActive() : Boolean
      {
         return null != this.fullRedraw;
      }
      
      public function activateFullRedraw() : void
      {
         if(this.isFullRedrawActive)
         {
            return;
         }
         this.deactivateFullRedraw();
         this.fullRedraw = new FullRedrawForcer();
         try
         {
            this.m_sprite.addChild(this.fullRedraw);
         }
         catch(err:Error)
         {
            fullRedraw = null;
            throw err;
         }
      }
      
      public function deactivateFullRedraw() : void
      {
         if(null != this.fullRedraw)
         {
            this.m_sprite.removeChild(this.fullRedraw);
         }
         this.fullRedraw = null;
      }
      
      public function get keyCapture() : Boolean
      {
         return this.keysActive;
      }
      
      public function set keyCapture(param1:Boolean) : void
      {
         this.keysActive = param1;
      }
      
      private function isEmpty(param1:DisplayObject) : Boolean
      {
         if(!param1.visible)
         {
            return true;
         }
         if(param1.width != 0)
         {
            return false;
         }
         if(param1.height != 0)
         {
            return false;
         }
         var _loc2_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(null == _loc2_)
         {
            return true;
         }
         return _loc2_.numChildren <= 0;
      }
      
      private function prune_empties(param1:DisplayObject) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc2_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(null == _loc2_)
         {
            return;
         }
         var _loc3_:* = int(_loc2_.numChildren - 1);
         while(_loc3_ >= 0)
         {
            _loc4_ = _loc2_.getChildAt(_loc3_);
            if(this.isEmpty(_loc4_))
            {
               _loc2_.removeChildAt(_loc3_);
            }
            _loc3_--;
         }
      }
   }
}

