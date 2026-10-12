package AvatarMode
{
   import Classes.AnimalStorageBuilding;
   import Classes.Avatar.FarmAvatar;
   import Classes.Building;
   import Classes.ImageLoader;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class AMBuildingInteraction extends AMActionState
   {
      
      private static var m_effectLoader:ImageLoader = null;
      
      private static var m_effect:DisplayObject = null;
      
      protected var m_targetBuilding:Building;
      
      protected var m_playOnReenter:Boolean = true;
      
      private var m_startAnimation:Boolean = false;
      
      public function AMBuildingInteraction(avatar:FarmAvatar, building:Building)
      {
         super(avatar,building);
         this.m_targetBuilding = building;
         this.m_targetBuilding.showFeedGlow(false);
         if(m_effectLoader == null)
         {
            m_effectLoader = ImageLoader.getInstance(Global.getAssetURL(AnimalStorageBuilding.FEEDING_SUCCESS_URL));
            m_effectLoader.getContent(this.onEffectLoad);
         }
      }
      
      private function onEffectLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         m_effect = dispObj;
         m_effect.visible = false;
         m_effect.scaleX = 1;
         m_effect.scaleY = 1;
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         if(m_actionStarted && m_avatar != null)
         {
            if(this.m_targetBuilding != null && this.m_targetBuilding.getDisplayObject() as Sprite != null)
            {
               if(!this.m_startAnimation && m_effect != null)
               {
                  (this.m_targetBuilding.getDisplayObject() as Sprite).addChild(m_effect);
                  if(m_effect as MovieClip != null)
                  {
                     m_effect.visible = true;
                     (m_effect as MovieClip).prevScene();
                     (m_effect as MovieClip).play();
                  }
                  this.m_startAnimation = true;
               }
               m_actionTime += delta;
               progress = m_actionTime / Global.farmGameSettingsManager.getNumber("fertilizeTime");
               if(progress > 1)
               {
                  this.doAction();
                  if(m_effect as MovieClip != null)
                  {
                     (m_effect as MovieClip).visible = false;
                  }
                  m_avatar.getStateMachine().removeState(this);
               }
               else
               {
                  m_avatar.setActionProgress(this.getProgressText(),progress);
               }
            }
            else
            {
               m_avatar.getStateMachine().removeState(this);
            }
         }
      }
      
      protected function doAction() : void
      {
      }
      
      protected function getProgressText() : String
      {
         return "";
      }
   }
}

