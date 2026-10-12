package Managers
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.buffs.BHarvestHelper;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.TargetedRewardsWindow;
   
   public class TargetedRewardsManager
   {
      
      private static const NUM_DAYS_NOT_PLAYED:int = 7;
      
      private static const NUM_DAYS_LIMIT_FOR_FEATURE:int = 30;
      
      private static const MIN_LEVEL:int = 3;
      
      private static const HOURS_CLAIM_REWARD_2_STARTS:int = 24;
      
      private static const HOURS_CLAIM_REWARD_2_ENDS:int = 48;
      
      private static const DAYS_FEATURE_END:int = 7;
      
      private static const FEATURE_NAME:String = "TargetedRewards";
      
      public static const ITEM_NAME_KEY:String = "itemName";
      
      public static const ITEM_AMOUNT_KEY:String = "itemAmount";
      
      public static const SERVICE_CLASS:String = "TargetedRewardsService";
      
      private static var m_instance:TargetedRewardsManager = null;
      
      private static const DEFAULT_REWARDS:String = "consume_organic_fertilizer:1,consume_turbo_charger_7pack:1,consume_organic_fertilizer:1,buff_harvest_helper:1";
      
      private var m_currentTime:Number = 0;
      
      public function TargetedRewardsManager()
      {
         super();
         this.m_currentTime = int(GlobalEngine.serverTime / 1000);
      }
      
      public static function getInstance() : TargetedRewardsManager
      {
         if(m_instance == null)
         {
            m_instance = new TargetedRewardsManager();
         }
         return m_instance;
      }
      
      public function checkAndDisplayUI() : void
      {
         var flagName:String = null;
         var targetedRewardsWindow:TargetedRewardsWindow = null;
         var result:Boolean = false;
         var isFirstDay:Boolean = false;
         if(this.arePrerequirementsMet())
         {
            if(this.isFeatureActive())
            {
               if(this.isEligibleForSecondReward())
               {
                  flagName = this.getSecondRewardGrantFlagName();
                  Global.player.setSeenFlag(flagName,false,true);
                  result = true;
               }
            }
            else if(this.canStartFeature())
            {
               Global.player.setFeatureLastShown(FEATURE_NAME,this.m_currentTime,false);
               isFirstDay = true;
               result = true;
            }
         }
         if(result)
         {
            targetedRewardsWindow = new TargetedRewardsWindow(FEATURE_NAME,isFirstDay);
            UI.displayPopup(targetedRewardsWindow,!isFirstDay);
         }
         else
         {
            this.release();
         }
      }
      
      public function getRewardsToDisplay(isFirstDay:Boolean) : Array
      {
         var result:Array = this.getRewardData();
         if(!isFirstDay)
         {
            result.splice(0,2);
         }
         return result;
      }
      
      public function grantRewards(firstDay:Boolean) : void
      {
         var reward:Object = null;
         var giftName:String = null;
         var item:FarmItem = null;
         var buff:BHarvestHelper = null;
         var giftCount:int = 0;
         var rewards:Array = this.getRewardsToGrant(firstDay);
         for each(reward in rewards)
         {
            giftName = reward[ITEM_NAME_KEY];
            item = Global.farmGameSettingsManager.getFarmItemByName(giftName);
            if(item.className == BHarvestHelper.CLASS_NAME)
            {
               buff = new BHarvestHelper(giftName);
               buff.apply(true);
            }
            else
            {
               giftCount = int(reward[ITEM_AMOUNT_KEY]);
               Global.player.addGift(giftName,"0",giftCount);
            }
         }
         this.grantRewardsTransaction();
      }
      
      public function release() : void
      {
         m_instance = null;
      }
      
      private function getSecondRewardGrantFlagName() : String
      {
         var timeStampOfFeatureStart:Number = Global.player.getFeatureLastShown(FEATURE_NAME);
         return FEATURE_NAME + timeStampOfFeatureStart;
      }
      
      private function isEligibleForSecondReward() : Boolean
      {
         var flagName:String = null;
         var hasSeen:Boolean = false;
         var result:Boolean = false;
         var hoursSinceFeatureStarted:int = this.hoursSinceFeatureStart();
         if(hoursSinceFeatureStarted > HOURS_CLAIM_REWARD_2_STARTS && hoursSinceFeatureStarted < HOURS_CLAIM_REWARD_2_ENDS)
         {
            flagName = this.getSecondRewardGrantFlagName();
            hasSeen = Global.player.getSeenFlag(flagName);
            if(!hasSeen)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function canStartFeature() : Boolean
      {
         var daysSinceLastLogin:int = 0;
         var daysSinceFeatureStarted:int = 0;
         var result:Boolean = false;
         if(!this.isFeatureActive())
         {
            daysSinceLastLogin = this.daysSinceLastPlay();
            if(daysSinceLastLogin > NUM_DAYS_NOT_PLAYED)
            {
               daysSinceFeatureStarted = this.daysSinceFeatureStart();
               if(daysSinceFeatureStarted == 0)
               {
                  result = true;
               }
               else if(daysSinceFeatureStarted > NUM_DAYS_LIMIT_FOR_FEATURE)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      private function isFeatureActive() : Boolean
      {
         var result:Boolean = false;
         var daysSinceFeatureStarted:int = this.daysSinceFeatureStart();
         if(daysSinceFeatureStarted != 0 && daysSinceFeatureStarted < DAYS_FEATURE_END)
         {
            result = true;
         }
         return result;
      }
      
      private function daysSinceLastPlay() : int
      {
         var aheadTime:Number = this.m_currentTime - Global.player.lastLoginDayTimestamp;
         var dayNo:int = aheadTime / FarmGameUtil.NUM_SECS_IN_DAY;
         return int(dayNo + 1);
      }
      
      private function daysSinceFeatureStart() : int
      {
         var aheadTime:Number = NaN;
         var dayNo:int = 0;
         var result:int = 0;
         var lastShownTime:Number = Global.player.getFeatureLastShown(FEATURE_NAME);
         if(lastShownTime > 0)
         {
            aheadTime = this.m_currentTime - lastShownTime;
            dayNo = aheadTime / FarmGameUtil.NUM_SECS_IN_DAY;
            result = dayNo + 1;
         }
         return result;
      }
      
      private function hoursSinceFeatureStart() : int
      {
         var aheadTime:Number = NaN;
         var hourNo:int = 0;
         var result:int = 0;
         var lastShownTime:Number = Global.player.getFeatureLastShown(FEATURE_NAME);
         if(lastShownTime > 0)
         {
            aheadTime = this.m_currentTime - lastShownTime;
            hourNo = aheadTime / FarmGameUtil.NUM_SECS_IN_HOUR;
            result = hourNo + 1;
         }
         return result;
      }
      
      private function arePrerequirementsMet() : Boolean
      {
         var result:Boolean = false;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TARGETED_REWARDS);
         var currentLevel:int = Global.player.level;
         if(variant == 2 && currentLevel > MIN_LEVEL)
         {
            result = true;
         }
         return result;
      }
      
      private function getRewardData() : Array
      {
         var runtimeGifts:String = Global.flashHotParams["TARGETED_REWARDS"];
         var rewards:Array = this.parseGifts(runtimeGifts);
         if(rewards == null || rewards.length != 4)
         {
            rewards = this.parseGifts(DEFAULT_REWARDS);
         }
         return rewards;
      }
      
      private function parseGifts(giftsString:String) : Array
      {
         var gifts:Array = null;
         var i:int = 0;
         var giftString:String = null;
         var gift:Array = null;
         var result:Array = new Array();
         if(Boolean(giftsString) && giftsString != "")
         {
            gifts = giftsString.split(",");
            if(Boolean(gifts) && gifts.length == 4)
            {
               for(i = 0; i < gifts.length; i++)
               {
                  giftString = gifts[i];
                  gift = giftString.split(":");
                  if(Boolean(gift) && gift.length == 2)
                  {
                     result.push({
                        "itemName":gift[0],
                        "itemAmount":gift[1],
                        "index":i
                     });
                  }
               }
            }
         }
         return result;
      }
      
      private function getRewardsToGrant(isFirstDay:Boolean) : Array
      {
         var result:Array = this.getRewardData();
         if(!isFirstDay)
         {
            result.splice(0,2);
         }
         else
         {
            result.splice(2,2);
         }
         return result;
      }
      
      private function grantRewardsTransaction() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantRewards",this.onCompleteCallback));
      }
      
      private function onCompleteCallback(data:Object) : void
      {
      }
   }
}

