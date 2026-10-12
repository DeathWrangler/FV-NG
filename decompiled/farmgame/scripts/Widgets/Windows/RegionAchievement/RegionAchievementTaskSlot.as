package Widgets.Windows.RegionAchievement
{
   import Classes.Quest.FarmTask;
   import Classes.RegionAchievement.RegionAchievement;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Events.RegionAchievementEvent;
   import Managers.RegionAchievementManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class RegionAchievementTaskSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private static const PROGRESS_NONE_POINT:int = 0;
      
      private static const PROGRESS_BRONZE_POINT:int = 20;
      
      private static const PROGRESS_SILVER_POINT:int = 40;
      
      private static const PROGRESS_GOLD_POINT:int = 60;
      
      private static const STARS_MC:String = "stars_mc";
      
      private static const ICON_MC:String = "icon_mc";
      
      private static const PROGRESS_BAR_MC:String = "progressBar_mc";
      
      private static const COMPLETE_MC:String = "completeIcon_mc";
      
      private static const TASK_BTN:String = "task_bt";
      
      private static const DISMISS_BTN:String = "dismiss_bt";
      
      private static const BRONZE_STAR_MC:String = "bronze_mc";
      
      private static const SILVER_STAR_MC:String = "silver_mc";
      
      private static const GOLD_STAR_MC:String = "gold_mc";
      
      private static const REGION_ICON_MC:String = "regionIcon_mc";
      
      private static const TEXT_ICON_MC:String = "textIcon_mc";
      
      private static const FINISHED_BG_MC:String = "finished_mc";
      
      private static const TROPHY_DESC_TF:String = "trophyDescription_tf";
      
      private static const TIMER_TF:String = "timer_tf";
      
      private static const TEXT_ICON_TROPHY_DESC_TF:String = "trophyDescription1_tf";
      
      private var m_icon:FarmIcon;
      
      private var m_regionIcon:MovieClip;
      
      private var m_trophyDescription:ZwTextField;
      
      private var m_textIconTrophyDescription:ZwTextField;
      
      private var m_timerText:ZwTextField;
      
      private var m_bronzeStarMC:MovieClip;
      
      private var m_silverStarMC:MovieClip;
      
      private var m_goldStarMC:MovieClip;
      
      private var m_starsMC:ZwFrame;
      
      private var m_textIconMC:ZwFrame;
      
      private var m_timer:Timer;
      
      private var m_featureName:String;
      
      private var m_achievement:RegionAchievement;
      
      private var m_regionId:String;
      
      private var m_achId:String;
      
      private var m_completeIcon:MovieClip;
      
      private var m_finishedBG:MovieClip;
      
      private var m_taskButton:FarmAnimatedTextButton;
      
      private var m_dismissButton:FarmAnimatedTextButton;
      
      private var m_progressBar:ZwWidget;
      
      public function RegionAchievementTaskSlot(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty(ICON_MC))
         {
            this.m_icon = addWidget(new FarmIcon(m_element[ICON_MC])) as FarmIcon;
         }
         if(m_element.hasOwnProperty(TEXT_ICON_MC))
         {
            this.m_textIconMC = addWidget(new ZwFrame(m_element[TEXT_ICON_MC])) as ZwFrame;
            if(this.m_textIconMC.element.hasOwnProperty(REGION_ICON_MC))
            {
               this.m_regionIcon = this.m_textIconMC.element[REGION_ICON_MC] as MovieClip;
            }
            if(this.m_textIconMC.element.hasOwnProperty(TEXT_ICON_TROPHY_DESC_TF))
            {
               this.m_textIconTrophyDescription = this.m_textIconMC.addWidget(new ZwTextField(this.m_textIconMC.element[TEXT_ICON_TROPHY_DESC_TF]," ")) as ZwTextField;
            }
         }
         if(m_element.hasOwnProperty(TROPHY_DESC_TF))
         {
            this.m_trophyDescription = addWidget(new ZwTextField(m_element[TROPHY_DESC_TF]," ")) as ZwTextField;
         }
         if(m_element.hasOwnProperty(TIMER_TF))
         {
            this.m_timerText = addWidget(new ZwTextField(m_element[TIMER_TF]," ")) as ZwTextField;
         }
         if(m_element.hasOwnProperty(PROGRESS_BAR_MC))
         {
            this.m_progressBar = addWidget(new ZwWidget(m_element[PROGRESS_BAR_MC])) as ZwWidget;
         }
         if(m_element.hasOwnProperty(COMPLETE_MC))
         {
            this.m_completeIcon = m_element[COMPLETE_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(FINISHED_BG_MC))
         {
            this.m_finishedBG = m_element[FINISHED_BG_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(TASK_BTN))
         {
            this.m_taskButton = addWidget(new FarmAnimatedTextButton(m_element[TASK_BTN]," ",this.onClaimClick)) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty(DISMISS_BTN))
         {
            this.m_dismissButton = addWidget(new FarmAnimatedTextButton(m_element[DISMISS_BTN]," ",this.onDismissClick)) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty(STARS_MC))
         {
            this.m_starsMC = addWidget(new ZwFrame(m_element[STARS_MC])) as ZwFrame;
            this.m_bronzeStarMC = this.m_starsMC.element[BRONZE_STAR_MC] as MovieClip;
            this.m_silverStarMC = this.m_starsMC.element[SILVER_STAR_MC] as MovieClip;
            this.m_goldStarMC = this.m_starsMC.element[GOLD_STAR_MC] as MovieClip;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_achievement = data as RegionAchievement;
         this.m_regionId = this.m_achievement.regionId;
         this.m_achId = this.m_achievement.name;
         this.m_textIconMC.visible = true;
         this.m_starsMC.visible = true;
         this.m_bronzeStarMC.gotoAndStop(2);
         this.m_silverStarMC.gotoAndStop(2);
         this.m_goldStarMC.gotoAndStop(2);
         this.m_completeIcon.visible = false;
         this.m_finishedBG.visible = false;
         this.m_bronzeStarMC.visible = true;
         this.m_silverStarMC.visible = true;
         this.m_goldStarMC.visible = true;
         this.m_dismissButton.visible = false;
         this.m_taskButton.text = ZLocUtils.t("Dialogs",this.m_featureName + "_claim_bt_text");
         this.m_dismissButton.text = ZLocUtils.t("Dialogs",this.m_featureName + "_dismiss_bt_text");
         this.m_timerText.visible = false;
         if(this.m_achievement.canClaim)
         {
            this.m_taskButton.visible = true;
            this.m_taskButton.applyGrayOut = false;
            this.m_taskButton.enabled = true;
         }
         else if(this.m_achievement.expired && !this.m_achievement.dismissed && !this.m_achievement.goldTrophyWon)
         {
            this.m_dismissButton.visible = true;
         }
         else
         {
            this.m_taskButton.applyGrayOut = true;
            this.m_taskButton.enabled = false;
            this.m_taskButton.visible = true;
         }
         if(this.m_achievement.timed && !this.m_achievement.dismissed && !this.m_taskButton.visible && !this.m_achievement.goldTrophyWon)
         {
            this.m_timerText.text = this.m_achievement.expiryTimer;
            this.m_timerText.visible = true;
         }
         if(this.m_achievement.trophyWon >= RegionAchievementManager.BRONZE_TROPHY)
         {
            this.m_bronzeStarMC.gotoAndStop(1);
         }
         if(this.m_achievement.trophyWon >= RegionAchievementManager.SILVER_TROPHY)
         {
            this.m_silverStarMC.gotoAndStop(1);
         }
         if(this.m_achievement.goldTrophyWon)
         {
            this.m_goldStarMC.gotoAndStop(1);
            this.m_completeIcon.visible = true;
            this.m_finishedBG.visible = true;
            this.m_taskButton.visible = false;
            this.m_dismissButton.visible = false;
         }
         if(this.m_achievement.timed)
         {
            this.m_silverStarMC.visible = false;
            this.m_bronzeStarMC.visible = false;
         }
         this.setProgressBar();
         this.m_icon.loadIcon(this.m_achievement.trophyUrl);
         this.m_icon.visible = true;
         var descParams:Object = this.m_achievement.descriptionParams();
         if(Boolean(descParams) && descParams.hasOwnProperty("description"))
         {
            if(descParams.hasOwnProperty("includeRegionIcon") && descParams.includeRegionIcon == true && descParams.hasOwnProperty("regionId") && descParams.regionId != "")
            {
               this.m_textIconTrophyDescription.text = descParams.description;
               this.m_textIconTrophyDescription.visible = true;
               this.m_regionIcon.gotoAndStop(int(descParams.regionId));
               this.m_regionIcon.visible = true;
               this.m_trophyDescription.visible = false;
            }
            else
            {
               this.m_trophyDescription.text = descParams.description;
               this.m_trophyDescription.visible = true;
               this.m_textIconTrophyDescription.visible = false;
               this.m_regionIcon.visible = false;
            }
         }
         this.refreshUi();
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_regionIcon = null;
         this.m_completeIcon = null;
         this.m_trophyDescription = null;
         this.m_taskButton = null;
         this.m_progressBar = null;
         this.killTimer();
         super.release();
      }
      
      private function setProgressBar() : void
      {
         var totalFrames:int = 0;
         var progress:int = 0;
         if(Boolean(this.m_progressBar) && Boolean(this.m_progressBar.element))
         {
            totalFrames = int(this.m_progressBar.element.totalFrames);
            progress = totalFrames / this.m_achievement.numOfMilestones * this.m_achievement.numOfMileStonesCompleted;
            this.m_progressBar.element.gotoAndStop(progress);
            this.m_progressBar.visible = true;
         }
      }
      
      private function generateActionCallback(questTask:FarmTask) : Function
      {
         return function():void
         {
         };
      }
      
      private function onClaimClick(e:Event) : void
      {
         this.m_taskButton.visible = false;
         RegionAchievementManager.getInstance(this.m_featureName).claimAchievementRewards(this.m_regionId,this.m_achId);
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.REFRESH_UI));
      }
      
      private function onDismissClick(e:Event) : void
      {
         this.m_dismissButton.visible = false;
         RegionAchievementManager.getInstance(this.m_featureName).setDismissedTimedAchievement(this.m_regionId,this.m_achId);
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.REFRESH_UI));
      }
      
      private function killTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.refreshUi);
            this.m_timer = null;
         }
      }
      
      private function initTimer() : void
      {
         if(!this.m_timer)
         {
            this.m_timer = new Timer(FarmGameUtil.NUM_MSECS_IN_SECOND);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.refreshUi);
            this.m_timer.start();
         }
      }
      
      private function refreshUi(e:TimerEvent = null) : void
      {
         if(this.m_achievement.timed)
         {
            if(!this.m_achievement.dismissed && !this.m_achievement.goldTrophyWon && !this.m_achievement.canClaim)
            {
               this.initTimer();
               this.m_timerText.text = this.m_achievement.expiryTimer;
               this.m_timerText.visible = true;
            }
         }
      }
   }
}

