package MyLife.Assets.Avatar
{
   import MyLife.Assets.Avatar.AvatarActions.ActionLibrary;
   import MyLife.Assets.Avatar.AvatarActions.AnimationAction;
   import MyLife.Assets.Avatar.Interfaces.IAvatarClothingLoader;
   import MyLife.Events.AvatarLoadEvent;
   import MyLife.MyLifeInstance;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol194")]
   public class Avatar extends MovieClip
   {
      
      public static const robotDanceFront:Class = Avatar_robotDanceFront;
      
      public static const jumpingJacksFront:Class = Avatar_jumpingJacksFront;
      
      public static const armShuffleFront:Class = Avatar_armShuffleFront;
      
      public static const jumpAndSwingFront:Class = Avatar_jumpAndSwingFront;
      
      public static const powerJumpFront:Class = Avatar_powerJumpFront;
      
      public static const walkFront:Class = Avatar_walkFront;
      
      public static const walkBack:Class = Avatar_walkBack;
      
      public static const standFront:Class = Avatar_standFront;
      
      public static const standBack:Class = Avatar_standBack;
      
      private static var registeredAnimations:Boolean = false;
      
      private var currentClothes:Object;
      
      public var parentCharacter:MovieClip;
      
      public var avatarClip:MovieClip;
      
      public var avatarFrontClip:MovieClip;
      
      public var avatarBackClip:MovieClip;
      
      private var currentDirection:Number = -1;
      
      private var localAnimation:AnimationAction;
      
      private var _clothesLoader:IAvatarClothingLoader;
      
      private var clothingConflictManager:ClothingConflictManager;
      
      private var gender:Number;
      
      private var effect:MovieClip;
      
      public function Avatar(param1:IAvatarClothingLoader)
      {
         super();
         if(registeredAnimations == false)
         {
            ActionLibrary.registerAnimationClipClass(robotDanceFront,"robotDanceFront");
            ActionLibrary.registerAnimationClipClass(jumpingJacksFront,"jumpingJacksFront");
            ActionLibrary.registerAnimationClipClass(armShuffleFront,"armShuffleFront");
            ActionLibrary.registerAnimationClipClass(jumpAndSwingFront,"jumpAndSwingFront");
            ActionLibrary.registerAnimationClipClass(powerJumpFront,"powerJumpFront");
            ActionLibrary.registerAnimationClipClass(walkFront,"walkFront");
            ActionLibrary.registerAnimationClipClass(walkBack,"walkBack");
            ActionLibrary.registerAnimationClipClass(standFront,"standFront");
            ActionLibrary.registerAnimationClipClass(standBack,"standBack");
            registeredAnimations = true;
         }
         this._clothesLoader = param1;
         this.clothingConflictManager = new ClothingConflictManager(this,this._clothesLoader);
      }
      
      public static function getClothingFileArray(param1:Object) : Array
      {
         var _loc3_:* = undefined;
         var _loc4_:String = null;
         var _loc2_:Array = [];
         if(param1 == null)
         {
            return _loc2_;
         }
         for(_loc3_ in param1)
         {
            if(param1[_loc3_] != null)
            {
               if(param1[_loc3_].itemId == null && param1[_loc3_].id != null)
               {
                  param1[_loc3_].itemId = param1[_loc3_].id;
               }
               if(param1[_loc3_].itemId == null && param1[_loc3_].item != null)
               {
                  param1[_loc3_].itemId = param1[_loc3_].item;
               }
               if(param1[_loc3_].metaData == null && param1[_loc3_].meta_data != null)
               {
                  param1[_loc3_].metaData = param1[_loc3_].meta_data;
               }
               if(param1[_loc3_].g == null && param1[_loc3_].gender != null)
               {
                  param1[_loc3_].g = param1[_loc3_].gender;
               }
               _loc4_ = null;
               if(param1[_loc3_].filename != null && param1[_loc3_].filename != "")
               {
                  _loc4_ = param1[_loc3_].filename;
               }
               if(_loc4_ != null)
               {
                  _loc2_.push(param1[_loc3_]);
               }
            }
         }
         return _loc2_;
      }
      
      public function setParentCharacter(param1:MovieClip) : void
      {
         this.parentCharacter = param1;
      }
      
      public function removeEffect() : void
      {
         if(this.effect != null)
         {
            if(this.effect.hasOwnProperty("destroy"))
            {
               this.effect.destroy();
            }
            if(this.effect.parent != null)
            {
               this.effect.parent.removeChild(this.effect);
            }
            this.effect = null;
         }
      }
      
      public function addEffect(param1:MovieClip) : void
      {
         this.removeEffect();
         this.effect = param1;
         this.addChild(this.effect);
      }
      
      private function addEffectForDefaultAnimation() : void
      {
      }
      
      public function doRandomDance() : void
      {
         var _loc2_:String = null;
         var _loc1_:Number = Math.round(Math.random() * 3);
         if(_loc1_ == 0)
         {
            _loc2_ = "robotDanceFront";
         }
         else if(_loc1_ == 1)
         {
            _loc2_ = "jumpAndSwingFront";
         }
         else if(_loc1_ == 2)
         {
            _loc2_ = "armShuffleFront";
         }
         else if(_loc1_ == 3)
         {
            _loc2_ = "jumpingJacksFront";
         }
         this.doAvatarAction(_loc2_,{"l":-1});
      }
      
      public function doAvatarAction(param1:String = null, param2:Object = null) : void
      {
         if(param2 == null)
         {
            param2 = new Object();
         }
         param2.animName = param1;
         if(this.localAnimation != null)
         {
            this.localAnimation.stop();
         }
         if(param1 != null)
         {
            this.localAnimation = new AnimationAction("anim",this,param2);
            this.localAnimation.start();
         }
      }
      
      public function initAvatar(param1:Number, param2:Number) : void
      {
         this.scaleX = this.scaleY = param2;
         this.gender = param1;
      }
      
      public function isFront() : Boolean
      {
         return this.currentDirection == MyLifeInstance.LEFT_FRONT || this.currentDirection == MyLifeInstance.RIGHT_FRONT;
      }
      
      public function getDirection() : Number
      {
         return this.currentDirection;
      }
      
      public function getGender() : Number
      {
         return this.gender;
      }
      
      public function getAvatarAction() : AnimationAction
      {
         return this.localAnimation;
      }
      
      public function setGender(param1:Number) : void
      {
         this.gender = param1;
      }
      
      public function setAnimationClip(param1:MovieClip, param2:Number) : void
      {
         if(param1.hasOwnProperty("front") && param1.hasOwnProperty("back"))
         {
            this.setSingleDirectionAnimationClip(param1.front,0,false);
            this.setSingleDirectionAnimationClip(param1.back,3,false);
            if(this.avatarClip != null)
            {
               if(this.avatarClip.parent == this)
               {
                  this.avatarClip.parent.removeChild(this.avatarClip);
               }
            }
            this.avatarClip = param1;
            this.addChild(this.avatarClip);
         }
         else
         {
            this.setSingleDirectionAnimationClip(param1,param2,true);
         }
      }
      
      public function setSingleDirectionAnimationClip(param1:MovieClip, param2:Number, param3:Boolean = true) : void
      {
         var clothes:Object = null;
         var clip:MovieClip = param1;
         var direction:Number = param2;
         var addClip:Boolean = param3;
         var isFront:Boolean = direction == MyLifeInstance.LEFT_FRONT || direction == MyLifeInstance.RIGHT_FRONT;
         var flipAvatar:Boolean = direction == MyLifeInstance.LEFT_FRONT || direction == MyLifeInstance.RIGHT_BACK;
         this.removeEffect();
         if(this.avatarClip != null)
         {
            if(this.avatarClip.parent == this)
            {
               this.avatarClip.parent.removeChild(this.avatarClip);
            }
         }
         else
         {
            clothes = this.currentClothes;
         }
         this.currentDirection = direction;
         if(isFront)
         {
            if(this.avatarFrontClip == null)
            {
               this.avatarFrontClip = ActionLibrary.getAnimationClipInstance("standFront");
               this.clothingConflictManager.renderClothes(clothes);
               this.avatarFrontClip.chest.skin.gotoAndStop(this.gender);
               this.avatarFrontClip.leftUpperArm.skin.gotoAndStop(this.gender);
               this.avatarFrontClip.rightUpperArm.skin.gotoAndStop(this.gender);
               this.avatarFrontClip.leftForeArm.skin.gotoAndStop(this.gender);
               this.avatarFrontClip.rightForeArm.skin.gotoAndStop(this.gender);
            }
            this.transferClipsToNewAnimation(this.avatarFrontClip,clip);
            this.avatarFrontClip = clip;
         }
         else
         {
            if(this.avatarBackClip == null)
            {
               this.avatarBackClip = ActionLibrary.getAnimationClipInstance("standBack");
               this.clothingConflictManager.renderClothes(clothes);
               try
               {
                  this.avatarBackClip.chest.skin.gotoAndStop(this.gender);
                  this.avatarBackClip.leftUpperArm.skin.gotoAndStop(this.gender);
                  this.avatarBackClip.rightUpperArm.skin.gotoAndStop(this.gender);
                  this.avatarBackClip.leftForeArm.skin.gotoAndStop(this.gender);
                  this.avatarBackClip.rightForeArm.skin.gotoAndStop(this.gender);
               }
               catch(err:Error)
               {
               }
            }
            this.transferClipsToNewAnimation(this.avatarBackClip,clip);
            this.avatarBackClip = clip;
         }
         this.avatarClip = clip;
         if(this.avatarClip != null)
         {
            if(addClip == true)
            {
               this.avatarClip.scaleX = Math.abs(this.avatarClip.scaleX) * (flipAvatar ? -1 : 1);
               this.addChild(this.avatarClip);
               this.addEffectForDefaultAnimation();
            }
         }
      }
      
      public function changeDirection(param1:Number) : void
      {
         if(this.localAnimation != null)
         {
            this.localAnimation.changeDirection(param1);
         }
         else
         {
            this.setAnimationClip(ActionLibrary.getAnimationClipInstance("standFront"),param1);
         }
      }
      
      public function setZzzStatus(param1:Boolean) : void
      {
      }
      
      public function removeItem(param1:Number) : void
      {
         this.clothingConflictManager.removeClothingItem(param1);
      }
      
      public function renderItem(param1:Object, param2:Number = -1, param3:String = "") : void
      {
         this.clothingConflictManager.addClothingItem(param1,true,param2,param3);
         if(param1["categoryId"] == 1000)
         {
            this.clothingConflictManager.renderClothes();
         }
      }
      
      public function getClothingItem(param1:String) : Object
      {
         return this.clothingConflictManager.getClothingItem(param1);
      }
      
      public function renderClothes(param1:Object) : void
      {
         this.currentClothes = param1;
         if(this.avatarClip == null)
         {
            this.avatarBackClip = ActionLibrary.getAnimationClipInstance("standBack");
            this.avatarBackClip.chest.skin.gotoAndStop(this.gender);
            this.avatarBackClip.leftUpperArm.skin.gotoAndStop(this.gender);
            this.avatarBackClip.rightUpperArm.skin.gotoAndStop(this.gender);
            this.avatarBackClip.leftForeArm.skin.gotoAndStop(this.gender);
            this.avatarBackClip.rightForeArm.skin.gotoAndStop(this.gender);
            this.setAnimationClip(ActionLibrary.getAnimationClipInstance("standFront"),0);
         }
         else
         {
            this.clothingConflictManager.renderClothes(param1);
            this.currentClothes = this.clothingConflictManager.getFormattedClothingList();
         }
      }
      
      public function onAllClothesLoaded() : void
      {
         this.renderClothes(this.currentClothes);
         this.currentClothes = this.clothingConflictManager.getFormattedClothingList();
         this.visible = true;
         dispatchEvent(new AvatarLoadEvent(AvatarLoadEvent.CLOTHING_LOAD_COMPLETE));
      }
      
      private function transferClipsToNewAnimation(param1:MovieClip, param2:MovieClip) : void
      {
         var i:int;
         var sourceChild:MovieClip = null;
         var destinationChild:MovieClip = null;
         var childClip:MovieClip = null;
         var sourceAnimation:MovieClip = param1;
         var destinationAnimation:MovieClip = param2;
         if(sourceAnimation == null || destinationAnimation == null)
         {
            return;
         }
         i = 0;
         for(; i < sourceAnimation.numChildren; i++)
         {
            sourceChild = sourceAnimation.getChildAt(i) as MovieClip;
            try
            {
               destinationChild = destinationAnimation.getChildByName(sourceChild.name) as MovieClip;
            }
            catch(error:*)
            {
               continue;
            }
            if(destinationChild != null)
            {
               this.removeUnusedChildren(destinationChild);
               this.removeUsedChildren(sourceChild);
               while(sourceChild.numChildren > 0)
               {
                  childClip = sourceChild.getChildAt(0) as MovieClip;
                  if(childClip != null)
                  {
                     destinationChild[childClip.name] = childClip;
                     destinationChild.addChild(childClip);
                  }
                  else
                  {
                     sourceChild.removeChildAt(0);
                  }
               }
            }
         }
      }
      
      private function removeUnusedChildren(param1:DisplayObjectContainer) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:int = 0;
         while(param1.numChildren > _loc2_)
         {
            _loc3_ = param1.getChildAt(_loc2_);
            if(Boolean(_loc3_) && _loc3_.name != "animationProp")
            {
               param1.removeChildAt(_loc2_);
            }
            else
            {
               _loc2_++;
            }
         }
      }
      
      private function removeUsedChildren(param1:DisplayObjectContainer) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:int = 0;
         while(param1.numChildren > _loc2_)
         {
            _loc3_ = param1.getChildAt(_loc2_);
            if(Boolean(_loc3_) && _loc3_.name == "animationProp")
            {
               param1.removeChildAt(_loc2_);
            }
            else
            {
               _loc2_++;
            }
         }
      }
      
      public function loadAvatarClothes(param1:Object, param2:Boolean = false, param3:Object = null) : void
      {
         this.visible = param2;
         var _loc4_:Array = getClothingFileArray(param1);
         this.currentClothes = param1;
         if(_loc4_.length == 0)
         {
            this.onAllClothesLoaded();
         }
         else
         {
            this._clothesLoader.loadClothing(_loc4_,this.onAllClothesLoaded);
         }
      }
      
      public function getCurrentAvatarClothes(param1:Boolean = false) : Object
      {
         return this.clothingConflictManager.getFormattedClothingList(param1);
      }
      
      public function stopAnimation() : void
      {
         if(this.localAnimation)
         {
            this.localAnimation.stop();
         }
      }
      
      public function cleanUp() : void
      {
         this.removeEffect();
         this.avatarFrontClip = null;
         this.avatarBackClip = null;
         if(this.localAnimation != null)
         {
            this.localAnimation.stop();
         }
         this.localAnimation = null;
         if(this._clothesLoader != null)
         {
            this._clothesLoader.cleanUp();
         }
         this._clothesLoader = null;
         if(this.clothingConflictManager != null)
         {
            this.clothingConflictManager.cleanUp();
         }
         this.clothingConflictManager = null;
         this.avatarClip = null;
         this.currentClothes = null;
      }
   }
}

