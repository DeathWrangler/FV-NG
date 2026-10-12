package Managers
{
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Widgets.Windows.DreamFishPremarketingWindow;
   import flash.events.Event;
   
   public class DreamFishPremarketingManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "DreamFishPremarketing";
      
      public static const FEED_NAME:String = "FeatureUI";
      
      public static const PRE_EA_INCOMPLETE:int = 1;
      
      public static const PRE_EA_COMPLETE:int = 2;
      
      public static const POST_EA_INCOMPLETE:int = 3;
      
      public static const POST_EA_COMPLETE:int = 4;
      
      public static const POST_EA_EXPANSION_COMPLETE_NOT_RAMPED:int = 5;
      
      public static const POST_EA_EXPANSION_INCOMPLETE_NOT_RAMPED:int = 6;
      
      public static const MAX_TICKET_COUNT:int = 30;
      
      public static const FEATURE_OPTIONS_KEY:String = "popup_Count";
      
      public var ASK_FEED_FREQUENCY_KEY:String;
      
      public const WORLD_TYPE:String = "dreamworld";
      
      private const ASSET_MAIN:String = "main";
      
      private var m_isActive:Boolean = false;
      
      private var m_window:DreamFishPremarketingWindow = null;
      
      private var m_currencyName:String = null;
      
      private var m_askFeedFrequency:int = 21600;
      
      private var m_endTimeString:String;
      
      private var m_ticketsCount:Number = NaN;
      
      private var m_state:int;
      
      public function DreamFishPremarketingManager(featureName:String)
      {
         super(featureName);
         if(!this.featureConfig)
         {
            return;
         }
         this.loadFeatureConfig(featureName);
         this.setState();
      }
      
      public static function instance(featureName:String = "DreamFishPremarketing") : DreamFishPremarketingManager
      {
         var instance:DreamFishPremarketingManager = BaseFeatureManager.getInstanceOfClass(featureName,DreamFishPremarketingManager) as DreamFishPremarketingManager;
         return instance.featureConfig == null ? null : instance;
      }
      
      private function loadFeatureConfig(featureName:String) : void
      {
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(featureName);
         if(featureXML == null)
         {
            return;
         }
         this.m_currencyName = featureXML.currencyItem[0].@name.toString();
         this.ASK_FEED_FREQUENCY_KEY = featureName + "AskCurrency";
         this.m_askFeedFrequency = featureXML.feed.@throttleTime.toString();
         this.m_endTimeString = featureXML.listEndDate;
         this.m_isActive = true;
      }
      
      private function setState() : void
      {
         if(this.isFeaturePlayable())
         {
            if(!this.isMaxTicketsCollected())
            {
               this.m_state = PRE_EA_INCOMPLETE;
            }
            else
            {
               this.m_state = PRE_EA_COMPLETE;
            }
         }
         else if(Global.experimentManager.getExperimentVariant("fv_xdw_master") >= 1)
         {
            if(!this.isMaxTicketsCollected())
            {
               this.m_state = POST_EA_INCOMPLETE;
            }
            else
            {
               this.m_state = POST_EA_COMPLETE;
            }
         }
         else if(!this.isMaxTicketsCollected())
         {
            this.m_state = POST_EA_EXPANSION_INCOMPLETE_NOT_RAMPED;
         }
         else
         {
            this.m_state = POST_EA_EXPANSION_COMPLETE_NOT_RAMPED;
         }
      }
      
      public function get state() : int
      {
         return this.m_state;
      }
      
      public function getDaysLeft() : int
      {
         var timeLeftArr:Array = null;
         var daysLeft:int = -1;
         var startTimeMS:Number = FarmGameUtil.synchronizedDateToNumber(this.m_endTimeString);
         var timeToUnlockMS:Number = (startTimeMS - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(timeToUnlockMS > 0)
         {
            timeLeftArr = FarmGameUtil.parseTimeLeft(timeToUnlockMS);
            daysLeft = int(timeLeftArr[0]);
         }
         return daysLeft + 1;
      }
      
      private function onaskForTickets(e:Object) : void
      {
         if(this.m_window)
         {
            this.m_window.refreshAskButton();
         }
      }
      
      public function askForTickets(event:Event = null) : void
      {
         getFeedData(FEED_NAME).postFeed(this.onaskForTickets);
      }
      
      public function get ItemName() : String
      {
         return this.m_currencyName;
      }
      
      public function isFeaturePlayable() : Boolean
      {
         return FarmGameUtil.isFeatureInActivePeriod(this.m_endTimeString,0);
      }
      
      public function showMainUI() : void
      {
         UI.displayPopup(this.m_window = new DreamFishPremarketingWindow(m_featureName,getAssetURL(this.ASSET_MAIN)));
      }
      
      public function get playerTicketCount() : int
      {
         if(isNaN(this.m_ticketsCount) || this.m_ticketsCount == 0)
         {
            this.m_ticketsCount = FeatureOptionsInventoryManager.getInstance().getCountByName(this.ItemName);
         }
         if(this.m_ticketsCount >= MAX_TICKET_COUNT)
         {
            this.m_ticketsCount = MAX_TICKET_COUNT;
         }
         return this.m_ticketsCount;
      }
      
      public function isMaxTicketsCollected() : Boolean
      {
         if(this.playerTicketCount >= MAX_TICKET_COUNT)
         {
            return true;
         }
         return false;
      }
   }
}

