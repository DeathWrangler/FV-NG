package Widgets.Windows
{
   import Classes.Animal;
   import Classes.Constants.ZLocConstants;
   import Classes.DragonBreeding.DragonBreedingSkillState;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ResourcePreviewFrame;
   import flash.events.Event;
   
   public class DragonBreedingLevelUpWindow extends DragonBreedingBaseRewardWindow
   {
      
      private const DEFAULT_ASSET:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_NewDragon.swf";
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESC_TF:String = "level_tf";
      
      private const INFO_TF:String = "description_tf";
      
      private const HERBS_TF:String = "count_tf";
      
      private const DRAGON_MC:String = "icon_mc_0";
      
      private const DRAGON_TF:String = "dragonname_tf";
      
      private const SHARE_BTN:String = "share_bt";
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_infoTf:ZwTextField;
      
      private var m_dragonIcon:ResourcePreviewFrame;
      
      private var m_herbsTf:ZwTextField;
      
      private var m_dragonTf:ZwTextField;
      
      private var m_shareBtn:FarmAnimatedTextButton;
      
      private var m_numHerbs:Number;
      
      private var m_dragonCode:String;
      
      public function DragonBreedingLevelUpWindow(featureName:String, dragonCode:String, numHerbs:Number = 1, windowAssetRelUrl:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_NewDragon.swf")
      {
         m_featureName = featureName;
         this.m_numHerbs = numHerbs;
         this.m_dragonCode = dragonCode;
         var skillState:DragonBreedingSkillState = Global.player.getDragonBreedingSkillStateForFeature(m_featureName);
         m_level = skillState.level;
         super(featureName,windowAssetRelUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var exportName:String = null;
         super.postLoadComplete();
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_dragonCode);
         var dragonName:String = item.friendlyTitle;
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            this.m_titleTf = addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_LevelUpWindow_title")),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.DESC_TF))
         {
            this.m_bodyTf = addWidget(new ZwTextField(m_window[this.DESC_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_LevelUpWindow_desc",{"level":m_level})),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.INFO_TF))
         {
            this.m_infoTf = addWidget(new ZwTextField(m_window[this.INFO_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_LevelUpWindow_info",{"level":m_level})),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.SHARE_BTN))
         {
            this.m_shareBtn = addWidget(new FarmAnimatedTextButton(m_window[this.SHARE_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_LevelUpWindow_ShareBtnText"),this.onShare),true) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty(this.HERBS_TF))
         {
            this.m_herbsTf = addWidget(new ZwTextField(m_window[this.HERBS_TF],"x" + this.m_numHerbs.toString())) as ZwTextField;
            if(this.m_numHerbs > 0)
            {
               this.m_herbsTf.visible = true;
            }
            else
            {
               this.m_herbsTf.visible = false;
            }
         }
         if(m_window.hasOwnProperty(this.DRAGON_MC))
         {
            exportName = item.overrideExportName + "_" + Animal.STATE_FRONT_IDLE;
            this.m_dragonIcon = addWidget(new ResourcePreviewFrame(m_window[this.DRAGON_MC],item.imageRelativeUrl(Animal.STATE_FRONT_IDLE),exportName,true)) as ResourcePreviewFrame;
         }
         if(m_window.hasOwnProperty(this.DRAGON_TF))
         {
            this.m_dragonTf = addWidget(new ZwTextField(m_window[this.DRAGON_TF],dragonName)) as ZwTextField;
            this.m_dragonTf.visible = true;
         }
      }
      
      private function onShare(e:Event) : void
      {
         DragonBreedingManager.getInstance(m_featureName).shareBragFeed(DragonBreedingManager.BRAG_FEED_UNLOCK_DRAGON);
         close();
      }
   }
}

