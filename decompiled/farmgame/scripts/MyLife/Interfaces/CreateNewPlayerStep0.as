package MyLife.Interfaces
{
   import MyLife.Assets.Avatar.Interfaces.IAvatarClothingLoader;
   import MyLife.Events.GlobalEventManager;
   import MyLife.Events.SaveAvatarEvent;
   import MyLife.NPC.SimpleNPC;
   import fl.motion.easing.*;
   import flash.display.*;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import gs.TweenLite;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol213")]
   public class CreateNewPlayerStep0 extends MovieClip
   {
      
      public var selectGenderErrorOutline:MovieClip;
      
      public var select_female:MovieClip;
      
      public var select_male:MovieClip;
      
      private var _myLife:MovieClip;
      
      private var selectedGender:int = 0;
      
      private var playerParams:Object;
      
      public var close_bt:SimpleButton;
      
      private var clothingLoader:IAvatarClothingLoader;
      
      public function CreateNewPlayerStep0(param1:IAvatarClothingLoader)
      {
         super();
         this.setupGenderSelector(this.select_female,SimpleNPC.GENDER_FEMALE);
         this.setupGenderSelector(this.select_male,SimpleNPC.GENDER_MALE);
         this.selectGenderErrorOutline.visible = false;
         this.close_bt.addEventListener(MouseEvent.CLICK,this.closeDialog);
         this.clothingLoader = param1;
      }
      
      public static function showDialog(param1:DisplayObject, param2:int, param3:int, param4:Function = null, param5:Array = null) : void
      {
         var startSize:Point = null;
         var matParams:Object = null;
         var middlePoint:Point = null;
         var mat:Matrix = null;
         var dialog:DisplayObject = param1;
         var dialogWidth:int = param2;
         var dialogHeight:int = param3;
         var completeFunc:Function = param4;
         var completeParams:Array = param5;
         startSize = new Point(dialogWidth,dialogHeight);
         matParams = {"scale":0.01};
         middlePoint = new Point((dialog.stage.stageWidth - dialogWidth) / 2,(dialog.stage.stageHeight - dialogHeight) / 2);
         mat = new Matrix();
         mat.translate(-startSize.x / 2,-startSize.y / 2);
         mat.scale(matParams.scale,matParams.scale);
         mat.translate(startSize.x / 2,startSize.y / 2);
         mat.translate(middlePoint.x,middlePoint.y);
         dialog.transform.matrix = mat;
         TweenLite.to(matParams,0.5,{
            "scale":1,
            "ease":Back.easeOut,
            "onUpdate":function():void
            {
               mat = new Matrix();
               mat.translate(-startSize.x / 2,-startSize.y / 2);
               mat.scale(matParams.scale,matParams.scale);
               mat.translate(startSize.x / 2,startSize.y / 2);
               mat.translate(middlePoint.x,middlePoint.y);
               dialog.transform.matrix = mat;
               middlePoint = new Point((dialog.stage.stageWidth - dialogWidth * matParams.scale) / 2,(dialog.stage.stageHeight - dialogHeight * matParams.scale) / 2);
               dialog.x = middlePoint.x;
               dialog.y = middlePoint.y;
               dialog.visible = true;
            },
            "onComplete":completeFunc,
            "onCompleteParams":completeParams
         });
      }
      
      public static function hideDialog(param1:DisplayObject, param2:int, param3:int, param4:Function = null, param5:Array = null) : void
      {
         var startSize:Point = null;
         var matParams:Object = null;
         var middlePoint:Point = null;
         var mat:Matrix = null;
         var dialog:DisplayObject = param1;
         var dialogWidth:int = param2;
         var dialogHeight:int = param3;
         var completeFunc:Function = param4;
         var completeParams:Array = param5;
         startSize = new Point(dialogWidth,dialogHeight);
         matParams = {"scale":1};
         middlePoint = new Point((dialog.stage.stageWidth - dialogWidth) / 2,(dialog.stage.stageHeight - dialogHeight) / 2);
         mat = new Matrix();
         mat.translate(-startSize.x / 2,-startSize.y / 2);
         mat.scale(matParams.scale,matParams.scale);
         mat.translate(startSize.x / 2,startSize.y / 2);
         mat.translate(middlePoint.x,middlePoint.y);
         dialog.transform.matrix = mat;
         TweenLite.to(matParams,0.5,{
            "scale":0,
            "ease":Back.easeIn,
            "onUpdate":function():void
            {
               mat = new Matrix();
               mat.translate(-startSize.x / 2,-startSize.y / 2);
               mat.scale(matParams.scale,matParams.scale);
               mat.translate(startSize.x / 2,startSize.y / 2);
               mat.translate(middlePoint.x,middlePoint.y);
               dialog.transform.matrix = mat;
               middlePoint = new Point((dialog.stage.stageWidth - dialogWidth * matParams.scale) / 2,(dialog.stage.stageHeight - dialogHeight * matParams.scale) / 2);
               dialog.x = middlePoint.x;
               dialog.y = middlePoint.y;
            },
            "onComplete":completeFunc,
            "onCompleteParams":completeParams
         });
      }
      
      public function initialize(param1:Object) : void
      {
         this.hide();
         if(param1.selectedGender)
         {
            this.selectNewGender(param1.selectedGender);
         }
         this.playerParams = param1;
      }
      
      private function setupGenderSelector(param1:MovieClip, param2:int) : void
      {
         param1.gotoAndStop((param2 - 1) * 2 + 1);
         param1._gender = param2;
         param1.buttonMode = true;
         param1.useHandCursor = true;
         param1.addEventListener(MouseEvent.CLICK,this.selectNewGenderClick);
      }
      
      public function closeDialog(param1:MouseEvent) : void
      {
         if(this.selectedGender == SimpleNPC.GENDER_FEMALE)
         {
            this.selectNewGender(SimpleNPC.GENDER_MALE);
         }
         else
         {
            this.selectNewGender(SimpleNPC.GENDER_FEMALE);
         }
         this.finishCancel();
      }
      
      public function skipDialog() : void
      {
         this.finishCancel();
      }
      
      protected function finishCancel() : void
      {
         var _loc1_:Object = this.clothingLoader.getAllDefaults(this.selectedGender);
         GlobalEventManager.getInstance().dispatchEvent(new SaveAvatarEvent(SaveAvatarEvent.SAVE,_loc1_,this.selectedGender,null));
         this.unloadInterface(this);
      }
      
      private function selectNewGenderClick(param1:MouseEvent) : void
      {
         this.selectNewGender(param1.currentTarget._gender);
      }
      
      private function selectNewGender(param1:int) : void
      {
         if(param1 == SimpleNPC.GENDER_FEMALE)
         {
            this.select_female.gotoAndStop(2);
            this.select_male.gotoAndStop(3);
            this.selectedGender = param1;
            this.finishCancel();
         }
         else if(param1 == SimpleNPC.GENDER_MALE)
         {
            this.select_female.gotoAndStop(1);
            this.select_male.gotoAndStop(4);
            this.selectedGender = param1;
            this.finishCancel();
         }
      }
      
      private function propagateEvent(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      private function bounceClipInViaY(param1:MovieClip) : void
      {
         TweenLite.to(param1,0.75,{
            "alpha":1,
            "y":param1.y,
            "ease":Bounce.easeOut
         });
         param1.alpha = 0;
         param1.y = -param1.height;
      }
      
      private function unloadInterface(param1:MovieClip) : void
      {
         if(Boolean(this.parent) && this.parent.contains(this))
         {
            this.parent.removeChild(this);
         }
      }
      
      public function show() : void
      {
         MovieClip(this).visible = true;
      }
      
      public function hide() : void
      {
         MovieClip(this).visible = false;
      }
   }
}

