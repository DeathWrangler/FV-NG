package gs
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.ColorTransform;
   import flash.media.SoundChannel;
   import flash.utils.*;
   
   public class TweenLite
   {
      
      private static var _listening:Boolean;
      
      public static var version:Number = 6.04;
      
      public static var killDelayedCallsTo:Function = killTweensOf;
      
      protected static var _all:Dictionary = new Dictionary();
      
      private static var _sprite:Sprite = new Sprite();
      
      private static var _timer:Timer = new Timer(2000);
      
      public var duration:Number;
      
      public var vars:Object;
      
      public var delay:Number;
      
      public var startTime:uint;
      
      public var initTime:uint;
      
      public var tweens:Object;
      
      public var target:Object;
      
      protected var _active:Boolean;
      
      protected var _subTweens:Array;
      
      protected var _hst:Boolean;
      
      protected var _initted:Boolean;
      
      public function TweenLite(param1:Object, param2:Number, param3:Object)
      {
         super();
         if(param1 == null)
         {
            return;
         }
         if(param3.overwrite != false && param1 != null || _all[param1] == undefined)
         {
            delete _all[param1];
            _all[param1] = new Dictionary();
         }
         _all[param1][this] = this;
         this.vars = param3;
         this.duration = param2 || 0.001;
         this.delay = Number(param3.delay) || 0;
         this.target = param1;
         if(!(this.vars.ease is Function))
         {
            this.vars.ease = easeOut;
         }
         if(this.vars.easeParams != null)
         {
            this.vars.proxiedEase = this.vars.ease;
            this.vars.ease = this.easeProxy;
         }
         if(this.vars.mcColor != null)
         {
            this.vars.tint = this.vars.mcColor;
         }
         if(!isNaN(Number(this.vars.autoAlpha)))
         {
            this.vars.alpha = Number(this.vars.autoAlpha);
         }
         this.tweens = {};
         this._subTweens = [];
         this._hst = this._initted = false;
         this._active = param2 == 0 && this.delay == 0;
         this.initTime = getTimer();
         if(this.vars.runBackwards == true && this.vars.renderOnStart != true || this._active)
         {
            this.initTweenVals();
            this.startTime = getTimer();
            if(this._active)
            {
               this.render(this.startTime + 1);
            }
            else
            {
               this.render(this.startTime);
            }
         }
         if(!_listening && !this._active)
         {
            _sprite.addEventListener(Event.ENTER_FRAME,executeAll);
            _timer.addEventListener("timer",killGarbage);
            _timer.start();
            _listening = true;
         }
      }
      
      public static function to(param1:Object, param2:Number, param3:Object) : TweenLite
      {
         return new TweenLite(param1,param2,param3);
      }
      
      public static function from(param1:Object, param2:Number, param3:Object) : TweenLite
      {
         param3.runBackwards = true;
         return new TweenLite(param1,param2,param3);
      }
      
      public static function delayedCall(param1:Number, param2:Function, param3:Array = null, param4:* = null) : TweenLite
      {
         return new TweenLite(param2,0,{
            "delay":param1,
            "onComplete":param2,
            "onCompleteParams":param3,
            "onCompleteScope":param4,
            "overwrite":false
         });
      }
      
      public static function executeAll(param1:Event = null) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc2_:Dictionary = _all;
         var _loc3_:uint = uint(getTimer());
         for(_loc4_ in _loc2_)
         {
            for(_loc5_ in _loc2_[_loc4_])
            {
               if(_loc2_[_loc4_][_loc5_] != undefined && Boolean(_loc2_[_loc4_][_loc5_].active))
               {
                  _loc2_[_loc4_][_loc5_].render(_loc3_);
                  if(_loc2_[_loc4_] == undefined)
                  {
                     break;
                  }
               }
            }
         }
      }
      
      public static function removeTween(param1:TweenLite = null) : void
      {
         if(param1 != null && _all[param1.target] != undefined)
         {
            delete _all[param1.target][param1];
         }
      }
      
      public static function killTweensOf(param1:Object = null, param2:Boolean = false) : void
      {
         var _loc3_:Object = null;
         var _loc4_:* = undefined;
         if(param1 != null && _all[param1] != undefined)
         {
            if(param2)
            {
               _loc3_ = _all[param1];
               for(_loc4_ in _loc3_)
               {
                  _loc3_[_loc4_].complete(false);
               }
            }
            delete _all[param1];
         }
      }
      
      public static function killGarbage(param1:TimerEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc2_:uint = 0;
         for(_loc4_ in _all)
         {
            _loc3_ = false;
            var _loc9_:int = 0;
            var _loc10_:* = _all[_loc4_];
            for(_loc5_ in _loc10_)
            {
               _loc3_ = true;
            }
            if(!_loc3_)
            {
               delete _all[_loc4_];
            }
            else
            {
               _loc2_++;
            }
         }
         if(_loc2_ == 0)
         {
            _sprite.removeEventListener(Event.ENTER_FRAME,executeAll);
            _timer.removeEventListener("timer",killGarbage);
            _timer.stop();
            _listening = false;
         }
      }
      
      protected static function easeOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return -param3 * (param1 = param1 / param4) * (param1 - 2) + param2;
      }
      
      public static function tintProxy(param1:Object) : void
      {
         var _loc2_:Number = Number(param1.target.progress);
         var _loc3_:Number = 1 - _loc2_;
         param1.info.target.transform.colorTransform = new ColorTransform(param1.info.color.redMultiplier * _loc3_ + param1.info.endColor.redMultiplier * _loc2_,param1.info.color.greenMultiplier * _loc3_ + param1.info.endColor.greenMultiplier * _loc2_,param1.info.color.blueMultiplier * _loc3_ + param1.info.endColor.blueMultiplier * _loc2_,param1.info.color.alphaMultiplier * _loc3_ + param1.info.endColor.alphaMultiplier * _loc2_,param1.info.color.redOffset * _loc3_ + param1.info.endColor.redOffset * _loc2_,param1.info.color.greenOffset * _loc3_ + param1.info.endColor.greenOffset * _loc2_,param1.info.color.blueOffset * _loc3_ + param1.info.endColor.blueOffset * _loc2_,param1.info.color.alphaOffset * _loc3_ + param1.info.endColor.alphaOffset * _loc2_);
      }
      
      public static function frameProxy(param1:Object) : void
      {
         param1.info.target.gotoAndStop(Math.round(param1.target.frame));
      }
      
      public static function volumeProxy(param1:Object) : void
      {
         param1.info.target.soundTransform = param1.target;
      }
      
      public function initTweenVals(param1:Boolean = false, param2:String = "") : void
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:ColorTransform = null;
         var _loc8_:ColorTransform = null;
         var _loc9_:Object = null;
         var _loc3_:Boolean = this.target is DisplayObject;
         if(this.target is Array)
         {
            _loc5_ = this.vars.endArray || [];
            _loc6_ = 0;
            while(_loc6_ < _loc5_.length)
            {
               if(this.target[_loc6_] != _loc5_[_loc6_] && this.target[_loc6_] != undefined)
               {
                  this.tweens[_loc6_.toString()] = {
                     "o":this.target,
                     "p":_loc6_.toString(),
                     "s":this.target[_loc6_],
                     "c":_loc5_[_loc6_] - this.target[_loc6_]
                  };
               }
               _loc6_++;
            }
         }
         else
         {
            for(_loc4_ in this.vars)
            {
               if(!(_loc4_ == "ease" || _loc4_ == "delay" || _loc4_ == "overwrite" || _loc4_ == "onComplete" || _loc4_ == "onCompleteParams" || _loc4_ == "onCompleteScope" || _loc4_ == "runBackwards" || _loc4_ == "onUpdate" || _loc4_ == "onUpdateParams" || _loc4_ == "onUpdateScope" || _loc4_ == "autoAlpha" || _loc4_ == "onStart" || _loc4_ == "onStartParams" || _loc4_ == "onStartScope" || _loc4_ == "renderOnStart" || _loc4_ == "easeParams" || _loc4_ == "mcColor" || _loc4_ == "type" || param1 && param2.indexOf(" " + _loc4_ + " ") != -1))
               {
                  if(_loc4_ == "tint" && _loc3_)
                  {
                     _loc7_ = this.target.transform.colorTransform;
                     _loc8_ = new ColorTransform();
                     if(this.vars.alpha != undefined)
                     {
                        _loc8_.alphaMultiplier = this.vars.alpha;
                        delete this.vars.alpha;
                        delete this.tweens.alpha;
                     }
                     else
                     {
                        _loc8_.alphaMultiplier = this.target.alpha;
                     }
                     if(this.vars[_loc4_] != null && this.vars[_loc4_] != "")
                     {
                        _loc8_.color = this.vars[_loc4_];
                     }
                     this.addSubTween(tintProxy,{"progress":0},{"progress":1},{
                        "target":this.target,
                        "color":_loc7_,
                        "endColor":_loc8_
                     });
                  }
                  else if(_loc4_ == "frame" && _loc3_)
                  {
                     this.addSubTween(frameProxy,{"frame":this.target.currentFrame},{"frame":this.vars[_loc4_]},{"target":this.target});
                  }
                  else if(_loc4_ == "volume" && (_loc3_ || this.target is SoundChannel))
                  {
                     this.addSubTween(volumeProxy,this.target.soundTransform,{"volume":this.vars[_loc4_]},{"target":this.target});
                  }
                  else if(this.target.hasOwnProperty(_loc4_))
                  {
                     if(typeof this.vars[_loc4_] == "number")
                     {
                        this.tweens[_loc4_] = {
                           "o":this.target,
                           "p":_loc4_,
                           "s":this.target[_loc4_],
                           "c":this.vars[_loc4_] - this.target[_loc4_]
                        };
                     }
                     else
                     {
                        this.tweens[_loc4_] = {
                           "o":this.target,
                           "p":_loc4_,
                           "s":this.target[_loc4_],
                           "c":Number(this.vars[_loc4_])
                        };
                     }
                  }
               }
            }
         }
         if(this.vars.runBackwards == true)
         {
            for(_loc4_ in this.tweens)
            {
               _loc9_ = this.tweens[_loc4_];
               _loc9_.s += _loc9_.c;
               _loc9_.c *= -1;
            }
         }
         if(typeof this.vars.autoAlpha == "number")
         {
            this.target.visible = !(this.vars.runBackwards == true && this.target.alpha == 0);
         }
         this._initted = true;
      }
      
      protected function addSubTween(param1:Function, param2:Object, param3:Object, param4:Object = null) : void
      {
         var _loc5_:String = null;
         this._subTweens.push({
            "proxy":param1,
            "target":param2,
            "info":param4
         });
         for(_loc5_ in param3)
         {
            if(param2.hasOwnProperty(_loc5_))
            {
               if(typeof param3[_loc5_] == "number")
               {
                  this.tweens["st" + this._subTweens.length + "_" + _loc5_] = {
                     "o":param2,
                     "p":_loc5_,
                     "s":param2[_loc5_],
                     "c":param3[_loc5_] - param2[_loc5_]
                  };
               }
               else
               {
                  this.tweens["st" + this._subTweens.length + "_" + _loc5_] = {
                     "o":param2,
                     "p":_loc5_,
                     "s":param2[_loc5_],
                     "c":Number(param3[_loc5_])
                  };
               }
            }
         }
         this._hst = true;
      }
      
      public function render(param1:uint) : void
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:uint = 0;
         var _loc2_:Number = (param1 - this.startTime) / 1000;
         if(_loc2_ > this.duration)
         {
            _loc2_ = this.duration;
         }
         var _loc3_:Number = Number(this.vars.ease(_loc2_,0,1,this.duration));
         for(_loc5_ in this.tweens)
         {
            _loc4_ = this.tweens[_loc5_];
            _loc4_.o[_loc4_.p] = _loc4_.s + _loc3_ * _loc4_.c;
         }
         if(this._hst)
         {
            _loc6_ = 0;
            while(_loc6_ < this._subTweens.length)
            {
               this._subTweens[_loc6_].proxy(this._subTweens[_loc6_]);
               _loc6_++;
            }
         }
         if(this.vars.onUpdate != null)
         {
            this.vars.onUpdate.apply(this.vars.onUpdateScope,this.vars.onUpdateParams);
         }
         if(_loc2_ == this.duration)
         {
            this.complete(true);
         }
      }
      
      public function complete(param1:Boolean = false) : void
      {
         if(!param1)
         {
            if(!this._initted)
            {
               this.initTweenVals();
            }
            this.startTime = 0;
            this.render(this.duration * 1000);
            return;
         }
         if(typeof this.vars.autoAlpha == "number" && this.target.alpha == 0)
         {
            this.target.visible = false;
         }
         if(this.vars.onComplete != null)
         {
            this.vars.onComplete.apply(this.vars.onCompleteScope,this.vars.onCompleteParams);
         }
         removeTween(this);
      }
      
      protected function easeProxy(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return this.vars.proxiedEase.apply(null,arguments.concat(this.vars.easeParams));
      }
      
      public function get active() : Boolean
      {
         if(this._active)
         {
            return true;
         }
         if((getTimer() - this.initTime) / 1000 > this.delay)
         {
            this._active = true;
            this.startTime = this.initTime + this.delay * 1000;
            if(!this._initted)
            {
               this.initTweenVals();
            }
            else if(typeof this.vars.autoAlpha == "number")
            {
               this.target.visible = true;
            }
            if(this.vars.onStart != null)
            {
               this.vars.onStart.apply(this.vars.onStartScope,this.vars.onStartParams);
            }
            if(this.duration == 0.001)
            {
               --this.startTime;
            }
            return true;
         }
         return false;
      }
   }
}

