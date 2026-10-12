package Managers
{
   import Classes.FeatureMessagingDefinition;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.PunchCardFeatureAvenuesWindow;
   import Widgets.Windows.PunchCardFeatureMainWindow;
   import Widgets.Windows.PunchCardFeatureRewardPopup;
   
   public class PunchCardFeatureManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "PunchCard";
      
      private static const SERVICE_NAME:String = "PunchCardFeatureService";
      
      public static const PREREQ_NAME:String = "punch_card_feature_enabled";
      
      private const SPEND_FEATURE_DATA:* = "PunchCardSpendData";
      
      private const FEATURE_END_DATE:String = "08/06/2020";
      
      public const NUM_MILESTONES:int = 10;
      
      public const LEVELS_FOR_GOLDCARD:int = 5;
      
      private var m_current_cash:int = 0;
      
      private const KEY_MILESTONE_LEVEL:String = "ms_level";
      
      private const KEY_PREVIOUS_EXPANSION_SPEND:String = "prev_spend";
      
      private const KEY_TEMP_LEVEL:String = "temp_level";
      
      private const FLAG_FIRST_TIME_SEEN:String = FEATURE_NAME + "first_time_seen";
      
      private const m_featureWorld:* = "canada";
      
      public const SPEND_MILESTONES:Array = new Array(0.8,1,1.2,1.4,1.6,1.7,1.8,1.9,2,2.1);
      
      public const MILESTONE_REWARDS:Array = new Array("turtle_rubyshell","duck_exoticmandarin","bigcat_exoticwhitelion","giraffe_colorful","horse_chestnutrace","llama_goldenfur","elephant_goldhorn","cow_bighorn","goat_longhair","pegacorn_bigwings");
      
      private const MAIN_WINDOW_URL:String = "assets/dialogs/FV_PunchCard_2020/FV_PunchCard_MainScreen.swf";
      
      private const AVENUES_WINDOW_URL:String = "assets/dialogs/FV_PunchCard_2020/FV_PunchCard_AvenueToSpend.swf";
      
      private const REWARD_POPUP_URL:String = "assets/dialogs/FV_PunchCard_2020/FV_PunchCard_RewardMoment.swf";
      
      public var m_mainWindow:PunchCardFeatureMainWindow;
      
      public var m_avenueWindow:PunchCardFeatureAvenuesWindow;
      
      public var m_rewardPopup:PunchCardFeatureRewardPopup;
      
      public function PunchCardFeatureManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.m_current_cash = Global.player.cash;
         this.startQuest();
         TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onTransactionCompleted);
      }
      
      public static function getInstance(featureName:String = "PunchCard") : PunchCardFeatureManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,PunchCardFeatureManager) as PunchCardFeatureManager;
      }
      
      public function startQuest() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",this.onFeatureInitialized,[FEATURE_NAME]),true);
      }
      
      private function onFeatureInitialized(result:Object) : void
      {
         this.m_current_cash = Global.player.cash;
         if(Boolean(result) && result.hasOwnProperty("featureData"))
         {
            FeatureOptionsManager.getInstance().setFeature(FEATURE_NAME,result["featureData"]);
            this.saveFeatureOptionsKey(this.KEY_TEMP_LEVEL,this.currentMilestoneLevel);
         }
      }
      
      protected function onTransactionCompleted(event:TransactionEvent) : void
      {
         if(this.isFeatureActive())
         {
            if(Global.player.cash < this.m_current_cash && !this.isFeatureCompletedByUser())
            {
               this.m_current_cash = Global.player.cash;
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"checkForUpdates",this.checkUpdateFeature,[FEATURE_NAME]));
            }
         }
      }
      
      public function checkUpdateFeature(result:Object) : void
      {
         var rewardGrantList:* = undefined;
         var resultData:Object = null;
         this.m_current_cash = Global.player.cash;
         if(Boolean(result) && result.hasOwnProperty("curr_spend"))
         {
            FeatureOptionsManager.getInstance().setFeatureOption(this.SPEND_FEATURE_DATA,this.m_featureWorld,result["curr_spend"]);
         }
         if(Boolean(result) && result.hasOwnProperty("updated"))
         {
            if(result["updated"] == true)
            {
               this.saveFeatureOptionsKey(this.KEY_TEMP_LEVEL,this.currentMilestoneLevel);
               rewardGrantList = new Array();
               if(result.hasOwnProperty("data"))
               {
                  for each(resultData in result["data"])
                  {
                     if(resultData.hasOwnProperty("reward"))
                     {
                        Global.player.addGift(resultData["reward"]);
                        rewardGrantList.push(resultData["reward"]);
                     }
                     if(resultData.hasOwnProperty("ms_level"))
                     {
                        this.saveFeatureOptionsKey(this.KEY_MILESTONE_LEVEL,resultData["ms_level"]);
                        FarmStatsManager.count(FEATURE_NAME,"milestone_granted",resultData["ms_level"].toString());
                     }
                  }
               }
               if(result.hasOwnProperty("goldcard_spend"))
               {
                  this.saveFeatureOptionsKey(this.KEY_MILESTONE_LEVEL,this.LEVELS_FOR_GOLDCARD);
                  this.saveFeatureOptionsKey(this.KEY_PREVIOUS_EXPANSION_SPEND,result["goldcard_spend"]);
               }
               if(Boolean(this.m_mainWindow) && this.m_mainWindow.isLoaded())
               {
                  this.m_mainWindow.close();
               }
               this.showMainWindow(rewardGrantList);
            }
            else if(!Global.player.getSeenFlag(this.FLAG_FIRST_TIME_SEEN))
            {
               this.showMainWindow();
            }
         }
      }
      
      public function showMainWindow(rewardsGranted:Array = null) : void
      {
         this.m_mainWindow = new PunchCardFeatureMainWindow(FEATURE_NAME,this.MAIN_WINDOW_URL,rewardsGranted);
         UI.displayPopup(this.m_mainWindow,false);
         Global.player.setSeenFlag(this.FLAG_FIRST_TIME_SEEN);
         FarmStatsManager.count(FEATURE_NAME,"mainui","open");
      }
      
      public function showAvenuesWindow() : void
      {
         this.m_avenueWindow = new PunchCardFeatureAvenuesWindow(FEATURE_NAME,this.AVENUES_WINDOW_URL);
         UI.displayPopup(this.m_avenueWindow,false);
         FarmStatsManager.count(FEATURE_NAME,"avenues_ui","open");
      }
      
      public function showRewardPopup(rewardItem:FarmItem) : void
      {
         this.m_rewardPopup = new PunchCardFeatureRewardPopup(FEATURE_NAME,this.REWARD_POPUP_URL,rewardItem);
         UI.displayPopup(this.m_rewardPopup,false);
         FarmStatsManager.count(FEATURE_NAME,"reward_popup","open");
      }
      
      public function get currentMilestoneLevel() : int
      {
         return this.getFeatureOptionsKey(this.KEY_MILESTONE_LEVEL) as int;
      }
      
      public function get currentTempLevel() : int
      {
         return this.getFeatureOptionsKey(this.KEY_TEMP_LEVEL) as int;
      }
      
      public function get previousExpansionSpend() : int
      {
         return this.getFeatureOptionsKey(this.KEY_PREVIOUS_EXPANSION_SPEND) as int;
      }
      
      public function get currentExpansionSpend() : int
      {
         var amount:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.SPEND_FEATURE_DATA,this.m_featureWorld);
         return Math.abs(amount as int);
      }
      
      public function updateTempLevel() : void
      {
         this.saveFeatureOptionsKey(this.KEY_TEMP_LEVEL,this.currentMilestoneLevel);
      }
      
      public function getMilestoneSpendAmount(spendIndex:int) : String
      {
         var milestoneAmount:int = 0;
         var currentSpend:int = this.currentExpansionSpend;
         if(spendIndex < this.SPEND_MILESTONES.length)
         {
            milestoneAmount = Math.floor(this.previousExpansionSpend * this.SPEND_MILESTONES[spendIndex]);
         }
         return currentSpend + "/" + milestoneAmount;
      }
      
      public function isFeatureActive() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName(PREREQ_NAME);
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = true;
         }
         return result;
      }
      
      public function isFeatureCompletedByUser() : Boolean
      {
         var result:Boolean = false;
         if(this.currentMilestoneLevel == this.NUM_MILESTONES)
         {
            result = true;
         }
         return result;
      }
      
      public function setupHud() : void
      {
         var hudData:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(FEATURE_NAME);
         if(hudData)
         {
            hudData.updateIconVisibility();
         }
      }
      
      public function getFeatureTimerText() : String
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var days:int = 0;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(this.FEATURE_END_DATE);
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var result:String = "";
         if(timeLeft < 0)
         {
            timeLeft = 0;
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(timeLeft);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            days = int(timeLeftArray[0]);
            result = days.toString();
            if(days == 1)
            {
               result += " Day left!";
            }
            else if(days == 0)
            {
               result = HUD.getformattedTimeLeft(timeLeft) + " left!";
            }
            else
            {
               result += " Days left!";
            }
         }
         return result;
      }
      
      public function closeAndOpenMainWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         this.showMainWindow();
      }
      
      public function closeMainWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
      }
      
      private function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,optionName,optionsValue);
      }
      
      private function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,optionName);
      }
   }
}

