package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.HarvestableResource;
   import Classes.Plot;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.SoundManager;
   import Managers.AvatarRetentionExperimentUtil;
   import Managers.FarmGameSettingsManager;
   import Widgets.Windows.BushelReportWindow;
   
   public class AMPlant extends AMActionState
   {
      
      private static const SFX_PLANT_IDS:Array = ["plant1","plant2","plant3"];
      
      private static const SFX_PLANT_PATHS:Array = ["assets/sounds/actions/sfx_plant_01.mp3","assets/sounds/actions/sfx_plant_02.mp3","assets/sounds/actions/sfx_plant_03.mp3"];
      
      private var m_plot:Plot;
      
      private var m_seedType:String;
      
      private var m_playOnReenter:Boolean = true;
      
      public function AMPlant(avatar:FarmAvatar, plot:Plot, seedType:String)
      {
         this.m_plot = plot;
         this.m_seedType = seedType;
         this.addPlantSounds();
         super(avatar,plot);
      }
      
      private function addPlantSounds() : void
      {
         var i:uint = 0;
         while(i < SFX_PLANT_IDS.length && i < SFX_PLANT_PATHS.length)
         {
            SoundManager.addSound(SFX_PLANT_IDS[i],Global.getAssetURL(SFX_PLANT_PATHS[i]),false);
            i++;
         }
      }
      
      override public function update(delta:Number) : void
      {
         var seedItem:SeedItem = null;
         var hasSeedPackage:Boolean = false;
         var lockedStates:Array = null;
         var progress:Number = NaN;
         var shouldAbortActions:Boolean = false;
         var seedCountStart:int = 0;
         var seedCountEnd:int = 0;
         var hasSeedPackageProperty:Boolean = false;
         var hasSeedHybridProperty:Boolean = false;
         var isHybrid:Boolean = false;
         if(m_actionStarted)
         {
            seedItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_seedType) as SeedItem;
            hasSeedPackage = Boolean(seedItem.seedpackage) && Global.player.hasSeed(this.m_seedType);
            lockedStates = seedItem.getLockedStates(seedItem);
            if(lockedStates.indexOf(FarmItem.UNLOCKED) >= 0 || hasSeedPackage || seedItem.isToolGenerated)
            {
               if(this.m_plot.isPlantable())
               {
                  m_actionTime += delta;
                  progress = m_actionTime / Global.farmGameSettingsManager.getNumber("plantTime");
                  if(progress > 1 || AvatarRetentionExperimentUtil.inNoWaitExperiment())
                  {
                     shouldAbortActions = false;
                     seedCountStart = Global.player.countSeeds(this.m_seedType);
                     this.m_plot.plant(this.m_seedType,HarvestableResource.ENERGY_SOURCE_AVATAR,0,true,!seedItem.isToolGenerated);
                     BushelReportWindow.conditionallyRefreshWindow();
                     seedCountEnd = Global.player.countSeeds(this.m_seedType);
                     if(Global.flashHotParams["AMPLANT_SEED_LICENSE_FIX_TEMPRT"] == true)
                     {
                        hasSeedPackageProperty = false;
                        hasSeedHybridProperty = false;
                        isHybrid = false;
                        if(FarmGameSettingsManager.isInDataSourceExperiment())
                        {
                           hasSeedPackageProperty = seedItem.hasPropertyInDataSource("seedpackage");
                           hasSeedHybridProperty = seedItem.hasPropertyInDataSource("isHybrid");
                           isHybrid = hasSeedHybridProperty && seedItem.isHybrid;
                        }
                        else
                        {
                           hasSeedPackageProperty = seedItem.xml.hasOwnProperty("seedpackage");
                           hasSeedHybridProperty = seedItem.xml.hasOwnProperty("@isHybrid");
                           isHybrid = hasSeedHybridProperty;
                        }
                        if(seedCountStart == 1 && seedCountEnd == 0 && (hasSeedPackageProperty && !Global.player.hasSeed(this.m_seedType) && !(isHybrid || seedItem.isSuperCrop())))
                        {
                           shouldAbortActions = true;
                        }
                     }
                     else if(hasSeedPackageProperty && !Global.player.hasSeed(this.m_seedType) && !(hasSeedHybridProperty || seedItem.isSuperCrop()))
                     {
                        shouldAbortActions = true;
                     }
                     m_avatar.setActionProgress(null);
                     m_avatar.getStateMachine().removeState(this);
                     if(shouldAbortActions)
                     {
                        abortActions();
                     }
                  }
                  else
                  {
                     m_avatar.setActionProgress(ZLocUtils.t("FarmGame","Planting"),progress);
                  }
               }
               else
               {
                  m_avatar.getStateMachine().removeState(this);
               }
            }
            else
            {
               abortActions();
            }
         }
      }
      
      override public function enter() : void
      {
         super.enter();
         if(!this.conditionallyPath() && this.m_actionStarted)
         {
            this.m_playOnReenter = false;
            SoundManager.chooseAndPlaySound(SFX_PLANT_IDS);
         }
      }
      
      override public function reenter() : void
      {
         super.reenter();
         if(this.m_playOnReenter && this.m_actionStarted)
         {
            SoundManager.chooseAndPlaySound(SFX_PLANT_IDS);
         }
      }
      
      override public function added() : void
      {
         super.added();
         this.m_plot.setActionState(HarvestableResource.IS_PLANTING);
         Global.hud.updateSeedingQueue(1,this.m_seedType);
      }
      
      override public function removed() : void
      {
         super.removed();
         this.m_plot.setActionState(HarvestableResource.IS_RESTING);
         Global.hud.updateSeedingQueue(-1,this.m_seedType);
      }
   }
}

