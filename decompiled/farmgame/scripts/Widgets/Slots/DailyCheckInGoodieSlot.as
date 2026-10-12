package Widgets.Slots
{
   import Classes.util.DisplayObjectUtils;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Managers.DailyCheckInManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.DailyCheckInWindow;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class DailyCheckInGoodieSlot extends ZwSlotFrame
   {
      
      private var m_goodieMc:MovieClip;
      
      private var m_candyRedeemMc:ZwWidget;
      
      private var m_checkMarkMc:ZwWidget;
      
      private var m_redeemBt:FarmAnimatedTextButton;
      
      private var m_timerTf:FarmTextField;
      
      private var m_timerDesc:FarmTextField;
      
      private var m_selectCandyBg:ZwWidget;
      
      private var m_rayMc:ZwWidget;
      
      private var m_dayNo:int;
      
      private var m_window:DailyCheckInWindow;
      
      public function DailyCheckInGoodieSlot(element:DisplayObject, goodieUrl:String, window:DailyCheckInWindow)
      {
         super(element);
         this.m_window = window;
         if(m_element)
         {
            m_element.visible = true;
         }
         if(m_element.hasOwnProperty("candy_redeem_mc"))
         {
            this.m_candyRedeemMc = addWidget(new ZwWidget(m_element["candy_redeem_mc"]),true) as ZwWidget;
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkMarkMc = addWidget(new ZwWidget(m_element["checkmark_mc"]),false) as ZwWidget;
         }
         if(m_element.hasOwnProperty("redeem_bt"))
         {
            this.m_redeemBt = addWidget(new FarmAnimatedTextButton(m_element["redeem_bt"],ZLocUtils.t("Dialogs","DailyCheckIn_CollectBtn"),this.onCollectClick),false) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("timer_tf"))
         {
            this.m_timerTf = addWidget(new FarmTextField(m_element["timer_tf"],"db1"),false) as FarmTextField;
         }
         if(m_element.hasOwnProperty("timer_tf_1"))
         {
            this.m_timerDesc = addWidget(new FarmTextField(m_element["timer_tf_1"],ZLocUtils.t("Dialogs","DailyCheckIn_TimeNextCollect")),false) as FarmTextField;
         }
         if(m_element.hasOwnProperty("selectcandy_mc"))
         {
            this.m_selectCandyBg = addWidget(new ZwWidget(m_element["selectcandy_mc"]),false) as ZwWidget;
         }
         if(m_element.hasOwnProperty("ray_mc"))
         {
            this.m_rayMc = addWidget(new ZwWidget(m_element["ray_mc"]),false) as ZwWidget;
         }
         LoadingManager.load(Global.getAssetURL(goodieUrl),this.onGoodieImgLoaded);
      }
      
      override public function populate(data:Object) : void
      {
         this.m_dayNo = data.dayNo;
         this.update();
      }
      
      private function update() : void
      {
         var timeElapsed:int = DailyCheckInManager.getInstance().getTimeElapsedSinceThisWeek();
         var timeRemaining:int = DailyCheckInManager.getInstance().getCurrentDayNumber() * DailyCheckInManager.SECS_PER_DAY - timeElapsed;
         var parsedTimeArr:Array = FarmGameUtil.parseTimeLeft(timeRemaining);
         this.m_timerTf.text = FarmGameUtil.zeroPad(parsedTimeArr[1],2) + ":" + FarmGameUtil.zeroPad(parsedTimeArr[2],2) + ":" + FarmGameUtil.zeroPad(parsedTimeArr[3],2);
         this.m_redeemBt.visible = false;
         this.m_timerDesc.visible = false;
         this.m_timerTf.visible = false;
         this.m_checkMarkMc.visible = false;
         this.m_candyRedeemMc.visible = true;
         this.m_selectCandyBg.visible = false;
         this.m_rayMc.visible = false;
         if(this.m_goodieMc)
         {
            this.m_goodieMc[DailyCheckInWindow.GOODIE_SMALL].visible = false;
            this.m_goodieMc[DailyCheckInWindow.GOODIE_MEDIUM].visible = false;
            this.m_goodieMc[DailyCheckInWindow.GOODIE_LARGE].visible = false;
         }
         DisplayObjectUtils.grayOut(this.m_candyRedeemMc.element as DisplayObject,false);
         var currentDay:int = DailyCheckInManager.getInstance().getCurrentDayNumber();
         if(this.m_dayNo < currentDay)
         {
            if(this.m_goodieMc)
            {
               this.m_goodieMc[DailyCheckInWindow.GOODIE_MEDIUM].visible = true;
            }
            if(DailyCheckInManager.getInstance().isGoodieCollectedOn(this.m_dayNo))
            {
               this.m_checkMarkMc.visible = true;
            }
            else
            {
               DisplayObjectUtils.grayOut(this.m_candyRedeemMc.element as DisplayObject,true);
            }
         }
         else if(this.m_dayNo == currentDay)
         {
            if(DailyCheckInManager.getInstance().isGoodieCollectedOn(this.m_dayNo))
            {
               this.m_checkMarkMc.visible = true;
               if(this.m_goodieMc)
               {
                  this.m_goodieMc[DailyCheckInWindow.GOODIE_MEDIUM].visible = true;
               }
            }
            else
            {
               this.m_redeemBt.visible = true;
               this.m_rayMc.visible = true;
               this.m_selectCandyBg.visible = true;
               if(this.m_goodieMc)
               {
                  this.m_goodieMc[DailyCheckInWindow.GOODIE_LARGE].visible = true;
               }
            }
         }
         else if(this.m_dayNo == currentDay + 1 && DailyCheckInManager.getInstance().isGoodieCollectedOn(currentDay))
         {
            this.m_timerTf.visible = true;
            this.m_timerDesc.visible = true;
            this.m_selectCandyBg.visible = true;
            if(this.m_goodieMc)
            {
               this.m_goodieMc[DailyCheckInWindow.GOODIE_LARGE].visible = true;
            }
         }
         else if(this.m_goodieMc)
         {
            this.m_goodieMc[DailyCheckInWindow.GOODIE_MEDIUM].visible = true;
         }
      }
      
      private function onCollectClick(e:Event) : void
      {
         this.m_redeemBt.enabled = false;
         this.m_redeemBt.text = ZLocUtils.t("Dialogs","dailycheckin_collecting");
         if(DailyCheckInManager.getInstance().hasWeekChanged())
         {
            this.m_window.close();
            DailyCheckInManager.getInstance().reinitialize();
         }
         else
         {
            DailyCheckInManager.getInstance().collectGoodie(this.onGoodieCollected);
         }
      }
      
      private function onGoodieCollected(result:Object = null) : void
      {
         if(this.m_window)
         {
            if(DailyCheckInManager.getInstance().areAllGoodiesCollected())
            {
               this.m_window.close();
            }
            else
            {
               this.m_window.refreshUi();
            }
         }
      }
      
      private function onGoodieImgLoaded(e:Event) : void
      {
         var loader:LoaderInfo = null;
         if(Boolean(e) && e.currentTarget is LoaderInfo)
         {
            loader = e.currentTarget as LoaderInfo;
            if(Boolean(loader) && loader.content is MovieClip)
            {
               this.m_goodieMc = loader.content as MovieClip;
               if(Boolean(this.m_goodieMc) && Boolean(this.m_candyRedeemMc) && Boolean(this.m_candyRedeemMc.element))
               {
                  (this.m_candyRedeemMc.element as DisplayObjectContainer).addChild(this.m_goodieMc);
                  this.update();
               }
            }
         }
      }
      
      override public function release() : void
      {
         this.m_window = null;
         super.release();
      }
   }
}

