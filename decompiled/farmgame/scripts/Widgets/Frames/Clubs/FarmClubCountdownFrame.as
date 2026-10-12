package Widgets.Frames.Clubs
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.Clubs.FarmClubUtility;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Clubs.FarmClubWindow2;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FarmClubCountdownFrame extends ZwFrame
   {
      
      private var m_parentWindow:FarmClubWindow2 = null;
      
      private var m_plantNowButton:FarmAnimatedTextButton = null;
      
      private var m_plantNowIconFrame:ZwFrame = null;
      
      private var m_plantNowIcon:FarmIcon = null;
      
      private var m_currentTierCrop:FarmItem = null;
      
      private var m_timerFrame:ZwFrame = null;
      
      private var m_nextCropFrame:ZwFrame = null;
      
      private var m_timeLeftTooltip:FarmTextTooltip = null;
      
      private var m_timeLeftUpdateTimer:Timer = null;
      
      private var m_loaded:Boolean = false;
      
      public function FarmClubCountdownFrame(element:DisplayObject, parentWindow:FarmClubWindow2)
      {
         var daysLeft:int = 0;
         super(element);
         this.m_parentWindow = parentWindow;
         var timeLeft:int = FarmClubUtility.getTimeTillDeadDay();
         if(timeLeft > 0)
         {
            this.m_timerFrame = new ZwFrame(m_element.timer_mc);
            addWidget(this.m_timerFrame);
            daysLeft = Math.floor(timeLeft / FarmGameUtil.NUM_MSECS_IN_DAY);
            this.m_timerFrame.addWidget(new ZwTextField(this.m_timerFrame.element.dayNumber_tf,daysLeft.toString()));
            this.m_timerFrame.addWidget(new ZwTextField(this.m_timerFrame.element.daysLeft_tf,ZLocUtils.t("FarmClub","daysLeft")));
            (this.m_timerFrame.element as MovieClip).gotoAndStop(7 - daysLeft);
            this.m_timeLeftTooltip = new FarmTextTooltip(FarmGameUtil.toFriendlyTime(timeLeft / FarmGameUtil.NUM_MSECS_IN_SECOND));
            this.m_timerFrame.attachTooltip(this.m_timeLeftTooltip);
            this.m_timeLeftUpdateTimer = new Timer(1000);
            this.m_timeLeftUpdateTimer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timeLeftUpdateTimer.start();
         }
         else
         {
            timeLeft = FarmClubUtility.getTimeTillCompetition();
            this.m_nextCropFrame = new ZwFrame(m_element.nextCrop_mc);
            this.m_nextCropFrame.addWidget(new ZwTextField(this.m_nextCropFrame.element.description_tf,ZLocUtils.t("FarmClub","NoCompetition")));
            addWidget(this.m_nextCropFrame);
            this.m_timeLeftTooltip = new FarmTextTooltip(FarmGameUtil.toFriendlyTime(timeLeft / FarmGameUtil.NUM_MSECS_IN_SECOND));
            this.m_nextCropFrame.attachTooltip(this.m_timeLeftTooltip);
            this.m_timeLeftUpdateTimer = new Timer(1000);
            this.m_timeLeftUpdateTimer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timeLeftUpdateTimer.start();
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(this.m_timerFrame != null)
         {
            this.m_timeLeftTooltip.setText(FarmGameUtil.toFriendlyTime(FarmClubUtility.getTimeTillDeadDay() / FarmGameUtil.NUM_MSECS_IN_SECOND));
         }
         else
         {
            this.m_timeLeftTooltip.setText(FarmGameUtil.toFriendlyTime(FarmClubUtility.getTimeTillCompetition() / FarmGameUtil.NUM_MSECS_IN_SECOND));
         }
      }
      
      public function populatePlantNow(crop:FarmItem) : void
      {
         if(!this.m_loaded)
         {
            this.m_currentTierCrop = crop;
            if(this.m_timerFrame != null)
            {
               this.m_plantNowButton = new FarmAnimatedTextButton(m_element.plant_bt,ZLocUtils.t("Dialogs","PlantNow"),this.onPlantNow);
               addWidget(this.m_plantNowButton);
               this.m_plantNowIconFrame = new ZwFrame(m_element.plantIcon_mc);
               this.m_plantNowIcon = new FarmIcon(this.m_plantNowIconFrame.element.cropIcon_mc,this.m_currentTierCrop.iconUrl);
               this.m_plantNowIcon.setIconSize(60,60);
               this.m_plantNowIconFrame.addWidget(this.m_plantNowIcon);
               addWidget(this.m_plantNowIconFrame);
            }
            else if(this.m_nextCropFrame != null)
            {
               this.m_plantNowIconFrame = new ZwFrame(this.m_nextCropFrame.element.plantIcon_mc);
               this.m_plantNowIcon = new FarmIcon(this.m_plantNowIconFrame.element.cropIcon_mc,this.m_currentTierCrop.iconUrl);
               this.m_plantNowIcon.setIconSize(60,60);
               this.m_plantNowIconFrame.addWidget(this.m_plantNowIcon);
               this.m_nextCropFrame.addWidget(this.m_plantNowIconFrame);
            }
            this.m_loaded = true;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_parentWindow = null;
         this.m_timerFrame = null;
         this.m_nextCropFrame = null;
         this.m_currentTierCrop = null;
         this.m_plantNowButton = null;
         this.m_plantNowIcon = null;
         this.m_plantNowIconFrame = null;
         this.m_timeLeftTooltip = null;
         if(this.m_timeLeftUpdateTimer)
         {
            this.m_timeLeftUpdateTimer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timeLeftUpdateTimer.stop();
         }
         this.m_timeLeftUpdateTimer = null;
      }
      
      private function onPlantNow(event:Event) : void
      {
         FarmStatsManager.count("club_buttons","plant","click");
         UI.displayMiniMarketDialog(new Array(this.m_currentTierCrop.name));
         this.m_parentWindow.close();
      }
   }
}

