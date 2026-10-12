package Widgets.Windows.RegionAchievement
{
   import Classes.RegionAchievement.RegionAchievement;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Events.RegionAchievementEvent;
   import Managers.RegionAchievementManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class RegionAchievementMainTrophySlot extends ZwSlotFrame
   {
      
      private static const CLAIM_STATE:int = 1;
      
      private static const DISMISS_STATE:int = 2;
      
      private static const DISMISS_BTN:String = "dismiss_bt";
      
      private static const CLAIM_BTN:String = "task_bt";
      
      private static const TIMER_TF:String = "timer_tf";
      
      private static const ICON_MC:String = "trophy_mc";
      
      private static const TROPHY_TITLE_TF:String = "trophyTitle_tf";
      
      private static const CLICK2VIEW_TF:String = "view_tf";
      
      private static const STARS_MC:String = "stars_mc";
      
      private static const BRONZE_MC:String = "bronze_mc";
      
      private static const SILVER_MC:String = "silver_mc";
      
      private static const GOLD_MC:String = "gold_mc";
      
      private static const ANIMATION_MC:String = "animation_mc";
      
      private static const STAR_GRAY_STATE:int = 2;
      
      private static const STAR_COMPLETE_STATE:int = 1;
      
      private static const MOUSE_OUT_STATE:int = 1;
      
      private static const MOUSE_OVER_STATE:int = 2;
      
      private var m_dismissBtn:FarmAnimatedTextButton;
      
      private var m_claimBtn:FarmAnimatedTextButton;
      
      private var m_timerTxt:ZwTextField;
      
      private var m_trophyIcon:FarmIcon;
      
      private var m_click2View:ZwTextField;
      
      private var m_trophyTitle:ZwTextField;
      
      private var m_bronzeIcon:MovieClip;
      
      private var m_silverIcon:MovieClip;
      
      private var m_goldIcon:MovieClip;
      
      private var m_animationMc:MovieClip;
      
      private var m_starsMC:ZwFrame;
      
      private var m_regionId:String;
      
      private var m_achId:String;
      
      private var m_parentWindow:RegionAchievementWindow;
      
      private var m_featureName:String;
      
      private var m_questId:String;
      
      private var m_timer:Timer;
      
      private var m_achievement:RegionAchievement;
      
      public function RegionAchievementMainTrophySlot(element:DisplayObject, parentWindow:RegionAchievementWindow, featureName:String)
      {
         this.m_parentWindow = parentWindow;
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty(DISMISS_BTN))
         {
            addWidget(this.m_dismissBtn = new FarmAnimatedTextButton(m_element[DISMISS_BTN],ZLocUtils.t("Dialogs",this.m_featureName + "_dismiss_bt_text"),this.onDismiss));
         }
         if(m_element.hasOwnProperty(CLAIM_BTN))
         {
            addWidget(this.m_claimBtn = new FarmAnimatedTextButton(m_element[CLAIM_BTN],ZLocUtils.t("Dialogs",this.m_featureName + "_claim_bt_text"),this.onClaimBtnClick));
            this.m_claimBtn.visible = false;
         }
         if(m_element.hasOwnProperty(TIMER_TF))
         {
            addWidget(this.m_timerTxt = new ZwTextField(m_element[TIMER_TF],"00:00:00"));
         }
         if(m_element.hasOwnProperty(ICON_MC))
         {
            addWidget(this.m_trophyIcon = new FarmIcon(m_element[ICON_MC]));
            if(this.m_trophyIcon.element as MovieClip)
            {
               this.m_trophyIcon.element.buttonMode = true;
            }
         }
         if(m_element.hasOwnProperty(CLICK2VIEW_TF))
         {
            addWidget(this.m_click2View = new ZwTextField(m_element[CLICK2VIEW_TF],ZLocUtils.t("Dialogs",this.m_featureName + "_click2view")));
         }
         if(m_element.hasOwnProperty(TROPHY_TITLE_TF))
         {
            addWidget(this.m_trophyTitle = new ZwTextField(m_element[TROPHY_TITLE_TF],""));
         }
         if(m_element.hasOwnProperty(STARS_MC))
         {
            this.m_starsMC = addWidget(new ZwFrame(m_element[STARS_MC])) as ZwFrame;
            if(this.m_starsMC.element.hasOwnProperty(BRONZE_MC))
            {
               this.m_bronzeIcon = this.m_starsMC.element[BRONZE_MC] as MovieClip;
            }
            if(this.m_starsMC.element.hasOwnProperty(SILVER_MC))
            {
               this.m_silverIcon = this.m_starsMC.element[SILVER_MC] as MovieClip;
            }
            if(this.m_starsMC.element.hasOwnProperty(GOLD_MC))
            {
               this.m_goldIcon = this.m_starsMC.element[GOLD_MC] as MovieClip;
            }
         }
         if(m_element.hasOwnProperty(ANIMATION_MC))
         {
            this.m_animationMc = m_element[ANIMATION_MC] as MovieClip;
         }
      }
      
      override public function populate(data:Object) : void
      {
         this.m_achievement = data as RegionAchievement;
         if(Boolean(data) && Boolean(this.m_achievement))
         {
            super.populate(data);
            this.m_starsMC.visible = true;
            this.m_regionId = this.m_achievement.regionId;
            this.m_achId = this.m_achievement.name;
            m_element.gotoAndStop(MOUSE_OUT_STATE);
            if(this.m_trophyIcon)
            {
               this.m_trophyIcon.visible = true;
               this.m_trophyIcon.loadIcon(this.m_achievement.trophyUrl);
            }
            if(this.m_trophyTitle)
            {
               this.m_trophyTitle.visible = true;
            }
            if(this.m_bronzeIcon)
            {
               this.m_bronzeIcon.visible = true;
               this.m_bronzeIcon.gotoAndStop(STAR_GRAY_STATE);
            }
            if(this.m_silverIcon)
            {
               this.m_silverIcon.visible = true;
               this.m_silverIcon.gotoAndStop(STAR_GRAY_STATE);
            }
            if(this.m_goldIcon)
            {
               this.m_goldIcon.visible = true;
               this.m_goldIcon.gotoAndStop(STAR_GRAY_STATE);
            }
            if(this.m_click2View)
            {
               this.m_click2View.visible = false;
               this.m_click2View.enabled = false;
            }
            if(this.m_timerTxt)
            {
               this.m_timerTxt.visible = false;
            }
            this.m_trophyIcon.registerEventListener(MouseEvent.MOUSE_OVER,this.onTrophyMouserRollOver);
            this.m_trophyIcon.registerEventListener(MouseEvent.MOUSE_OUT,this.onTrophyMouserRollOut);
            this.m_trophyIcon.registerEventListener(MouseEvent.CLICK,this.onTrophyClick);
            this.updateTrophyStar(this.m_achievement.trophyWon);
            this.m_claimBtn.visible = this.m_achievement.canClaim;
            this.m_dismissBtn.visible = false;
            if(this.m_achievement.timed)
            {
               this.m_starsMC.visible = false;
               if(this.m_achievement.expired && !this.m_achievement.dismissed && !this.m_achievement.goldTrophyWon && !this.m_claimBtn.visible)
               {
                  this.m_dismissBtn.visible = true;
               }
               if(!this.m_achievement.expired && !this.m_achievement.goldTrophyWon && !this.m_claimBtn.visible)
               {
                  this.m_timerTxt.text = this.m_achievement.expiryTimer;
                  this.m_timerTxt.visible = true;
               }
            }
         }
         m_element.visible = true;
         this.refreshUi();
      }
      
      private function updateTrophyStar(claimedTrophies:int) : void
      {
         if(claimedTrophies >= RegionAchievementManager.BRONZE_TROPHY)
         {
            this.m_bronzeIcon.gotoAndStop(STAR_COMPLETE_STATE);
         }
         if(claimedTrophies >= RegionAchievementManager.SILVER_TROPHY)
         {
            this.m_silverIcon.gotoAndStop(STAR_COMPLETE_STATE);
         }
         if(claimedTrophies >= RegionAchievementManager.GOLD_TROPHY)
         {
            this.m_goldIcon.gotoAndStop(STAR_COMPLETE_STATE);
         }
      }
      
      private function onTrophyClick(eve:MouseEvent) : void
      {
         RegionAchievementManager.getInstance(this.m_featureName).claimAchievementRewards(this.m_regionId,this.m_achId);
      }
      
      private function onClaimBtnClick(e:MouseEvent) : void
      {
         RegionAchievementManager.getInstance(this.m_featureName).claimAchievementRewards(this.m_regionId,this.m_achId);
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.REFRESH_UI));
      }
      
      private function onDismiss(e:MouseEvent) : void
      {
         RegionAchievementManager.getInstance(this.m_featureName).setDismissedTimedAchievement(this.m_regionId,this.m_achId);
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.REFRESH_UI));
      }
      
      private function onTrophyMouserRollOver(eve:MouseEvent) : void
      {
         m_element.gotoAndStop(MOUSE_OVER_STATE);
         if(this.m_click2View)
         {
            this.m_click2View.visible = true;
         }
      }
      
      private function onTrophyMouserRollOut(eve:MouseEvent) : void
      {
         m_element.gotoAndStop(MOUSE_OUT_STATE);
         if(this.m_click2View)
         {
            this.m_click2View.visible = false;
         }
      }
      
      override public function release() : void
      {
         this.m_trophyIcon.unregisterEventListener(MouseEvent.MOUSE_OVER,this.onTrophyMouserRollOver);
         this.m_trophyIcon.unregisterEventListener(MouseEvent.MOUSE_OUT,this.onTrophyMouserRollOut);
         this.m_trophyIcon.unregisterEventListener(MouseEvent.CLICK,this.onTrophyClick);
         this.killTimer();
         super.release();
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
               this.m_timerTxt.text = this.m_achievement.expiryTimer;
               this.m_timerTxt.visible = true;
            }
            if(this.m_achievement.expired && !this.m_achievement.dismissed && !this.m_achievement.goldTrophyWon && !this.m_claimBtn.visible)
            {
               this.m_dismissBtn.visible = true;
               this.killTimer();
            }
         }
      }
   }
}

