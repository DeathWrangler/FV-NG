package Widgets.Windows.MOTD
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.LimitedQuantityBundleManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class LimitedQuantityBundleMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_countdown0_tf:ZwTextField;
      
      private var m_countdown1_tf:ZwTextField;
      
      private var m_counterMC:MovieClip;
      
      private var m_loadingAnim0:MovieClip;
      
      private var m_loadingAnim1:MovieClip;
      
      private var m_counterVisible:Boolean;
      
      private var m_items:Array;
      
      private var m_slotNum:int = -1;
      
      private const FEATURE_NAME:String = "limitedQuantityBundles_v2_6";
      
      private const SLOT0_MC:String = "slot0_mc";
      
      private const SLOT1_MC:String = "slot1_mc";
      
      private const SLOT0_Prefix:String = "slot0_";
      
      private const SLOT1_Prefix:String = "slot1_";
      
      private const ACCEPT0_BT:String = "accept0_bt";
      
      private const ACCEPT1_BT:String = "accept1_bt";
      
      private const TICK0_MC:String = "tick0_mc";
      
      private const TICK1_MC:String = "tick1_mc";
      
      private const TIME_LEFT_TF:String = "time_left_tf";
      
      private const TIME_UNIT_TF:String = "time_unit_tf";
      
      protected var m_Slot0Frame:ZwFrame = null;
      
      protected var m_Slot1Frame:ZwFrame = null;
      
      protected var m_accept0_bt:FarmAnimatedTextButton;
      
      protected var m_accept1_bt:FarmAnimatedTextButton;
      
      private var m_timer:Timer;
      
      private var m_buy0_bt:FarmAnimatedCashButton;
      
      private var m_buy1_bt:FarmAnimatedCashButton;
      
      public function LimitedQuantityBundleMOTD(displayParams:Object = null)
      {
         var count:int = 0;
         var i:int = 0;
         this.m_items = new Array();
         super(displayParams);
         if(displayParams.hasOwnProperty("itemList"))
         {
            count = int(displayParams["itemList"].item.length);
            for(i = 0; i < count; i++)
            {
               this.m_items.push(displayParams["itemList"]["item"][i]);
            }
         }
         else
         {
            this.m_items.push(displayParams["item"]);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         m_window.visible = true;
         m_window.mainWindow.visible = true;
         if(Boolean(m_window.mainWindow.hasOwnProperty(this.SLOT0_MC)) && Boolean(m_window.mainWindow.hasOwnProperty(this.SLOT1_MC)))
         {
            addWidget(this.m_Slot0Frame = new ZwFrame(m_window.mainWindow[this.SLOT0_MC]));
            if(m_window.mainWindow.hasOwnProperty(this.ACCEPT0_BT))
            {
               this.m_accept0_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow[this.ACCEPT0_BT],ZLocUtils.t_pk(m_currentMOTD["buttonText"]),null)) as FarmAnimatedTextButton;
               this.m_accept0_bt.visible = false;
               this.m_accept0_bt.enabled = false;
            }
            if(m_window.mainWindow.hasOwnProperty("buy0_bt"))
            {
               this.m_buy0_bt = addWidget(new FarmAnimatedCashButton(m_window.mainWindow["buy0_bt"],"Buy","299",this.onBuyBundle)) as FarmAnimatedCashButton;
               this.m_buy0_bt.visible = true;
            }
            if(m_window.mainWindow.slot0_mc.hasOwnProperty("slot0_1_mc"))
            {
               m_window.mainWindow.slot0_mc.slot0_0_mc.visible = true;
               m_window.mainWindow.slot0_mc.slot0_1_mc.visible = true;
               m_window.mainWindow.slot0_mc.slot0_2_mc.visible = true;
               m_window.mainWindow.slot0_mc.slot0_3_mc.visible = true;
            }
            if(m_window.mainWindow.hasOwnProperty(this.TICK0_MC))
            {
               m_window.mainWindow[this.TICK0_MC].visible = false;
            }
            addWidget(this.m_Slot1Frame = new ZwFrame(m_window.mainWindow[this.SLOT1_MC]));
            if(m_window.mainWindow.hasOwnProperty(this.ACCEPT1_BT))
            {
               this.m_accept1_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow[this.ACCEPT1_BT],ZLocUtils.t_pk(m_currentMOTD["buttonText"]),null)) as FarmAnimatedTextButton;
               this.m_accept1_bt.visible = false;
               this.m_accept1_bt.enabled = false;
            }
            if(m_window.mainWindow.hasOwnProperty("buy1_bt"))
            {
               this.m_buy1_bt = addWidget(new FarmAnimatedCashButton(m_window.mainWindow["buy1_bt"],"Buy","299",this.onBuyBundle)) as FarmAnimatedCashButton;
               this.m_buy1_bt.visible = true;
            }
            if(m_window.mainWindow.slot1_mc.hasOwnProperty("slot1_1_mc"))
            {
               m_window.mainWindow.slot1_mc.slot1_0_mc.visible = true;
               m_window.mainWindow.slot1_mc.slot1_1_mc.visible = true;
               m_window.mainWindow.slot1_mc.slot1_2_mc.visible = true;
               m_window.mainWindow.slot1_mc.slot1_3_mc.visible = true;
            }
            if(m_window.mainWindow.hasOwnProperty(this.TICK1_MC))
            {
               m_window.mainWindow[this.TICK1_MC].visible = false;
            }
            if(m_window.mainWindow.hasOwnProperty(this.TIME_LEFT_TF))
            {
               addWidget(new FarmTextField(m_window.mainWindow[this.TIME_LEFT_TF],"LOADING"));
            }
            if(m_window.mainWindow.hasOwnProperty(this.TIME_UNIT_TF))
            {
               addWidget(new FarmTextField(m_window.mainWindow[this.TIME_UNIT_TF],""));
            }
            this.setTimerVisibility();
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(this.m_counterMC == null)
         {
            this.m_counterMC = m_window.mainWindow;
            if(Boolean(this.m_Slot0Frame) && Boolean(this.m_Slot1Frame))
            {
               if(ObjectUtil.pathExists(this.m_counterMC,["timer0_mc","counter0_mc","digit0_txt"]))
               {
                  this.m_countdown0_tf = new ZwTextField(this.m_counterMC.timer0_mc.counter0_mc.digit0_txt,"750");
                  addWidget(this.m_countdown0_tf,false);
               }
               if(ObjectUtil.pathExists(this.m_counterMC,["timer0_mc","counter0_mc","digiAni0"]))
               {
                  this.m_loadingAnim0 = this.m_counterMC.timer0_mc.counter0_mc.digiAni0;
               }
               if(ObjectUtil.pathExists(this.m_counterMC,["timer1_mc","counter1_mc","digit1_txt"]))
               {
                  this.m_countdown1_tf = new ZwTextField(this.m_counterMC.timer1_mc.counter1_mc.digit1_txt,"750");
                  addWidget(this.m_countdown1_tf,false);
               }
               if(ObjectUtil.pathExists(this.m_counterMC,["timer1_mc","counter1_mc","digiAni1"]))
               {
                  this.m_loadingAnim1 = this.m_counterMC.timer1_mc.counter1_mc.digiAni1;
               }
            }
            else
            {
               if(ObjectUtil.pathExists(this.m_counterMC,["timer_mc","counter_mc","digit_txt"]))
               {
                  this.m_countdown0_tf = new ZwTextField(this.m_counterMC.timer_mc.counter_mc.digit_txt,"750");
                  addWidget(this.m_countdown0_tf);
               }
               if(ObjectUtil.pathExists(this.m_counterMC,["timer_mc","counter_mc","digiAni"]))
               {
                  this.m_loadingAnim0 = this.m_counterMC.timer_mc.counter_mc.digiAni;
               }
            }
         }
         if(m_accept_bt)
         {
            m_accept_bt.enabled = false;
            m_accept_bt.toggleClickableButton(false);
         }
         if(this.m_buy0_bt)
         {
            this.m_buy0_bt.enabled = false;
         }
         if(this.m_buy1_bt)
         {
            this.m_buy1_bt.enabled = false;
         }
         this.setBundleVisibility();
         this.setCounterVisibility();
      }
      
      private function onBuyBundle(e:Event) : void
      {
         var bundleCounter:String = "";
         if(e.target.name == "buy0_bt")
         {
            bundleCounter = this.m_accept0_bt.text;
            this.m_accept0_bt.enabled = false;
            this.m_buy0_bt.enabled = false;
            this.m_slotNum = 0;
         }
         else if(e.target.name == "buy1_bt")
         {
            bundleCounter = this.m_accept1_bt.text;
            this.m_buy1_bt.enabled = false;
            this.m_accept1_bt.enabled = false;
            this.m_slotNum = 1;
         }
         var tmpPopup:GenericPopup = new GenericPopup("Are you sure you want to spend 299 FC on this limited quantity bundle?\n",GenericPopup.TYPE_ACCEPTCANCEL,this.buyConfirmationHandler,GenericPopup.GENERIC_ASSET_MED);
         UI.displayPopup(tmpPopup,false,"DairyFarm_Tradein",true);
      }
      
      private function buyConfirmationHandler(event:GenericPopupEvent = null) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.manager.setBundleToBuy(this.m_items[this.m_slotNum],this.FEATURE_NAME,onAccept);
            FarmStatsManager.count("limited_qty_bundle","ClickBuy_accept",this.m_items[this.m_slotNum],"accept");
         }
         else
         {
            this.m_slotNum = -1;
            this.m_buy0_bt.enabled = true;
            this.m_buy1_bt.enabled = true;
            FarmStatsManager.count("limited_qty_bundle","ClickBuy_cancel",this.m_items[this.m_slotNum],"cancel");
         }
      }
      
      private function logStatsImpression(counter_value:Number, bundleName:String) : void
      {
         FarmStatsManager.count("limited_qty_bundle","Impression",bundleName,"","","",counter_value);
      }
      
      private function setCounterVisibility() : void
      {
         var LQManager:LimitedQuantityBundleManager = LimitedQuantityBundleManager.getInstance();
         this.m_counterVisible = LQManager.isCounterVisible();
         if(this.m_counterVisible)
         {
            this.m_counterMC.visible = true;
            if(this.m_loadingAnim0)
            {
               this.m_loadingAnim0.visible = true;
               this.m_loadingAnim0.gotoAndPlay(1);
            }
            if(this.m_loadingAnim1)
            {
               this.m_loadingAnim1.visible = true;
               this.m_loadingAnim1.gotoAndPlay(1);
            }
            this.m_countdown0_tf.visible = false;
         }
         else
         {
            this.m_counterMC.visible = false;
         }
         if(!LQManager.getBundlePurchaseStatus(this.FEATURE_NAME,this.m_items[0]))
         {
            LQManager.updateUIWithItemsRemaining(this.m_items[0],this.refreshCountDownTF);
         }
         if(!LQManager.getBundlePurchaseStatus(this.FEATURE_NAME,this.m_items[1]))
         {
            LQManager.updateUIWithItemsRemaining(this.m_items[1],this.refreshCountDownTF,true);
         }
      }
      
      private function setBundleVisibility() : void
      {
         var LQManager:LimitedQuantityBundleManager = LimitedQuantityBundleManager.getInstance();
         if(LQManager.getBundlePurchaseStatus(this.FEATURE_NAME,this.m_items[0]) == true)
         {
            if(m_window.mainWindow.hasOwnProperty(this.TICK0_MC))
            {
               m_window.mainWindow[this.TICK0_MC].visible = true;
            }
            this.m_accept0_bt.visible = true;
            this.m_accept0_bt.text = "Bought!";
            this.m_accept0_bt.applyGrayOut = true;
            this.m_accept0_bt.enabled = false;
            this.m_buy0_bt.enabled = false;
            this.m_buy0_bt.visible = false;
         }
         if(LQManager.getBundlePurchaseStatus(this.FEATURE_NAME,this.m_items[1]) == true)
         {
            if(m_window.mainWindow.hasOwnProperty(this.TICK1_MC))
            {
               m_window.mainWindow[this.TICK1_MC].visible = true;
            }
            this.m_accept1_bt.visible = true;
            this.m_accept1_bt.text = "Bought!";
            this.m_accept1_bt.applyGrayOut = true;
            this.m_accept1_bt.enabled = false;
            this.m_buy1_bt.enabled = false;
            this.m_buy1_bt.visible = false;
         }
      }
      
      private function setTimerVisibility() : void
      {
         var hours:int = this.manager.getTimeRemaining(this.FEATURE_NAME) / FarmGameUtil.NUM_SECS_IN_HOUR;
         if(m_window.mainWindow.hasOwnProperty(this.TIME_LEFT_TF))
         {
            if(hours > 1)
            {
               m_window.mainWindow[this.TIME_LEFT_TF].text = hours;
               m_window.mainWindow[this.TIME_UNIT_TF].text = "hours";
            }
            else
            {
               this.startTimer();
            }
         }
      }
      
      private function get manager() : LimitedQuantityBundleManager
      {
         return LimitedQuantityBundleManager.getInstance();
      }
      
      private function refreshCountDownTF(numberOfItems:Number, itemName:String = null) : void
      {
         var numItems:int = numberOfItems <= 0 ? 0 : int(Math.floor(numberOfItems));
         var slotNum:int = -1;
         if(Boolean(itemName) && this.m_items.length >= 2)
         {
            slotNum = this.m_items.indexOf(itemName);
         }
         if(this == UI.getCurrentPopup())
         {
            if(this.m_counterVisible)
            {
               switch(slotNum)
               {
                  case 1:
                     if(this.m_countdown1_tf)
                     {
                        this.m_countdown1_tf.text = numItems.toString();
                        this.m_countdown1_tf.visible = true;
                        if(this.m_loadingAnim1)
                        {
                           this.m_loadingAnim1.stop();
                           this.m_loadingAnim1.visible = false;
                           this.m_countdown1_tf.visible = true;
                        }
                     }
                     if(numItems <= 0)
                     {
                        this.m_accept1_bt.visible = true;
                        this.m_accept1_bt.text = "Out of Stock!";
                        this.m_buy1_bt.visible = false;
                     }
                     else
                     {
                        this.m_buy1_bt.enabled = true;
                     }
                     break;
                  default:
                     if(this.m_countdown0_tf)
                     {
                        this.m_countdown0_tf.text = Math.floor(numItems).toString();
                        this.m_countdown0_tf.visible = true;
                        if(this.m_loadingAnim0)
                        {
                           this.m_loadingAnim0.stop();
                           this.m_loadingAnim0.visible = false;
                           this.m_countdown0_tf.visible = true;
                        }
                     }
                     if(numItems <= 0)
                     {
                        this.m_accept0_bt.visible = true;
                        this.m_accept0_bt.text = "Out of Stock!";
                        this.m_buy0_bt.visible = false;
                     }
                     else
                     {
                        this.m_buy0_bt.enabled = true;
                     }
               }
            }
            this.logStatsImpression(numItems,itemName);
         }
      }
      
      private function startTimer() : void
      {
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
      }
      
      override public function close() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         super.close();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         var unit:String = null;
         var time:Number = this.manager.getTimeRemaining(this.FEATURE_NAME);
         var timeLeft:Array = FarmGameUtil.parseTimeLeft(time);
         if(m_window.mainWindow.hasOwnProperty(this.TIME_LEFT_TF))
         {
            if(timeLeft[1] >= 1)
            {
               unit = timeLeft[1] == 1 ? "hour" : "hours";
               m_window.mainWindow[this.TIME_LEFT_TF].text = int(timeLeft[1]);
            }
            else if(timeLeft[2] >= 1)
            {
               this.startTimer();
               unit = timeLeft[2] == 1 ? "min" : "mins";
               m_window.mainWindow[this.TIME_LEFT_TF].text = int(timeLeft[2]);
            }
            else
            {
               this.startTimer();
               unit = timeLeft[3] == 1 ? "sec" : "secs";
               m_window.mainWindow[this.TIME_LEFT_TF].text = int(timeLeft[3]);
            }
            m_window.mainWindow[this.TIME_UNIT_TF].text = unit;
         }
      }
   }
}

