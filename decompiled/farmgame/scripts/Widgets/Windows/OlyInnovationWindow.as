package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.CommunityGoalsManager;
   import Managers.FarmStatsManager;
   import Managers.OlyInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class OlyInnovationWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 5;
      
      protected var m_featureName:String;
      
      private var m_currencyFrame:ZwFrame;
      
      private var m_tileContainerFrame:GenericSlotContainerFrame;
      
      private var m_buildingContainerFrame:GenericSlotContainerFrame;
      
      private var m_communityGoalsBt:FarmAnimatedTextButton;
      
      private var m_goldCount:ZwTextField;
      
      private var m_findButtons:Array = new Array();
      
      private var m_goldIcon:FarmIcon;
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const GOLD_MC:String = "gold_mc";
      
      private const GOLDICON_MC:String = "goldIcon_mc";
      
      private const TEXT_WHATISTHIS:String = "_howDoesThisWork";
      
      private const PLAY_CG_BT:String = "play_bt";
      
      private const BUY_GOLD_BT:String = "buy_bt";
      
      private const GOLDCOUNT_TF:String = "goldcount_tf";
      
      private const TILES_MC:String = "tiles_mc";
      
      private const BUILDINGS_MC:String = "buildings_mc";
      
      private const TEXT_TITLE:String = "_title";
      
      private const TEXT_DESCRIPTION:String = "_description";
      
      private const TEXT_CGBUTTON:String = "_cgbutton";
      
      private const TEXT_BUYGOLD:String = "_buygold";
      
      private const TEXT_GOLDICON:String = "_goldicon_tooltip";
      
      private const TEXT_CGINACTIVE:String = "_cginactive";
      
      public function OlyInnovationWindow(assetUrl:String, featureName:String)
      {
         this.m_featureName = featureName;
         super(featureName,assetUrl,NUM_TUTORIAL_SCENES);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.m_currencyFrame = this.loadCurrencyFrame();
         this.loadFire();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)));
         }
         if(m_window.hasOwnProperty(this.DESCRIPTION_TF))
         {
            addWidget(new ZwTextField(m_window[this.DESCRIPTION_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_DESCRIPTION))) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.TILES_MC))
         {
            this.m_tileContainerFrame = new GenericSlotContainerFrame(m_window[this.TILES_MC],OlyInnovationSlot,null,this);
            addWidget(this.m_tileContainerFrame);
            this.m_tileContainerFrame.setData(OlyInnovationManager.getInstance().tileConfig);
         }
         if(m_window.hasOwnProperty(this.BUILDINGS_MC))
         {
            this.m_buildingContainerFrame = new GenericSlotContainerFrame(m_window[this.BUILDINGS_MC],OlyInnovationSlot,null,this);
            addWidget(this.m_buildingContainerFrame);
            this.m_buildingContainerFrame.setData(OlyInnovationManager.getInstance().buildingConfig);
         }
         this.refreshWindow();
         FarmStatsManager.count(this.m_featureName,"feature_ui","main_ui","impression");
      }
      
      private function loadFire() : void
      {
         var fireIndex:int = 0;
         while(m_window.hasOwnProperty("fire_" + fireIndex))
         {
            if(!OlyInnovationManager.getInstance().isTaskComplete(fireIndex + 1))
            {
               (m_window["fire_" + fireIndex] as MovieClip).visible = true;
            }
            fireIndex++;
         }
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      private function loadCurrencyFrame() : ZwFrame
      {
         var frame:ZwFrame = null;
         if(m_window.hasOwnProperty(this.GOLD_MC))
         {
            frame = new ZwFrame(m_window[this.GOLD_MC]);
            frame.visible = true;
         }
         if(frame.element[this.GOLDICON_MC])
         {
            addWidget(this.m_goldIcon = new FarmIcon(frame.element[this.GOLDICON_MC]));
            this.m_goldIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_GOLDICON)));
         }
         if(frame.element.hasOwnProperty(this.PLAY_CG_BT))
         {
            this.m_communityGoalsBt = addWidget(new FarmAnimatedTextButton(frame.element[this.PLAY_CG_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_CGBUTTON),this.openCommunityGoalsUI)) as FarmAnimatedTextButton;
         }
         if(frame.element.hasOwnProperty(this.BUY_GOLD_BT))
         {
            addWidget(new FarmAnimatedTextButton(frame.element[this.BUY_GOLD_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BUYGOLD),this.openBuyCurrencyUI));
         }
         if(frame.element.hasOwnProperty(this.GOLDCOUNT_TF))
         {
            this.m_goldCount = new FarmTextField(frame.element[this.GOLDCOUNT_TF],"x" + OlyInnovationManager.getInstance().getcurrencyCount());
            this.m_goldCount.visible = true;
         }
         return frame;
      }
      
      protected function openCommunityGoalsUI(event:Event) : void
      {
         this.close();
         CommunityGoalsManager.getInstance().displayDialog();
      }
      
      protected function openBuyCurrencyUI(event:Event) : void
      {
         tintWindow();
         enableInput = false;
         OlyInnovationManager.getInstance().openBuyWindow(this);
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         if(OlyInnovationManager.getInstance().isCommunityGoalsActive())
         {
            this.m_communityGoalsBt.toggleClickableButton(true);
         }
         else
         {
            this.m_communityGoalsBt.toggleClickableButton(false,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_CGINACTIVE));
         }
         this.m_goldCount.text = "x" + OlyInnovationManager.getInstance().getcurrencyCount();
         this.m_tileContainerFrame.refresh();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         FarmStatsManager.count(this.m_featureName,"FTUE","FTUE_ui_triggered","click");
         showTutorial();
      }
   }
}

