package Managers
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Widgets.Windows.MarketFlashSaleWindow;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MarketFlashSaleManager
   {
      
      private static var s_instance:MarketFlashSaleManager;
      
      public static const MARKET_FLASH_SALE_SEEN_FLAG:String = "seen_market_sale_motd";
      
      private static const SALE_OFF_RUNTIME_NAME:String = "MARKETPLACE_SALE_PERCENTAGE_OFF";
      
      private static const TIMER_PULSE_TIME:int = 1000;
      
      protected var m_timer:Timer;
      
      protected var m_lastSaleActive:Boolean = false;
      
      private var m_cachedSaleStart:Number = NaN;
      
      private var m_cachedSaleDuration:Number = NaN;
      
      public function MarketFlashSaleManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[MarketFlashSaleManager] :: Use instance()");
      }
      
      public static function get instance() : MarketFlashSaleManager
      {
         if(!s_instance)
         {
            s_instance = new MarketFlashSaleManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public function init() : void
      {
         if(this.canSaleActivateOnSession())
         {
            this.m_lastSaleActive = this.isSaleActive();
            if(this.m_lastSaleActive)
            {
               this.enableSaleUI();
            }
            else
            {
               this.disableSaleUI();
            }
            this.m_timer = new Timer(TIMER_PULSE_TIME,0);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.refreshTimer);
            this.m_timer.start();
         }
      }
      
      private function refreshTimer(event:TimerEvent) : void
      {
         var nowActive:Boolean = this.isSaleActive();
         if(nowActive && !this.m_lastSaleActive)
         {
            this.popupSaleMOTD();
            this.enableSaleUI();
         }
         else if(!nowActive && this.m_lastSaleActive)
         {
            this.disableSaleUI();
            this.terminateTimer();
         }
         this.m_lastSaleActive = nowActive;
      }
      
      private function terminateTimer() : void
      {
         if(this.m_timer != null)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.refreshTimer);
            this.m_timer = null;
         }
      }
      
      private function popupSaleMOTD() : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKETPLACE_SALE_AUTO_POPUP) > 0)
         {
            FarmStatsManager.count("market_sale",Experiments.EXPERIMENT_FLASH_MARKETPLACE_SALE_AUTO_POPUP,"impression");
            if(!Global.player.getSeenSessionFlag(MarketFlashSaleManager.MARKET_FLASH_SALE_SEEN_FLAG))
            {
               Global.player.setSeenSessionFlag(MarketFlashSaleManager.MARKET_FLASH_SALE_SEEN_FLAG,true);
               if(!UI.isMarketWindowOpen())
               {
                  UI.displayPopup(new MarketFlashSaleWindow());
               }
            }
         }
      }
      
      private function disableSaleUI() : void
      {
         Global.ui.getActionMenu().setMarketIconNormalVersion();
         UI.enableMarketFlashSaleUI(false);
      }
      
      public function conditionallyDisableSaleUI() : void
      {
         if(!this.isSaleActive())
         {
            this.disableSaleUI();
         }
      }
      
      private function enableSaleUI() : void
      {
         Global.ui.getActionMenu().setMarketIconSaleVersion();
         UI.enableMarketFlashSaleUI(true);
      }
      
      public function isSaleActive() : Boolean
      {
         return this.getTimeLeft() > 0;
      }
      
      public function getItemSaleCashCost(item:FarmItem) : int
      {
         var result:Number = item.cash;
         if(this.isItemAffected(item) && this.isSaleActive())
         {
            result *= this.getSaleOffMultiplyValue();
         }
         return Math.round(Math.max(result,1));
      }
      
      public function getSaleOffPercentage() : int
      {
         return Global.flashHotParams[SALE_OFF_RUNTIME_NAME];
      }
      
      protected function getSaleOffMultiplyValue() : Number
      {
         var percentageOff:int = int(Global.flashHotParams[SALE_OFF_RUNTIME_NAME]);
         return (100 - percentageOff) / 100;
      }
      
      public function getSaleMinAffectedItemCost() : int
      {
         return Global.flashHotParams["MARKETPLACE_SALE_MIN_VALUE_AFFECTED"];
      }
      
      protected function isItemAffected(item:FarmItem) : Boolean
      {
         var result:Boolean = false;
         var minAffectedValue:int = this.getSaleMinAffectedItemCost();
         if(item.cash >= minAffectedValue)
         {
            result = true;
         }
         return result;
      }
      
      public function isSaleActiveForItem(item:FarmItem) : Boolean
      {
         return this.isItemAffected(item) && this.isSaleActive();
      }
      
      private function canSaleActivateOnSession() : Boolean
      {
         var startSaleTimeNumber:Number = NaN;
         var startSaleTime:int = 0;
         var finishSaleTime:int = 0;
         var now:int = 0;
         var result:Boolean = false;
         var saleDuration:int = this.getSaleDuration();
         if(saleDuration > 0)
         {
            startSaleTimeNumber = this.getSaleStartTime();
            if(!isNaN(startSaleTimeNumber))
            {
               startSaleTime = startSaleTimeNumber;
               finishSaleTime = startSaleTime + saleDuration;
               now = GlobalEngine.serverTime;
               if(now < finishSaleTime)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      private function getSaleStartTime() : Number
      {
         var startSaleTimeString:String = null;
         if(isNaN(this.m_cachedSaleStart))
         {
            startSaleTimeString = Global.flashHotParams["MARKETPLACE_SALE_START_TIME"];
            if(startSaleTimeString != null && startSaleTimeString.length > 0)
            {
               this.m_cachedSaleStart = FarmGameUtil.synchronizedDateTimeToNumber(startSaleTimeString);
            }
         }
         return this.m_cachedSaleStart;
      }
      
      private function getSaleDuration() : int
      {
         var experimentValue:int = 0;
         if(isNaN(this.m_cachedSaleDuration))
         {
            this.m_cachedSaleDuration = -1;
            experimentValue = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKETPLACE_SALE);
            if(experimentValue >= Experiments.VARIANT_FLASH_MARKETPLACE_SALE_START)
            {
               this.m_cachedSaleDuration = Global.flashHotParams["MARKETPLACE_SALE_DURATION_" + experimentValue] * FarmGameUtil.NUM_MSECS_IN_SECOND;
            }
         }
         return this.m_cachedSaleDuration;
      }
      
      public function getTimeLeft() : int
      {
         var startSaleTimeNumber:Number = NaN;
         var startSaleTime:int = 0;
         var finishSaleTime:int = 0;
         var now:int = 0;
         var result:int = -1;
         var saleDuration:int = this.getSaleDuration();
         if(saleDuration > 0)
         {
            startSaleTimeNumber = this.getSaleStartTime();
            if(!isNaN(startSaleTimeNumber))
            {
               startSaleTime = startSaleTimeNumber;
               finishSaleTime = startSaleTime + saleDuration;
               now = GlobalEngine.serverTime;
               if(now > startSaleTime && now < finishSaleTime)
               {
                  result = (finishSaleTime - now) / FarmGameUtil.NUM_MSECS_IN_SECOND;
               }
            }
         }
         return result;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
