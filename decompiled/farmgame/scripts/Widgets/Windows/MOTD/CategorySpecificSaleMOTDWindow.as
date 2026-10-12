package Widgets.Windows.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class CategorySpecificSaleMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      protected static const MENU_PREFIX:String = "menu_";
      
      private var m_timer:Timer;
      
      private var timerMC:MovieClip;
      
      public function CategorySpecificSaleMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var titleText:String = null;
         var bodyText:String = null;
         var shouldShowCloseButton:Boolean = false;
         var discount:String = null;
         addWidget(new ZwBaseWidget(m_window.mainWindow));
         addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t_pk(m_currentMOTD["buttonText"]),onAccept));
         if(m_window.mainWindow.title_tf)
         {
            titleText = Global.categorySpecificSalesManager.motdTitle;
            if(titleText != "")
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,titleText));
            }
         }
         if(m_window.mainWindow.body_tf)
         {
            bodyText = Global.categorySpecificSalesManager.motdBody;
            if(bodyText != "")
            {
               addWidget(new FarmTextField(m_window.mainWindow.body_tf,bodyText));
            }
         }
         if(m_window.mainWindow.hasOwnProperty("back_mc"))
         {
            m_window.mainWindow.back_mc.visible = true;
            m_window.mainWindow.back_mc.gotoAndPlay(2);
         }
         if(m_window.mainWindow.hasOwnProperty("close_bt"))
         {
            shouldShowCloseButton = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CATEGORY_SPECIFIC_SALE_CLOSE) == Experiments.VARIANT_CATEGORY_SPECIFIC_SALE_CLOSE;
            if(shouldShowCloseButton)
            {
               m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClose)) as FarmButton;
            }
            else
            {
               m_window.mainWindow.close_bt.visible = false;
            }
         }
         if(m_window.mainWindow["DiscountContainer_mc"])
         {
            discount = ZLocUtils.t("Dialogs","Instagrow_DialogPercentSign",{"quantity":Global.categorySpecificSalesManager.discount});
            addWidget(new FarmTextField(m_window.mainWindow.DiscountContainer_mc.offerPer_txt,discount));
         }
         var items:Array = Global.categorySpecificSalesManager.getItemsInSale();
         var item:FarmItem = items[0];
         if(item)
         {
            addWidget(new ObjectPreviewFrame(m_window.mainWindow.slot_1_mc,item,null,[2.5]));
         }
         item = items[1];
         if(item)
         {
            addWidget(new ObjectPreviewFrame(m_window.mainWindow.slot_0_mc,item,null,[2]));
         }
         item = items[2];
         if(item)
         {
            addWidget(new ObjectPreviewFrame(m_window.mainWindow.slot_2_mc,item,null,[2]));
         }
         if(m_window.mainWindow["timer_mc"])
         {
            this.startTimer();
         }
      }
      
      private function startTimer() : void
      {
         if(m_window.mainWindow["timer_mc"])
         {
            this.timerMC = m_window.mainWindow["timer_mc"];
            addWidget(new ZwWidget(this.timerMC));
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.updateTimer);
            this.m_timer.start();
            this.updateTimer();
         }
      }
      
      private function updateTimer(event:Event = null) : void
      {
         var time:Array = FarmGameUtil.parseTimeLeftZLoc(Global.categorySpecificSalesManager.timeLeft);
         if(time["Days"] < 10)
         {
            this.setDigit(this.timerMC["hh_1_mc"],0);
            this.setDigit(this.timerMC["hh_0_mc"],time["Days"]);
         }
         else
         {
            this.setDigit(this.timerMC["hh_1_mc"],time["Days"] / 10);
            this.setDigit(this.timerMC["hh_0_mc"],time["Days"] % 10);
         }
         if(time["Hours"] < 10)
         {
            this.setDigit(this.timerMC["mm_1_mc"],0);
            this.setDigit(this.timerMC["mm_0_mc"],time["Hours"]);
         }
         else
         {
            this.setDigit(this.timerMC["mm_1_mc"],time["Hours"] / 10);
            this.setDigit(this.timerMC["mm_0_mc"],time["Hours"] % 10);
         }
         if(time["Minutes"] < 10)
         {
            this.setDigit(this.timerMC["ss_1_mc"],0);
            this.setDigit(this.timerMC["ss_0_mc"],time["Minutes"]);
         }
         else
         {
            this.setDigit(this.timerMC["ss_1_mc"],time["Minutes"] / 10);
            this.setDigit(this.timerMC["ss_0_mc"],time["Minutes"] % 10);
         }
      }
      
      private function setDigit(containerMC:MovieClip, val:int) : void
      {
         if(Boolean(containerMC) && Boolean(containerMC["digit_txt"]))
         {
            TextField(containerMC["digit_txt"]).text = val.toString();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.updateTimer);
            this.m_timer = null;
         }
         super.onClose(event);
      }
   }
}

