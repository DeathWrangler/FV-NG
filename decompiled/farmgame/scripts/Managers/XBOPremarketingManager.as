package Managers
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Transactions.TGenericTransactionWithFeed;
   import Transactions.TRefreshGifts;
   import Widgets.Windows.GenericSingleButtonWindow;
   import Widgets.Windows.XBOPremarketingWindow;
   import Widgets.Windows.XBORewardsWindow;
   import flash.events.Event;
   
   public class XBOPremarketingManager
   {
      
      private static var m_instance:XBOPremarketingManager;
      
      private const ASSET_MAIN:String = "main";
      
      private const ASSET_REWARD:String = "reward";
      
      private const ASSET_GRANT:String = "grant";
      
      private const SERVICE_NAME:String = "XBOPremarketingService";
      
      private const LAST_SEEN_REWARD:String = "lastSeenReward";
      
      private const DISCOUNT_GRANT:String = "discountGrant";
      
      public const WORLD_TYPE:String = "limbo";
      
      public var ASK_FEED_FREQUENCY_KEY:String;
      
      private var GRANT_POPUP_FLAG:String;
      
      private var INIT_FEATURE_FLAG:String;
      
      private var REWARDS_GRANT_FLAG:String;
      
      private var m_isActive:Boolean = false;
      
      private var m_featureName:String;
      
      private var m_assets:Array = null;
      
      private var m_prereqs:Array = null;
      
      private var m_milestones:Array = null;
      
      private var m_window:XBOPremarketingWindow = null;
      
      private var m_rewardsWindow:XBORewardsWindow = null;
      
      private var m_currencyName:String = null;
      
      private var m_askFeedFrequency:int = 21600;
      
      private var m_endTime:Number;
      
      private var m_endTimeString:String;
      
      private var m_maxRewards:int;
      
      private var m_ticketsCount:Number = NaN;
      
      public function XBOPremarketingManager(featureName:String, key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"Invalid TutorialManager Singleton access. Use TutorialManager.instance");
         if(key == null || typeof key != typeof SingletonEnforcer)
         {
            return;
         }
         this.loadFeatureConfig(featureName);
      }
      
      public static function instance(featureName:String = null) : XBOPremarketingManager
      {
         if(!m_instance)
         {
            m_instance = new XBOPremarketingManager(featureName,new SingletonEnforcer());
         }
         return m_instance;
      }
      
      private function loadFeatureConfig(featureName:String) : void
      {
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(featureName);
         if(featureXML == null)
         {
            return;
         }
         this.m_featureName = featureName;
         this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(featureXML.prereqs.children());
         this.m_assets = PrerequisiteUtility.parseXmlNodePrereqs(featureXML.assets.children());
         this.m_milestones = PrerequisiteUtility.parseXmlNodePrereqs(featureXML.rewards.children());
         this.m_currencyName = featureXML.currencyItem[0].@name.toString();
         this.GRANT_POPUP_FLAG = featureName + "GrantPopup";
         this.INIT_FEATURE_FLAG = featureName + "initFeature";
         this.ASK_FEED_FREQUENCY_KEY = featureName + "AskCurrency";
         this.REWARDS_GRANT_FLAG = featureName + "_rewardsGrant";
         this.m_askFeedFrequency = featureXML.feed.@throttleTime.toString();
         this.m_endTimeString = featureXML.listEndDate;
         this.m_maxRewards = this.m_milestones.length;
         this.m_isActive = true;
         if(!Global.player.getSeenFlag(this.INIT_FEATURE_FLAG))
         {
            this.m_ticketsCount = this.playerTicketCount + 25;
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"grantInitialTickets",null,[this.m_featureName]),true);
            Global.player.setSeenFlag(this.INIT_FEATURE_FLAG);
         }
      }
      
      public function get isActive() : Boolean
      {
         return this.m_isActive;
      }
      
      private function getEndTime(prereqs:Array) : String
      {
         var prereq:Object = null;
         var child:Object = null;
         for(var i:int = 0; i < prereqs.length; i++)
         {
            if(PrerequisiteUtility.getPreqreqType(prereqs[i]) == PrerequisiteConstants.PREREQUISITE_PREREQ_REFERENCE)
            {
               prereq = Global.farmGameSettingsManager.getPrereqByName(this.m_prereqs[i][PrerequisiteConstants.KEY_VALUE]);
               if(prereq.children_from_xml)
               {
                  for each(child in prereq.children_from_xml)
                  {
                     if(child.type == PrerequisiteConstants.PREREQUISITE_END_TIME)
                     {
                        return child.value;
                     }
                  }
               }
            }
            if(PrerequisiteUtility.getPreqreqType(this.m_prereqs[i]) == PrerequisiteConstants.PREREQUISITE_END_TIME)
            {
               return this.m_prereqs[i][PrerequisiteConstants.KEY_VALUE];
            }
         }
         return null;
      }
      
      private function get endTimeNumber() : Number
      {
         if(this.m_endTime)
         {
            return this.m_endTime;
         }
         this.m_endTime = FarmGameUtil.synchronizedDateTimeToNumber(this.m_endTimeString) / 1000;
         return this.m_endTime;
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      public function get assets() : Array
      {
         return this.m_assets;
      }
      
      public function get milestones() : Array
      {
         return this.m_milestones;
      }
      
      public function get maxMilestone() : int
      {
         return this.m_maxRewards;
      }
      
      private function getAssetURL(type:String) : String
      {
         for(var i:int = 0; i < this.assets.length; i++)
         {
            if(this.assets[i].name == type)
            {
               return this.assets[i].path;
            }
         }
         return null;
      }
      
      public function get carnivalTicketItemName() : String
      {
         return this.m_currencyName;
      }
      
      public function get hasUnlockedLimbo() : Boolean
      {
         return Global.worldManager.hasUnlockedWorld(this.WORLD_TYPE);
      }
      
      public function isFeaturePlayable() : Boolean
      {
         return FarmGameUtil.isFeatureInActivePeriod(this.m_endTimeString,0);
      }
      
      public function get isEAAvailable() : Boolean
      {
         return WorldSeasonsManager.getInstance().isEarlyAccessExpansionAvailable(this.WORLD_TYPE);
      }
      
      public function get isGAAvailable() : Boolean
      {
         return WorldSeasonsManager.getInstance().isGeneralAccessExpansionAvailable(this.WORLD_TYPE);
      }
      
      public function get isEAUser() : Boolean
      {
         return WorldSeasonsManager.getInstance().isEAUser(this.WORLD_TYPE);
      }
      
      public function getRewardIconUrl(milestoneIndex:int) : String
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.milestones[milestoneIndex].name);
         return farmItem.getImageByName("icon");
      }
      
      public function getRewardFriendlyName(milestoneIndex:int) : String
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.milestones[milestoneIndex].name);
         return farmItem.friendlyName;
      }
      
      public function showMainUI() : void
      {
         if(this.isFeaturePlayable() && this.currentMilestone < this.maxMilestone)
         {
            UI.displayPopup(this.m_window = new XBOPremarketingWindow(this.m_featureName,this.getAssetURL(this.ASSET_MAIN)));
         }
         else
         {
            UI.displayPopup(this.m_rewardsWindow = new XBORewardsWindow(this.m_featureName,this.getAssetURL(this.ASSET_REWARD)));
         }
      }
      
      public function showRewardsUI() : void
      {
         UI.displayPopup(this.m_rewardsWindow = new XBORewardsWindow(this.m_featureName,this.getAssetURL(this.ASSET_REWARD)));
      }
      
      public function get timeRemaining() : String
      {
         return FarmGameUtil.getTimeLeftText(this.endTimeNumber);
      }
      
      public function get endTimeString() : String
      {
         return this.m_endTimeString;
      }
      
      public function showRewardsOverlay(event:Event = null) : void
      {
         this.m_window.rewardsOverlayVisibility = true;
      }
      
      public function hideRewardsOverlay(event:Event = null) : void
      {
         this.m_window.rewardsOverlayVisibility = false;
      }
      
      public function get playerTicketCount() : int
      {
         if(isNaN(this.m_ticketsCount) || this.m_ticketsCount == 0)
         {
            this.m_ticketsCount = FeatureOptionsInventoryManager.getInstance().getCountByName(this.carnivalTicketItemName);
         }
         return this.m_ticketsCount;
      }
      
      public function askForTickets(event:Event = null) : void
      {
         if(this.getThrottleTimeRemaining(this.ASK_FEED_FREQUENCY_KEY) <= 0)
         {
            TransactionManager.addTransaction(new TGenericTransactionWithFeed(this.SERVICE_NAME,"askForTickets",this.onaskForTickets,[this.m_featureName]));
            Global.player.setFeatureLastShown(this.ASK_FEED_FREQUENCY_KEY,GlobalEngine.serverTime / 1000,false);
         }
      }
      
      public function requestTickets(event:Event) : void
      {
         MFSRequestManager.getInstance().makeSendRequestFreeGifts(this.carnivalTicketItemName,this.m_featureName);
      }
      
      private function onaskForTickets(e:Object) : void
      {
         if(this.m_window)
         {
            this.m_window.refreshAskButton();
         }
      }
      
      public function get MaxTickets() : Number
      {
         return this.milestones[this.milestones.length - 1].cost;
      }
      
      public function get currentMilestone() : int
      {
         for(var i:int = 0; i < this.milestones.length; i++)
         {
            if(this.playerTicketCount < this.milestones[i].cost)
            {
               return i;
            }
            if(this.playerTicketCount == this.milestones[i].cost)
            {
               return i + 1;
            }
         }
         return this.milestones.length;
      }
      
      public function get hasRewards() : Boolean
      {
         return this.currentMilestone > 0;
      }
      
      public function get nextMilestone() : int
      {
         return this.currentMilestone + 1 <= this.milestones.length ? int(this.currentMilestone + 1) : int(NaN);
      }
      
      public function getTicketsForMilestone(milestoneIndex:int) : int
      {
         if(milestoneIndex < 1)
         {
            return 0;
         }
         return this.milestones[milestoneIndex - 1].cost;
      }
      
      public function getThrottleTimeRemaining(key:String) : int
      {
         var time:int = 0;
         var now:int = int(GlobalEngine.serverTime / 1000);
         var lastShown:int = Global.player.getFeatureLastShown(key);
         var coolOffTime:int = 0;
         switch(key)
         {
            case this.ASK_FEED_FREQUENCY_KEY:
               coolOffTime = this.m_askFeedFrequency;
         }
         if(lastShown != 0)
         {
            time = lastShown + coolOffTime - now;
         }
         return time;
      }
      
      public function displayGrantPopup() : void
      {
         if(!Global.player.getSeenFlag(this.GRANT_POPUP_FLAG))
         {
            UI.displayPopup(new GenericSingleButtonWindow(this.getAssetURL(this.ASSET_GRANT),this.m_featureName,this.DISCOUNT_GRANT),false);
            Global.player.setSeenFlag(this.GRANT_POPUP_FLAG);
         }
      }
      
      public function set lastSeenReward(value:int) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,this.LAST_SEEN_REWARD,value);
         FeatureOptionsManager.getInstance().saveSingleFeature(this.m_featureName,this.LAST_SEEN_REWARD);
      }
      
      public function get lastSeenReward() : int
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,this.LAST_SEEN_REWARD) as int;
      }
      
      public function grantEarnedItems() : void
      {
         if(!Global.player.getSeenFlag(this.REWARDS_GRANT_FLAG))
         {
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"grantEarnedItems",this.onGrantEarnedItems,[this.m_featureName]));
         }
      }
      
      private function onGrantEarnedItems(e:Object = null) : void
      {
         TransactionManager.addTransaction(new TRefreshGifts());
         if(this.hasRewards)
         {
            this.showRewardsUI();
         }
         Global.player.setSeenFlag(this.REWARDS_GRANT_FLAG);
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
