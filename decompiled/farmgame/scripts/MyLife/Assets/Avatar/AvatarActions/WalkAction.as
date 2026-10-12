package MyLife.Assets.Avatar.AvatarActions
{
   import MyLife.MyLifeInstance;
   import com.boostworthy.animation.easing.Transitions;
   import com.boostworthy.animation.rendering.RenderMethod;
   import com.boostworthy.animation.sequence.Timeline;
   import com.boostworthy.animation.sequence.tweens.Action;
   import com.boostworthy.animation.sequence.tweens.Tween;
   import com.boostworthy.events.AnimationEvent;
   import fai.*;
   import fl.motion.easing.*;
   import flash.display.MovieClip;
   
   public class WalkAction extends AnimationAction
   {
      
      private static var isRegistered:Boolean = false;
      
      protected var walkPath:Array;
      
      protected var walkSpeed:Number;
      
      protected var timeline:Timeline;
      
      protected var walkLength:Number;
      
      protected var isWalking:Boolean;
      
      public function WalkAction(param1:String, param2:MovieClip, param3:Object, param4:Number = 2, param5:Boolean = false)
      {
         param3.l = AnimationAction.LOOP;
         if(param3.animName == null)
         {
            param3.animName = "walk";
         }
         super(param1,param2,param3,param4,param5);
         this.walkPath = param3.walkPath;
         if(!(this.walkPath[0] is Position))
         {
            this.convertObjectsToPositions();
         }
         this.walkPath[0] = this.characterClip.getPosition();
         this.walkSpeed = param3.walkSpeed;
         this.prepareWalkTweens();
         this.isWalking = false;
      }
      
      public static function registerAction() : void
      {
         ActionLibrary.registerActionClass(WalkAction,"walk");
      }
      
      protected function convertObjectsToPositions() : void
      {
         var _loc2_:Position = null;
         var _loc1_:Number = 0;
         while(_loc1_ < this.walkPath.length)
         {
            _loc2_ = new Position(this.walkPath[_loc1_].x,this.walkPath[_loc1_].y);
            this.walkPath[_loc1_] = _loc2_;
            _loc1_++;
         }
      }
      
      public function prepareWalkTweens() : void
      {
         var _loc4_:Position = null;
         var _loc8_:Position = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc1_:Boolean = this.timeline == null;
         this.walkLength = 0;
         var _loc2_:Number = 1;
         var _loc3_:Number = 1;
         this.timeline = new Timeline(RenderMethod.ENTER_FRAME);
         var _loc5_:Number = -1;
         var _loc6_:Position = this.walkPath[this.walkPath.length - 1];
         _loc4_ = new Position(characterClip.x,characterClip.y);
         var _loc7_:Number = 50 / this.walkSpeed;
         for each(_loc8_ in this.walkPath)
         {
            _loc9_ = _loc8_.deltaPosition(_loc4_).vectorLength();
            if(_loc9_ > 0)
            {
               this.walkLength += _loc9_;
               _loc3_ = _loc9_ * _loc7_;
               this.timeline.addTween(new Tween(characterClip,"x",_loc8_.x,_loc2_,_loc2_ + _loc3_,Transitions.LINEAR));
               this.timeline.addTween(new Tween(characterClip,"y",_loc8_.y,_loc2_,_loc2_ + _loc3_,Transitions.LINEAR));
               _loc10_ = this.getDirectionFromDelta(_loc8_.deltaPosition(_loc4_),_loc6_.deltaPosition(_loc8_));
               this.timeline.addTween(new Action(this.changeDirection,[_loc10_],new Function(),[],_loc2_));
               _loc2_ += _loc3_;
            }
            _loc5_ = _loc10_;
            _loc4_ = _loc8_;
         }
         this.timeline.addEventListener(AnimationEvent.FINISH,this.onMovementFinish);
         this.timeline.addEventListener(AnimationEvent.CHANGE,this.onTimelineChange);
      }
      
      public function getWalkLength() : Number
      {
         return this.walkLength;
      }
      
      override public function changeDirection(param1:Number) : void
      {
         if(direction != param1)
         {
            super.changeDirection(param1);
         }
      }
      
      public function getDirectionFromDelta(param1:Position, param2:Position) : Number
      {
         if(param1.y > 0 && param1.x > 0)
         {
            return MyLifeInstance.RIGHT_FRONT;
         }
         if(param1.y > 0 && param1.x < 0)
         {
            return MyLifeInstance.LEFT_FRONT;
         }
         if(param1.y < 0 && param1.x < 0)
         {
            return MyLifeInstance.LEFT_BACK;
         }
         if(param1.y < 0 && param1.x > 0)
         {
            return MyLifeInstance.RIGHT_BACK;
         }
         if(param1.y == 0)
         {
            if(param2.y < 0)
            {
               if(param1.x > 0)
               {
                  return MyLifeInstance.RIGHT_BACK;
               }
               return MyLifeInstance.LEFT_BACK;
            }
            if(param1.x > 0)
            {
               return MyLifeInstance.RIGHT_FRONT;
            }
            return MyLifeInstance.LEFT_FRONT;
         }
         if(param1.x == 0)
         {
            if(param2.x < 0)
            {
               if(param1.y > 0)
               {
                  return MyLifeInstance.LEFT_FRONT;
               }
               return MyLifeInstance.LEFT_BACK;
            }
            if(param1.y > 0)
            {
               return MyLifeInstance.RIGHT_FRONT;
            }
            return MyLifeInstance.RIGHT_BACK;
         }
         return MyLifeInstance.LEFT_FRONT;
      }
      
      override public function start() : void
      {
         if(this.timeline != null)
         {
            this.timeline.play();
         }
         this.isWalking = true;
         if(this.avatarClip.parent != characterClip._renderClip)
         {
            avatarClip.x = 0;
            avatarClip.y = 0;
            characterClip._renderClip.avatarClip = avatarClip;
            characterClip._renderClip.addChild(avatarClip);
         }
         super.start();
      }
      
      override public function pause() : void
      {
         super.pause();
         if(this.timeline != null)
         {
            this.isWalking = false;
            this.timeline.stop();
         }
      }
      
      override public function resume() : void
      {
         super.resume();
         if(this.timeline != null)
         {
            this.isWalking = true;
            this.timeline.play();
         }
      }
      
      override public function stop() : void
      {
         super.stop();
         this.timeline.stop();
         this.isWalking = false;
         if(characterClip.hasOwnProperty("isPlayerCharacter") && Boolean(characterClip.isPlayerCharacter()))
         {
            MyLifeInstance.getInstance().server.callExtension("updateCharacterPath",{
               "speed":characterClip.characterSpeed,
               "path":[{
                  "x":characterClip.x,
                  "y":characterClip.y,
                  "d":avatarClip.getDirection()
               }]
            });
         }
      }
      
      override public function cleanUp() : void
      {
         if(this.timeline != null)
         {
            this.timeline.stop();
            this.timeline = null;
         }
         super.cleanUp();
      }
      
      protected function onTimelineChange(param1:AnimationEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(characterClip)
         {
            _loc2_ = MyLifeInstance.getInstance();
            if(characterClip.hasOwnProperty("isPlayerCharacter") && Boolean(characterClip.isPlayerCharacter()))
            {
               _loc2_.getZone().getTriggerZoneHit(characterClip.getPosition(),characterClip);
            }
            _loc2_.getZone().onCharacterMoved(characterClip);
            _loc2_.getZone().resortDepths();
         }
      }
      
      protected function onMovementFinish(param1:AnimationEvent) : void
      {
         this.isWalking = false;
         if(characterClip.hasOwnProperty("isPlayerCharacter") && Boolean(characterClip.isPlayerCharacter()))
         {
            MyLifeInstance.getInstance().server.callExtension("updateCharacterPath",{
               "speed":characterClip.characterSpeed,
               "path":[{
                  "x":characterClip.x,
                  "y":characterClip.y,
                  "d":avatarClip.getDirection()
               }]
            });
         }
         onActionComplete();
      }
   }
}

