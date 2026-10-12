package MyLife
{
   import MyLife.Assets.Avatar.Interfaces.IAvatarClothingLoader;
   import MyLife.NPC.SimpleNPC;
   import fai.*;
   import fl.motion.MatrixTransformer;
   import fl.motion.easing.*;
   import flash.display.*;
   import flash.geom.Matrix;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import gs.TweenLite;
   
   public class Character extends SimpleNPC
   {
      
      public static var popupCollection:Array = new Array();
      
      public static var popupUserId:Array = new Array();
      
      public var coinBalance:Number = 0;
      
      private var characterContextMenu:MovieClip;
      
      private var _characterTypingTimer:Timer;
      
      private var _characterTyping:Boolean = false;
      
      private var _playerCharacter:Boolean = false;
      
      private var _drunkSkewMax:Number = 0;
      
      private var highlighted:Boolean = false;
      
      public var freeActions:Boolean = false;
      
      public function Character(param1:IAvatarClothingLoader, param2:Boolean = false)
      {
         super(param1);
         this._playerCharacter = param2;
      }
      
      public function setDrunkLevel(param1:Number) : void
      {
         var _loc2_:Number = Math.sqrt(param1);
         if(this._drunkSkewMax <= 0)
         {
            if(_loc2_ > 1)
            {
               this.startSkewCharacter(_loc2_);
            }
         }
         else
         {
            this._drunkSkewMax = _loc2_;
         }
      }
      
      private function startSkewCharacter(param1:Number) : void
      {
         this._drunkSkewMax = param1;
         var _loc2_:Object = {"xSkew":0};
         TweenLite.to(_loc2_,2.5,{
            "xSkew":this._drunkSkewMax,
            "ease":Linear.easeOut,
            "onUpdate":this.skewUpdateFunction,
            "onUpdateParams":[_loc2_],
            "onComplete":this.skewCharacter,
            "onCompleteParams":[2,_loc2_]
         });
      }
      
      private function skewCharacter(param1:*, param2:Object) : void
      {
         if(this._drunkSkewMax <= 1)
         {
            this._drunkSkewMax = 0;
            return;
         }
         if(param1 == 1)
         {
            TweenLite.to(param2,5,{
               "xSkew":this._drunkSkewMax,
               "ease":Linear.easeInOut,
               "onUpdate":this.skewUpdateFunction,
               "onUpdateParams":[param2],
               "onComplete":this.skewCharacter,
               "onCompleteParams":[2,param2]
            });
         }
         else
         {
            TweenLite.to(param2,5,{
               "xSkew":-this._drunkSkewMax,
               "ease":Linear.easeInOut,
               "onUpdate":this.skewUpdateFunction,
               "onUpdateParams":[param2],
               "onComplete":this.skewCharacter,
               "onCompleteParams":[1,param2]
            });
         }
      }
      
      private function skewUpdateFunction(param1:Object) : void
      {
         this.setCharacterSkew(param1.xSkew);
      }
      
      private function setCharacterSkew(param1:Number) : void
      {
         var _loc2_:Matrix = _renderClip.transform.matrix;
         MatrixTransformer.setSkewX(_loc2_,param1);
         _renderClip.transform.matrix = _loc2_;
      }
      
      public function setZzzStatus(param1:Boolean) : void
      {
         if(Boolean(_renderClip) && Boolean(_renderClip.avatarClip) && Boolean(_renderClip.avatarClip.setZzzStatus))
         {
            _renderClip.avatarClip.setZzzStatus(param1);
         }
      }
      
      public function isPlayerCharacter() : Boolean
      {
         return this._playerCharacter;
      }
      
      override public function highlightCharacter(param1:Object, param2:Boolean) : void
      {
         super.highlightCharacter(param1,param2);
         this.highlighted = param2;
      }
      
      private function getNewInstanceFromClassName(param1:String) : Object
      {
         var _loc2_:Class = null;
         var _loc3_:Object = null;
         try
         {
            _loc2_ = getDefinitionByName(param1) as Class;
            return new _loc2_();
         }
         catch(e:Error)
         {
         }
         return null;
      }
   }
}

