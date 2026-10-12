package MyLife.Assets.Avatar.AvatarActions
{
   import flash.display.MovieClip;
   
   public class ActionLibrary
   {
      
      private static var actionHash:Object;
      
      private static var animationClipHash:Object;
      
      private static var registeredDefaultClasses:Boolean = false;
      
      public function ActionLibrary()
      {
         super();
      }
      
      public static function registerActionClass(param1:Class, param2:String) : void
      {
         if(actionHash == null)
         {
            actionHash = new Object();
         }
         actionHash[param2] = param1;
      }
      
      public static function unregisterActionClass(param1:String) : void
      {
         delete actionHash[param1];
      }
      
      public static function registerAnimationClipClass(param1:Class, param2:String) : void
      {
         if(animationClipHash == null)
         {
            animationClipHash = new Object();
         }
         animationClipHash[param2] = param1;
      }
      
      public static function unregisterAnimationClipClass(param1:String) : void
      {
         delete animationClipHash[param1];
      }
      
      public static function getAnimationClipInstance(param1:String) : MovieClip
      {
         var animationClass:Class;
         var animationClip:MovieClip = null;
         var animationClipClassName:String = param1;
         if(animationClipHash[animationClipClassName] == null)
         {
            return null;
         }
         animationClass = animationClipHash[animationClipClassName];
         try
         {
            animationClip = new animationClass() as MovieClip;
         }
         catch(error:Error)
         {
            animationClip = null;
         }
         return animationClip;
      }
      
      public static function getActionInstance(param1:String, param2:MovieClip, param3:Object = null, param4:Number = 2, param5:Boolean = false) : AvatarAction
      {
         var animationClass:Class;
         var action:AvatarAction = null;
         var actionIdentifier:String = param1;
         var avatar:MovieClip = param2;
         var actionParams:Object = param3;
         var interruptionType:Number = param4;
         var isWaiting:Boolean = param5;
         if(registeredDefaultClasses == false)
         {
            AnimationAction.registerAction();
            WalkAction.registerAction();
            registeredDefaultClasses = true;
         }
         animationClass = actionHash[actionIdentifier];
         try
         {
            action = new animationClass(actionIdentifier,avatar,actionParams,interruptionType,isWaiting) as AvatarAction;
         }
         catch(error:Error)
         {
            action = null;
         }
         return action;
      }
      
      public static function isActionLoaded(param1:String) : Boolean
      {
         if(registeredDefaultClasses == false)
         {
            AnimationAction.registerAction();
            WalkAction.registerAction();
            registeredDefaultClasses = true;
         }
         var _loc2_:Boolean = false;
         if(Boolean(actionHash) && Boolean(param1))
         {
            _loc2_ = actionHash[param1] != null;
         }
         return _loc2_;
      }
      
      public static function isAnimationLoaded(param1:String) : Boolean
      {
         if(registeredDefaultClasses == false)
         {
            AnimationAction.registerAction();
            WalkAction.registerAction();
            registeredDefaultClasses = true;
         }
         var _loc2_:Boolean = false;
         if(Boolean(animationClipHash) && Boolean(param1))
         {
            _loc2_ = animationClipHash[param1] != null;
         }
         return _loc2_;
      }
      
      public static function makeAnimItem(param1:Object) : Object
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:* = 0;
         var _loc7_:Array = null;
         if(param1.hasOwnProperty("metaData"))
         {
            _loc2_ = param1.metaData.split("|");
         }
         else if(param1.hasOwnProperty("meta_data"))
         {
            _loc2_ = param1.meta_data.split("|");
         }
         if(_loc2_)
         {
            _loc4_ = {
               "name":param1.filename,
               "s":1,
               "l":1
            };
            _loc5_ = {"params":_loc4_};
            _loc3_ = {
               "value":_loc5_,
               "used":0
            };
            _loc6_ = int(_loc2_.length);
            while(_loc6_)
            {
               _loc6_--;
               _loc7_ = _loc2_[_loc6_].split(":");
               switch(_loc7_[0])
               {
                  case "energy":
                     break;
                  case "action":
                     _loc3_.name = _loc7_[1];
                     _loc5_.a = _loc7_[1];
                     break;
                  case "startFrame":
                     _loc4_.s = Number(_loc7_[1]);
                     break;
                  case "endFrame":
                     _loc4_.e = Number(_loc7_[1]);
                     break;
                  case "loop":
                     _loc4_.l = Number(_loc7_[1]);
               }
            }
            _loc3_.text = param1.name;
         }
         return _loc3_;
      }
   }
}

