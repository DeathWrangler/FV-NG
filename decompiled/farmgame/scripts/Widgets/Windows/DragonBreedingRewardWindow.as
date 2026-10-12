package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.DragonBreeding.DragonBreedingSkillState;
   import Classes.util.ZLocUtils;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class DragonBreedingRewardWindow extends DragonBreedingBaseRewardWindow
   {
      
      private const DEFAULT_ASSET:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_LevelUp.swf";
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESC_TF:String = "level_tf";
      
      private const INFO_TF:String = "description_tf";
      
      private const COUNT_TF:String = "count_tf";
      
      private const SHARE_BTN:String = "share_bt";
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_infoTf:ZwTextField;
      
      private var m_countTf:ZwTextField;
      
      private var m_shareBtn:FarmAnimatedTextButton;
      
      private var m_count:Number;
      
      public function DragonBreedingRewardWindow(featureName:String, count:Number = 1, windowAssetRelUrl:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_LevelUp.swf")
      {
         m_featureName = featureName;
         this.m_count = count;
         var skillState:DragonBreedingSkillState = Global.player.getDragonBreedingSkillStateForFeature(m_featureName);
         m_level = skillState.level;
         super(featureName,windowAssetRelUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
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
         if(m_window.hasOwnProperty(this.COUNT_TF))
         {
            this.m_countTf = addWidget(new ZwTextField(m_window[this.COUNT_TF],"x" + this.m_count.toString()),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.SHARE_BTN))
         {
            this.m_shareBtn = addWidget(new FarmAnimatedTextButton(m_window[this.SHARE_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_LevelUpWindow_ShareBtnText"),this.onShare),true) as FarmAnimatedTextButton;
         }
      }
      
      private function onShare(e:Event) : void
      {
         DragonBreedingManager.getInstance(m_featureName).shareBragFeed(DragonBreedingManager.BRAG_FEED_UNLOCK_LEVEL);
         close();
      }
   }
}

