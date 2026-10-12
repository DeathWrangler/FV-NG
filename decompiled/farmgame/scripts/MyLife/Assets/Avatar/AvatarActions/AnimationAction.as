package MyLife.Assets.Avatar.AvatarActions
{
   import MyLife.MyLifeInstance;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AnimationAction extends AvatarAction
   {
      
      public static const LOOP:Number = -1;
      
      public static const TOTAL_FRAMES:int = 0;
      
      private static var isRegistered:Boolean = false;
      
      public static const STAND_FRONT:String = "standFront";
      
      public static const STAND_BACK:String = "standBack";
      
      public static const WALK_FRONT:String = "walkFront";
      
      public static const WALK_BACK:String = "walkBack";
      
      public static const ARM_SHUFFLE:String = "armShuffleFront";
      
      public static const JUMPING_JACKS:String = "jumpingJacksFront";
      
      public static const ROBOT_DANCE:String = "robotDanceFront";
      
      public static const JUMP_AND_SWING:String = "jumpAndSwingFront";
      
      public static const POWER_JUMP:String = "powerJumpFront";
      
      public static const MYSTIC_LEVITATION:String = "mysticLevitationFront";
      
      public static const YOU_DA_BOMB:String = "youDaBombFront";
      
      public static const THROW_WATER_BALLOON:String = "throwWaterBalloon";
      
      public static const TOUCHDOWN:String = "touchdown";
      
      public static const MOON_WALK:String = "moonWalk";
      
      public static const LAUGH:String = "laugh";
      
      public static const CHEER:String = "cheer";
      
      public static const SIT_UPS:String = "sitUps";
      
      public static const PASS_GAS:String = "passGas";
      
      public static const AIR_GUITAR:String = "airGuitar";
      
      public static const IN_LOVE:String = "lovie";
      
      public static const POP_AND_LOCK:String = "popNLock";
      
      public static const KRUNK:String = "krunkDance";
      
      public static const RUNNING_MAN:String = "runningManDance";
      
      public static const HIP_HOP_SPIN:String = "hipHopSpin";
      
      public static const WAVE:String = "wave";
      
      public static const CANCAN:String = "cancanDance";
      
      public static const EGYPTIAN:String = "egyptian";
      
      public static const YAWN:String = "yawn";
      
      public static const TOO_COOL:String = "kewel4U";
      
      public static const IM_HOT:String = "hotPose";
      
      public static const PET_PET:String = "petPet";
      
      public static const QUICK_DANCE:String = "quickDance";
      
      public static const QUICK_APPLAUSE:String = "quickApplause";
      
      public static const FOOT_TAP:String = "footTap";
      
      public static const INTERACTIVE_CLASS_PREFIX:String = "Classes::";
      
      protected var duration:Number;
      
      protected var direction:Number;
      
      protected var frameIncrement:Number;
      
      protected var currentAnimation:MovieClip;
      
      protected var startFrame:Number;
      
      protected var endFrame:Number;
      
      protected var frame:Number;
      
      protected var animName:String;
      
      protected var currentLoop:Number;
      
      public function AnimationAction(param1:String, param2:MovieClip, param3:Object = null, param4:Number = 2, param5:Boolean = false)
      {
         super(param1,param2,param3,param4,param5);
         this.initializeActionData(param1,param3);
      }
      
      public static function registerAction() : void
      {
         ActionLibrary.registerActionClass(AnimationAction,"anim");
      }
      
      protected function initializeActionData(param1:String, param2:Object = null) : void
      {
         this.startFrame = 1;
         this.endFrame = TOTAL_FRAMES;
         this.duration = -1;
         this.direction = 0;
         this.animName = "stand";
         if(param2)
         {
            if(param2.s != null)
            {
               this.startFrame = param2.s;
            }
            if(param2.e != null)
            {
               this.endFrame = param2.e;
            }
            if(param2.l != null)
            {
               this.duration = param2.l;
            }
            if(param2.d != null)
            {
               this.direction = param2.d;
            }
            if(param2.animName != null)
            {
               this.animName = param2.animName;
            }
         }
      }
      
      public function getDirection() : Number
      {
         return this.direction;
      }
      
      override public function start() : void
      {
         this.startAnimation();
         this.currentLoop = 0;
         if(this.animName.indexOf(INTERACTIVE_CLASS_PREFIX) != -1)
         {
            m_isPlaying = true;
         }
         super.start();
      }
      
      override public function pause() : void
      {
         super.pause();
      }
      
      override public function resume() : void
      {
         super.resume();
      }
      
      protected function startAnimation() : void
      {
         if(this.animName == null)
         {
            return;
         }
         this.setAnimationClip();
         if(!this.currentAnimation)
         {
            return;
         }
         if(isNaN(this.startFrame) || this.startFrame < TOTAL_FRAMES)
         {
            this.startFrame = 1;
         }
         else if(this.startFrame == TOTAL_FRAMES || this.startFrame > this.currentAnimation.totalFrames)
         {
            this.startFrame = this.currentAnimation.totalFrames;
         }
         if(isNaN(this.endFrame) || this.endFrame == TOTAL_FRAMES || this.endFrame > this.currentAnimation.totalFrames)
         {
            this.endFrame = this.currentAnimation.totalFrames;
         }
         else if(this.endFrame < TOTAL_FRAMES)
         {
            this.endFrame = 1;
         }
         this.frameIncrement = this.startFrame <= this.endFrame ? 1 : -1;
         this.frame = this.startFrame;
         if(this.currentAnimation)
         {
            this.currentAnimation.gotoAndStop(this.frame);
         }
         if(this.currentAnimation.hasOwnProperty("front"))
         {
            this.currentAnimation.front.gotoAndStop(this.frame);
         }
         if(this.currentAnimation.hasOwnProperty("back"))
         {
            this.currentAnimation.back.gotoAndStop(this.frame);
         }
      }
      
      override public function changeDirection(param1:Number) : void
      {
         this.direction = param1;
         this.setAnimationClip();
      }
      
      override public function cleanUp() : void
      {
         this.currentAnimation = null;
         super.cleanUp();
      }
      
      final protected function setAnimationClip() : void
      {
         var _loc1_:String = null;
         if(this.animName == null)
         {
            return;
         }
         this.currentAnimation = null;
         var _loc2_:Boolean = this.direction == MyLifeInstance.LEFT_FRONT || this.direction == MyLifeInstance.RIGHT_FRONT;
         _loc1_ = this.animName + (_loc2_ ? "Front" : "Back");
         this.currentAnimation = ActionLibrary.getAnimationClipInstance(_loc1_);
         if(this.currentAnimation == null)
         {
            this.currentAnimation = ActionLibrary.getAnimationClipInstance(this.animName);
         }
         if(this.currentAnimation != null && avatarClip != null)
         {
            avatarClip.setAnimationClip(this.currentAnimation,this.direction);
         }
      }
      
      override protected function updateAction(param1:Event) : void
      {
         this.positionNameTagAndBubble();
         if(this.frame == this.endFrame)
         {
            this.frame = this.startFrame;
            ++this.currentLoop;
            if(this.duration != LOOP && this.currentLoop == this.duration)
            {
               if(this.animName.indexOf(INTERACTIVE_CLASS_PREFIX) != -1)
               {
                  m_isPlaying = false;
               }
               onActionComplete();
               return;
            }
         }
         else
         {
            this.frame += this.frameIncrement;
         }
         if(Boolean(this.currentAnimation) && this.animName.indexOf(INTERACTIVE_CLASS_PREFIX) != -1)
         {
            this.currentAnimation.gotoAndStop(this.frame);
            if(this.currentAnimation)
            {
               if(this.currentAnimation.hasOwnProperty("front"))
               {
                  this.currentAnimation.front.gotoAndStop(this.frame);
               }
               if(this.currentAnimation.hasOwnProperty("back"))
               {
                  this.currentAnimation.back.gotoAndStop(this.frame);
               }
            }
         }
      }
      
      public function isPlaying() : Boolean
      {
         return m_isPlaying;
      }
      
      private function positionNameTagAndBubble() : void
      {
         if(this.avatarClip.parentCharacter == null)
         {
            return;
         }
         if(this.avatarClip.parentCharacter.hasOwnProperty("positionNameTagAndBubble"))
         {
            this.avatarClip.parentCharacter.positionNameTagAndBubble();
         }
      }
   }
}

