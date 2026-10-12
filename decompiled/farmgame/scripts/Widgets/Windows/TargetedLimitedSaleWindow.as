package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LimitedSaleUtility;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Sales.TargetedLimitedSaleSlotFrame;
   import Widgets.Slots.Sales.TargetedLimitedSaleSlot;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class TargetedLimitedSaleWindow extends FarmWindow
   {
      
      public static const DIALOG_STATS_WINDOW:String = "limited_sales";
      
      public static const SALE_ACTIVITY_COUNTER:String = "limitedsales_activity";
      
      protected var m_localizationKey:String;
      
      protected var m_timer:Timer;
      
      protected var m_timeRemaining:int;
      
      protected var m_timerWidgets:Object;
      
      protected var m_saleSlotFrame:TargetedLimitedSaleSlotFrame;
      
      protected var m_toasterFrame:ZwFrame;
      
      protected var m_toasterTextField:ZwTextField;
      
      protected var m_dialogAsset:String = "assets/dialogs/FV_LimitedSale.swf";
      
      public function TargetedLimitedSaleWindow(dialogPath:String = null)
      {
         if(!dialogPath)
         {
            dialogPath = this.m_dialogAsset;
         }
         super(dialogPath);
         this.m_localizationKey = LimitedSaleUtility.instance().getLocalizationKey();
         this.m_timerWidgets = new Object();
         this.m_timerWidgets.seconds = new Array();
         this.m_timerWidgets.minutes = new Array();
         this.m_timerWidgets.hours = new Array();
      }
      
      override protected function postLoadComplete() : void
      {
         var subtitleKey:String = null;
         var subtitleText:String = null;
         var saleItemList:Object = null;
         var thankyouMc:ZwFrame = null;
         super.postLoadComplete();
         if(m_window)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","Congrats")));
            subtitleKey = LimitedSaleUtility.instance().getLocalizationKey() + "_subtitle";
            subtitleText = "";
            if(ZLocUtils.hasString("Dialogs",subtitleKey))
            {
               subtitleText = ZLocUtils.t("Dialogs",subtitleKey);
            }
            else
            {
               subtitleText = ZLocUtils.t("Dialogs","targetedSale1_subtitle");
            }
            addWidget(new ZwTextField(m_window.body_tf,subtitleText));
            addWidget(new ZwTextField(m_window.timer_tf,ZLocUtils.t("Dialogs","limitedSaleExpire")));
            saleItemList = LimitedSaleUtility.instance().getSaleItems();
            this.m_saleSlotFrame = addWidget(new TargetedLimitedSaleSlotFrame(m_window.slotFrame_mc,saleItemList)) as TargetedLimitedSaleSlotFrame;
            this.m_saleSlotFrame.addEventListener(TargetedLimitedSaleSlot.BUY_CLICKED_EVENT,this.onBuyItemClick);
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,DIALOG_STATS_WINDOW,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
            FarmStatsManager.count(SALE_ACTIVITY_COUNTER,StatsTrackingConstants.DIALOG_STATS_COUNTER,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
            this.m_timerWidgets.seconds.push(addWidget(new ZwTextField(m_window.value_5_tf,"0")) as ZwTextField);
            this.m_timerWidgets.seconds.push(addWidget(new ZwTextField(m_window.value_4_tf,"0")) as ZwTextField);
            this.m_timerWidgets.minutes.push(addWidget(new ZwTextField(m_window.value_3_tf,"0")) as ZwTextField);
            this.m_timerWidgets.minutes.push(addWidget(new ZwTextField(m_window.value_2_tf,"0")) as ZwTextField);
            this.m_timerWidgets.hours.push(addWidget(new ZwTextField(m_window.value_1_tf,"0")) as ZwTextField);
            this.m_timerWidgets.hours.push(addWidget(new ZwTextField(m_window.value_0_tf,"0")) as ZwTextField);
            this.m_timer = new Timer(1000,0);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.refreshTimer);
            this.m_timer.start();
            this.m_toasterFrame = new ZwFrame(m_window.popup_mc);
            thankyouMc = new ZwFrame(this.m_toasterFrame.element.thankyou_mc);
            this.m_toasterTextField = new ZwTextField(thankyouMc.element.thankyou_tf,ZLocUtils.t("Dialogs","LimitedSalePurchaseSuccess"));
            thankyouMc.addWidget(this.m_toasterTextField);
            this.m_toasterFrame.addWidget(thankyouMc);
            this.refreshTimer(null);
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,DIALOG_STATS_WINDOW,"button_cancel");
         FarmStatsManager.count(SALE_ACTIVITY_COUNTER,StatsTrackingConstants.DIALOG_STATS_COUNTER,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         var property:String = null;
         var widget:ZwTextField = null;
         super.release();
         if(this.m_timer != null)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.refreshTimer);
            this.m_timer = null;
         }
         for(property in this.m_timerWidgets)
         {
            for each(widget in this.m_timerWidgets[property])
            {
               widget = null;
            }
            delete this.m_timerWidgets[property];
         }
         this.m_timerWidgets = null;
         this.m_saleSlotFrame.removeEventListener(TargetedLimitedSaleSlot.BUY_CLICKED_EVENT,this.onBuyItemClick);
         this.m_saleSlotFrame = null;
         this.m_toasterFrame = null;
         this.m_toasterTextField = null;
      }
      
      private function refreshTimer(event:TimerEvent) : void
      {
         var timeRemainingCopy:int = 0;
         var hoursRemaining:int = 0;
         var minutesRemaining:int = 0;
         this.m_timeRemaining = LimitedSaleUtility.instance().getTimeRemainingOnCurrentSale();
         if(this.m_timeRemaining < 0)
         {
            LimitedSaleUtility.instance().showSaleOverMessage();
            this.close();
         }
         else
         {
            timeRemainingCopy = this.m_timeRemaining;
            hoursRemaining = Math.floor(timeRemainingCopy / FarmGameUtil.NUM_SECS_IN_HOUR);
            timeRemainingCopy -= hoursRemaining * FarmGameUtil.NUM_SECS_IN_HOUR;
            minutesRemaining = Math.floor(timeRemainingCopy / FarmGameUtil.NUM_SECS_IN_MINUTE);
            timeRemainingCopy -= minutesRemaining * FarmGameUtil.NUM_SECS_IN_MINUTE;
            this.setUpTimerTextForPlace(this.m_timerWidgets.hours,hoursRemaining);
            this.setUpTimerTextForPlace(this.m_timerWidgets.minutes,minutesRemaining);
            this.setUpTimerTextForPlace(this.m_timerWidgets.seconds,timeRemainingCopy);
         }
      }
      
      private function setUpTimerTextForPlace(place:Array, placeTimeRemaining:int) : void
      {
         place[0].text = placeTimeRemaining % 10;
         place[1].text = Math.floor(placeTimeRemaining / 10);
      }
      
      private function onBuyItemClick(event:Event) : void
      {
         var currentToasterFrame:int = (this.m_toasterFrame.element as MovieClip).currentFrame;
         if(currentToasterFrame == 1 || currentToasterFrame == (this.m_toasterFrame.element as MovieClip).totalFrames)
         {
            (this.m_toasterFrame.element as MovieClip).visible = true;
            (this.m_toasterFrame.element as MovieClip).gotoAndPlay(2);
         }
      }
   }
}

