package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.HarvestableResource;
   import Classes.Plot;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Managers.AvatarRetentionExperimentUtil;
   
   public class AMHarvest extends AMActionState
   {
      
      protected var m_harvestResource:HarvestableResource;
      
      private var m_playOnReenter:Boolean = true;
      
      public function AMHarvest(avatar:FarmAvatar, resource:HarvestableResource)
      {
         super(avatar,resource);
         this.m_harvestResource = resource;
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         var text:String = null;
         if(m_actionStarted)
         {
            if(this.m_harvestResource.isHarvestable() && !this.m_harvestResource.isBusy)
            {
               m_actionTime += delta;
               progress = m_actionTime / this.m_harvestResource.getHarvestTime();
               if(progress > 1 || AvatarRetentionExperimentUtil.inNoWaitExperiment())
               {
                  this.m_harvestResource.harvest();
                  m_avatar.getStateMachine().removeState(this);
                  this.m_harvestResource.doHarvestDropOff(m_avatar);
                  if(this.m_harvestResource is Plot)
                  {
                     UI.showBushelReportWindow();
                  }
               }
               else
               {
                  text = this.m_harvestResource.getHarvestText();
                  m_avatar.setActionProgress(text,progress);
               }
            }
            else
            {
               m_avatar.getStateMachine().removeState(this);
            }
         }
      }
      
      override public function enter() : void
      {
         super.enter();
         if(!this.conditionallyPath() && this.m_actionStarted)
         {
            this.m_playOnReenter = false;
            if(this.m_harvestResource.getTypeName() == "plot")
            {
               SoundManager.chooseAndPlaySound(["crop1","crop2","crop3"]);
            }
            else if(this.m_harvestResource.getTypeName() == "tree")
            {
               SoundManager.chooseAndPlaySound(["tree1","tree2","tree3"]);
            }
         }
      }
      
      override public function reenter() : void
      {
         super.reenter();
         if(this.m_playOnReenter && m_actionStarted)
         {
            if(this.m_harvestResource.getClassName() == "Plot")
            {
               SoundManager.chooseAndPlaySound(["crop1","crop2","crop3"]);
            }
            else if(this.m_harvestResource.getClassName() == "Tree")
            {
               SoundManager.chooseAndPlaySound(["tree1","tree2","tree3"]);
            }
         }
      }
      
      override public function added() : void
      {
         super.added();
         this.m_harvestResource.setActionState(HarvestableResource.IS_HARVESTING);
      }
      
      override public function removed() : void
      {
         super.removed();
         this.m_harvestResource.setActionState(HarvestableResource.IS_RESTING);
      }
   }
}

