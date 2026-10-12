package Widgets.Windows
{
   import Classes.Animal;
   import Classes.Constants.ZLocConstants;
   import Classes.DragonBreeding.DragonBreedingSkillState;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.DragonBreedingConfigManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   
   public class DragonBreedingBaseRewardWindow extends FarmWindow
   {
      
      private const UNLOCK_MC:String = "unlock_mc";
      
      private const UNLOCK_TF:String = "unlock_tf";
      
      private const UNLOCK_ICON_MC:String = "icon_mc";
      
      protected var m_featureName:String;
      
      protected var m_level:int;
      
      private var m_unlockMC:MovieClip;
      
      private var m_unlockTF:ZwTextField;
      
      private var m_nextDragonAsset:String;
      
      private var m_nextDragonTooltip:String;
      
      private var m_nextDragonExportName:String;
      
      private var m_nextDragonUnlockLevel:Number;
      
      public function DragonBreedingBaseRewardWindow(featureName:String, windowAssetRelUrl:String)
      {
         var rewardDragonName:String = null;
         var dragonItem:FarmItem = null;
         this.m_featureName = featureName;
         var skillState:DragonBreedingSkillState = Global.player.getDragonBreedingSkillStateForFeature(this.m_featureName);
         this.m_level = skillState.level;
         var nextBigRewardLevel:Number = DragonBreedingConfigManager.getInstance(this.m_featureName).getNextBigReward(this.m_level);
         if(nextBigRewardLevel)
         {
            rewardDragonName = DragonBreedingConfigManager.getInstance(this.m_featureName).getRewardFromLevel(nextBigRewardLevel);
            if(rewardDragonName)
            {
               dragonItem = Global.farmGameSettingsManager.getFarmItemByName(rewardDragonName);
               if(dragonItem)
               {
                  this.m_nextDragonTooltip = dragonItem.friendlyTitle;
                  this.m_nextDragonExportName = dragonItem.overrideExportName + "_" + Animal.STATE_FRONT_IDLE;
                  this.m_nextDragonUnlockLevel = nextBigRewardLevel;
                  this.m_nextDragonAsset = dragonItem.imageRelativeUrl(Animal.STATE_FRONT_IDLE);
               }
            }
         }
         super(windowAssetRelUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var m_objectFrame:ResourcePreviewFrame = null;
         var unlockText:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.UNLOCK_MC))
         {
            this.m_unlockMC = m_window[this.UNLOCK_MC];
            this.m_unlockMC.visible = false;
            if(Boolean(this.m_unlockMC.hasOwnProperty(this.UNLOCK_ICON_MC)) && Boolean(this.m_nextDragonAsset) && Boolean(this.m_nextDragonUnlockLevel))
            {
               m_objectFrame = addWidget(new ResourcePreviewFrame(this.m_unlockMC[this.UNLOCK_ICON_MC],this.m_nextDragonAsset,this.m_nextDragonExportName,true)) as ResourcePreviewFrame;
               m_objectFrame.attachTooltip(new FarmTextTooltip(this.m_nextDragonTooltip));
               if(this.m_unlockMC.hasOwnProperty(this.UNLOCK_TF))
               {
                  unlockText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_LevelUpWindow_UnlockText",{"level":this.m_nextDragonUnlockLevel.toString()});
                  this.m_unlockTF = addWidget(new ZwTextField(this.m_unlockMC[this.UNLOCK_TF],unlockText)) as ZwTextField;
               }
            }
         }
      }
   }
}

