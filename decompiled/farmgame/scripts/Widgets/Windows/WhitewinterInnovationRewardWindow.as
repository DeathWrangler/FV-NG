package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Managers.WhitewinterInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Frames.WhitewinterInnovationRewardWindowFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class WhitewinterInnovationRewardWindow extends FarmWindow
   {
      
      private static const REWARD_FTUE_FLAG:String = "rewardftue";
      
      private var m_featureName:String;
      
      private var m_loadingWidget:ZwWidget;
      
      private var m_subTitleTextField:FarmTextField;
      
      private var m_genericTextField:FarmTextField;
      
      private var m_rewardCountFrame:ZwFrame;
      
      private var m_rewardCountTextField:FarmTextField;
      
      private var m_slots:WhitewinterInnovationRewardWindowFrame;
      
      private var m_acceptButton:FarmAnimatedButton;
      
      private var m_className:String;
      
      private var m_manager:WhitewinterInnovationManager = WhitewinterInnovationManager.getInstance();
      
      private var m_isDisplayFlag:Boolean = true;
      
      private var m_bonus1MC:MovieClip;
      
      private var m_bonus2MC:MovieClip;
      
      private var m_bonus3MC:MovieClip;
      
      private var m_bonusSlot1mc:MovieClip;
      
      private var m_bonusSlot2mc:MovieClip;
      
      private var m_bonusSlot3mc:MovieClip;
      
      private var m_mileStone1CheckMark:MovieClip;
      
      private var m_mileStone2CheckMark:MovieClip;
      
      private var m_mileStone3CheckMark:MovieClip;
      
      private var name1_tf:FarmTextField;
      
      private var name2_tf:FarmTextField;
      
      private var name3_tf:FarmTextField;
      
      private var date1_tf:FarmTextField;
      
      private var date2_tf:FarmTextField;
      
      private var date3_tf:FarmTextField;
      
      private var m_giftcount_tf:FarmTextField;
      
      private var m_giftbox_tf:FarmTextField;
      
      private var m_countMc:MovieClip;
      
      private const TOTAL_NUM_OF_TUTORIAL_PAGES:int = 3;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private var m_whatIsThis_mc:FarmAnimatedButton;
      
      private var m_showGrant:Boolean;
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Show me","Okay","Let’s Play!"];
      
      private var m_ftueOn:Boolean = false;
      
      private var m_tutorialFeatureName:String;
      
      protected var m_ftue:MovieClip = null;
      
      protected var m_tutorialButton:FarmAnimatedTextButton;
      
      protected var m_tutorialScene:int;
      
      public function WhitewinterInnovationRewardWindow(featureName:String, assetPath:String, showGrant:Boolean = false)
      {
         this.m_tutorialFeatureName = featureName + "GiftUI";
         super(assetPath);
         this.m_featureName = featureName;
         this.m_className = "WhitewinterInnovationRewardWindow";
         this.m_showGrant = showGrant;
      }
      
      override protected function postLoadComplete() : void
      {
         var subtitle:String = null;
         var m_bonus1MCtooltip:FarmIcon = null;
         var m_bonus2MCtooltip:FarmIcon = null;
         var m_bonus3MCtooltip:FarmIcon = null;
         super.postLoadComplete();
         var firstTimeSeenFlag:String = this.m_tutorialFeatureName + REWARD_FTUE_FLAG;
         if(m_window)
         {
            MovieClipUtils.recursivePlay(m_window);
            if(m_window.title_tf)
            {
               addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"WhitewinterInnovation_HUDIcon_Tooltip")));
            }
            if(m_window.body_tf)
            {
               subtitle = "Here are all the presents you have!";
               this.m_subTitleTextField = new FarmTextField(m_window.body_tf,subtitle);
               addWidget(this.m_subTitleTextField);
            }
            if(m_window.giftbox_tf)
            {
               this.m_giftbox_tf = new FarmTextField(m_window.giftbox_tf,"Find Open Gifts in Your GIFT BOX");
               addWidget(this.m_giftbox_tf);
            }
            if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
            {
               this.m_whatIsThis_mc = addWidget(new FarmAnimatedButton(m_window[this.WHATISTHIS_MC],this.howDoesThisWorkClick),true) as FarmAnimatedButton;
            }
            if(m_window.count_mc)
            {
               this.m_countMc = m_window.count_mc;
               this.m_countMc.visible = true;
               if(this.m_countMc.hasOwnProperty("giftcount_tf"))
               {
                  this.m_giftcount_tf = new FarmTextField(this.m_countMc.giftcount_tf);
                  this.m_giftcount_tf.text = this.manager.getCurrentStage().toString() + "/" + this.manager.rewardsArray.length.toString();
               }
            }
            if(m_window.slots_mc)
            {
               this.m_slots = new WhitewinterInnovationRewardWindowFrame(m_window.slots_mc);
               addWidget(this.m_slots,true);
            }
            if(m_window.hasOwnProperty("bonus1_mc"))
            {
               this.m_bonus1MC = m_window.bonus1_mc;
               this.m_bonus1MC.visible = true;
               this.m_bonusSlot1mc = m_window.bonusSlot1_mc as MovieClip;
               this.m_bonusSlot1mc.visible = true;
               if(this.manager.hasDatePassedForSlot(this.manager.MILESTONE_STAGES[0] - 1) && !this.manager.isMileStoneAchieved(1))
               {
                  this.m_bonus1MC.visible = false;
                  this.m_bonusSlot1mc.visible = false;
               }
               this.m_mileStone1CheckMark = this.m_bonus1MC.checkmark_mc;
               this.m_mileStone1CheckMark.visible = this.manager.isMileStoneAchieved(1);
               m_bonus1MCtooltip = new FarmIcon(this.m_bonus1MC);
               m_bonus1MCtooltip.attachTooltip(new FarmTextTooltip("Holiday Blast Pegasus"));
            }
            if(m_window.name1_tf)
            {
               this.name1_tf = new FarmTextField(m_window.name1_tf,WhitewinterInnovationManager.COLLECTION1);
               addWidget(this.name1_tf);
            }
            if(m_window.date1_tf)
            {
               this.date1_tf = new FarmTextField(m_window.date1_tf,"25th Dec");
               addWidget(this.date1_tf);
            }
            if(m_window.hasOwnProperty("bonus2_mc"))
            {
               this.m_bonus2MC = m_window.bonus2_mc;
               this.m_bonus2MC.visible = true;
               this.m_bonusSlot2mc = m_window.bonusSlot2_mc as MovieClip;
               this.m_bonusSlot2mc.visible = true;
               if(this.manager.hasDatePassedForSlot(this.manager.MILESTONE_STAGES[1] - 1) && !this.manager.isMileStoneAchieved(2))
               {
                  this.m_bonus2MC.visible = false;
                  this.m_bonusSlot2mc.visible = false;
               }
               this.m_mileStone2CheckMark = this.m_bonus2MC.checkmark_mc;
               this.m_mileStone2CheckMark.visible = this.manager.isMileStoneAchieved(2);
               m_bonus2MCtooltip = new FarmIcon(this.m_bonus2MC);
               m_bonus2MCtooltip.attachTooltip(new FarmTextTooltip("New Year Fun Horse"));
            }
            if(m_window.name2_tf)
            {
               this.name2_tf = new FarmTextField(m_window.name2_tf,WhitewinterInnovationManager.COLLECTION2);
               addWidget(this.name2_tf);
            }
            if(m_window.date2_tf)
            {
               this.date2_tf = new FarmTextField(m_window.date2_tf,"1st Jan");
               addWidget(this.date2_tf);
            }
            if(m_window.hasOwnProperty("bonus3_mc"))
            {
               this.m_bonus3MC = m_window.bonus3_mc;
               this.m_bonus3MC.visible = true;
               this.m_bonusSlot3mc = m_window.bonusSlot3_mc as MovieClip;
               this.m_bonusSlot3mc.visible = true;
               if(this.manager.hasDatePassedForSlot(this.manager.MILESTONE_STAGES[2] - 1) && !this.manager.isMileStoneAchieved(3))
               {
                  this.m_bonus3MC.visible = false;
                  this.m_bonusSlot3mc.visible = false;
               }
               this.m_mileStone3CheckMark = this.m_bonus3MC.checkmark_mc;
               this.m_mileStone3CheckMark.visible = this.manager.isMileStoneAchieved(3);
               m_bonus3MCtooltip = new FarmIcon(this.m_bonus3MC);
               m_bonus3MCtooltip.attachTooltip(new FarmTextTooltip("Ice Skating Fun"));
            }
            if(m_window.name3_tf)
            {
               this.name3_tf = new FarmTextField(m_window.name3_tf,WhitewinterInnovationManager.COLLECTION3);
               addWidget(this.name3_tf);
            }
            if(m_window.date3_tf)
            {
               this.date3_tf = new FarmTextField(m_window.date3_tf,"5th Jan");
               addWidget(this.date3_tf);
            }
         }
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            this.showFTUE();
         }
      }
      
      override protected function release() : void
      {
         this.m_featureName = null;
         this.m_loadingWidget = null;
         this.m_subTitleTextField = null;
         this.m_genericTextField = null;
         this.m_rewardCountFrame = null;
         this.m_rewardCountTextField = null;
         this.m_slots = null;
         this.m_acceptButton = null;
         super.release();
      }
      
      public function get manager() : WhitewinterInnovationManager
      {
         return WhitewinterInnovationManager.getInstance();
      }
      
      override public function close() : void
      {
         var featureEndDate:Number = NaN;
         this.manager.grantAllEligibleRewards();
         featureEndDate = FarmGameUtil.synchronizedDateToNumber(this.manager.dateArray[this.manager.MILESTONE_STAGES[2] - 1]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(currentTime < featureEndDate)
         {
            this.manager.showMainUI();
         }
         super.close();
      }
      
      public function isShowGrantMC() : Boolean
      {
         return this.m_showGrant;
      }
      
      protected function getNumTutorialScenes() : int
      {
         return this.TOTAL_NUM_OF_TUTORIAL_PAGES;
      }
      
      protected function showFTUE() : void
      {
         if(!this.m_ftue)
         {
            this.setupFTUE();
         }
         if(this.m_ftue)
         {
            this.m_tutorialScene = 1;
            this.m_ftue.gotoAndStop(this.m_tutorialScene);
            this.m_tutorialButton.text = this.TUTORIAL_BUTTON_TEXT_ARRAY[this.m_tutorialScene - 1];
            this.m_ftue.visible = true;
            this.m_ftueOn = true;
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.showFTUE();
      }
      
      protected function setupFTUE() : void
      {
         this.m_tutorialScene = 1;
         if(Boolean(m_window) && Boolean(m_window.tutorial_mc))
         {
            this.m_ftue = m_window.tutorial_mc as MovieClip;
            if(this.m_ftue)
            {
               this.m_ftue.visible = false;
               if(this.m_tutorialButton == null && this.m_ftue.hasOwnProperty("okay_bt"))
               {
                  addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(this.m_ftue.okay_bt,this.TUTORIAL_BUTTON_TEXT_ARRAY[this.m_tutorialScene - 1],this.onFTUEOKBtnClick));
               }
            }
         }
      }
      
      protected function onFTUEOKBtnClick(event:Event) : void
      {
         var firstTimeSeenFlag:String = null;
         if(this.m_tutorialScene++ < this.getNumTutorialScenes())
         {
            this.m_tutorialButton.text = this.TUTORIAL_BUTTON_TEXT_ARRAY[this.m_tutorialScene - 1];
            (this.m_ftue as MovieClip).play();
         }
         else
         {
            firstTimeSeenFlag = this.m_tutorialFeatureName + REWARD_FTUE_FLAG;
            Global.player.setSeenFlag(firstTimeSeenFlag);
            this.m_ftue.visible = false;
            this.m_ftueOn = false;
         }
      }
   }
}

