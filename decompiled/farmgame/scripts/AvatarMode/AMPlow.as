package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.HarvestableResource;
   import Classes.Plot;
   import Classes.util.ZLocUtils;
   import Engine.Managers.SoundManager;
   import Managers.AvatarRetentionExperimentUtil;
   
   public class AMPlow extends AMActionState
   {
      
      private static var m_added:Boolean = false;
      
      private var m_plot:Plot;
      
      private var m_playOnReenter:Boolean = true;
      
      public function AMPlow(avatar:FarmAvatar, plot:Plot)
      {
         super(avatar,plot);
         this.m_plot = plot;
         if(!m_added)
         {
            m_added = true;
            this.addPlowSounds();
         }
      }
      
      private function addPlowSounds() : void
      {
         SoundManager.addSound("plow1",Global.getAssetURL("assets/sounds/actions/sfx_plow_01.mp3"),false);
         SoundManager.addSound("plow2",Global.getAssetURL("assets/sounds/actions/sfx_plow_02.mp3"),false);
         SoundManager.addSound("plow3",Global.getAssetURL("assets/sounds/actions/sfx_plow_03.mp3"),false);
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         if(m_actionStarted)
         {
            if(this.m_plot.isPlowable())
            {
               m_actionTime += delta;
               progress = m_actionTime / Global.farmGameSettingsManager.getNumber("plowTime");
               if(progress > 1 || AvatarRetentionExperimentUtil.inNoWaitExperiment())
               {
                  this.m_plot.plow();
                  m_avatar.getStateMachine().removeState(this);
               }
               else
               {
                  m_avatar.setActionProgress(ZLocUtils.t("FarmGame","Plowing"),progress);
               }
            }
            else
            {
               m_avatar.getStateMachine().removeState(this);
            }
         }
      }
      
      override public function added() : void
      {
         super.added();
         this.m_plot.setActionState(HarvestableResource.IS_PLOWING);
      }
      
      override public function enter() : void
      {
         super.enter();
         if(!this.conditionallyPath() || this.m_actionStarted)
         {
            this.m_playOnReenter = false;
            SoundManager.chooseAndPlaySound(["plow1","plow2","plow3"]);
         }
      }
      
      override public function reenter() : void
      {
         super.reenter();
         if(this.m_playOnReenter && this.m_actionStarted)
         {
            SoundManager.chooseAndPlaySound(["plow1","plow2","plow3"]);
         }
      }
      
      override public function removed() : void
      {
         super.removed();
         this.m_plot.setActionState(HarvestableResource.IS_RESTING);
      }
   }
}

