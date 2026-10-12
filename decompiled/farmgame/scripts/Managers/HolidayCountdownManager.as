package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.ToasterIconPaths;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.DynamicIconQueue;
   import Display.FarmDynamicDialog;
   import Display.GenericPopup;
   import Display.QueuedIcon;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import HolidayCountdown.HolidayCountdownIconStates;
   import HolidayCountdown.HolidayCountdownMessageIcon;
   import Transactions.TGenericTransaction;
   import Transactions.THolidayCountdownBuyItem;
   import Transactions.THolidayCountdownPublishBonusFeed;
   import Transactions.THolidayCountdownSeenWhatIsThis;
   import Transactions.THolidayCountdownUnlockItem;
   import Widgets.Windows.CountdownReplayPopup;
   import Widgets.Windows.CountdownRewardDialog;
   import Widgets.Windows.CountdownWindow;
   import Widgets.Windows.IconTitleToasterWindow;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.display.DisplayObject;
   
   public class HolidayCountdownManager
   {
      
      protected static var m_config:Object;
      
      protected static var m_data:Object;
      
      protected static var m_rewards:Array;
      
      protected static var m_dialog:FarmDynamicDialog;
      
      protected static var m_finishedDialog:GenericDialog;
      
      protected static var m_acquiredAllItems:Boolean;
      
      protected static var m_bonusDialog:FarmDynamicDialog;
      
      protected static var m_hudIcon:QueuedIcon;
      
      private static var m_featureLoadingTime:Number;
      
      protected static const HUDICON_OFFSET_X:Number = 646;
      
      protected static const HUDICON_OFFSET_Y:Number = 80;
      
      private static const HUDICON_TOOLTIP_WIDTH:Number = 300;
      
      protected static const BONUS_STAR_ASSET_PATH:String = "assets/dialogs/4d_elements/";
      
      protected static const HUD_EXPERIMENT:String = "fv_2012_aprilCountdown_iconAnimation";
      
      public static const STAT_HUD_ICON_SUBCOUNTER:String = "hud_icon";
      
      public static const STAT_MAIN_DIALOG_SUBCOUNTER:String = "home_dialog";
      
      public static const STAT_COMPLETED_DIALOG_SUBCOUNTER:String = "completed_dialog";
      
      public static const STAT_IDLE_POP_SUBCOUNTER:String = "idle_pop_ui";
      
      public static const STAT_ERROR_ELIGIBLE_RECIPIENTS:String = "error_eligible_recipients";
      
      public static const DEFAULT_FEATURE_NAME:String = "HolidayCountdown";
      
      public static const DEFAULT_DIALOG_NAME:String = "holidayCountdown";
      
      protected static const WHAT_IS_THIS_MAX_OCCURANCE:int = 3;
      
      private static var m_trackBackoff:Boolean = false;
      
      private static var m_countWindow:CountdownWindow = null;
      
      private static var m_unlockedIndices:Object = {};
      
      private static var m_unlockedTime:int = 0;
      
      private static var m_newReceivedItem:String = "";
      
      public function HolidayCountdownManager()
      {
         super();
      }
      
      public static function set rewards(rewards:Array) : void
      {
         m_rewards = rewards;
      }
      
      public static function addReward(itemCode:String) : void
      {
         m_rewards.push({
            "itemCode":itemCode,
            "timestamp":GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND
         });
      }
      
      public static function get individualRewardTimeLimit() : int
      {
         var result:int = 0;
         if(m_config.hasOwnProperty("individualRewardTimeLimit"))
         {
            result = int(m_config["individualRewardTimeLimit"]);
         }
         return result;
      }
      
      public static function get rewardType() : String
      {
         var result:String = "";
         if(m_config.hasOwnProperty("rewardType"))
         {
            result = m_config["rewardType"];
         }
         return result;
      }
      
      public static function set acquiredAllItems(acquiredAllItems:Boolean) : void
      {
         m_acquiredAllItems = acquiredAllItems;
      }
      
      public static function init(params:Object) : void
      {
         var hcToasterItem:FarmItem = null;
         var localizedToasterTitle:String = null;
         var localizedToasterText:String = null;
         var data:Object = Boolean(params) && params.hasOwnProperty("holidayCountdown") ? params["holidayCountdown"] : null;
         if(data)
         {
            m_config = data["config"];
            m_data = data["data"];
            m_newReceivedItem = data["newItem"];
            m_unlockedIndices = data["unlockedIndices"];
            m_unlockedTime = data["unlockedTime"];
            m_rewards = data["rewards"];
            m_acquiredAllItems = data["acquiredAllItems"];
            m_featureLoadingTime = GlobalEngine.serverTime;
            if(m_config["bonusPrizeItem"] != null && m_config["justReceivedBonus"] != null)
            {
               Global.player.addGift(m_config["bonusPrizeItem"]);
            }
            setupHudIcon();
            hcToasterItem = HolidayCountdownManager.shouldShowToaster();
            if(hcToasterItem != null)
            {
               localizedToasterTitle = ZLocUtils.t("HolidayCountdown","HolidayCountdown_ToasterTitle");
               localizedToasterText = ZLocUtils.t("HolidayCountdown",HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdown_ToasterBody"),{
                  "item":ZLocUtils.tk_pk_asTitle(hcToasterItem.friendlyName),
                  "countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))
               });
               if(hcToasterItem.className == "CSeedPackage")
               {
                  localizedToasterText += ZLocUtils.t("HolidayCountdown",HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdown_ToasterSeed"));
               }
               ToasterManager.getInstance().add(new IconTitleToasterWindow(localizedToasterTitle,localizedToasterText,hcToasterItem.icon,ToasterIconPaths.DIALOG_ASSET,0.7,null,HolidayCountdownManager.displayDialog));
            }
         }
      }
      
      private static function setupHudIcon() : void
      {
         var giftFarmItem:FarmItem = null;
         var iconName2:String = null;
         var daysLeft:int = getDaysLeftInCampaign();
         var timeText:String = "";
         if(isRepeatingCountdown() || canRestartCountdown())
         {
            timeText = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("Replay_hudTooltip"));
         }
         else if(daysLeft <= 0)
         {
            timeText = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdown_hudTooltip"),{
               "timeStr":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,"HolidayCountdown_hudTooltip_postCountdown"),
               "countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))
            });
         }
         else if(daysLeft == 1)
         {
            timeText = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdown_hudTooltip"),{
               "timeStr":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,"HolidayCountdown_hudIconDaysLeftSingular"),
               "countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))
            });
         }
         else
         {
            timeText = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdown_hudTooltip"),{
               "timeStr":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,"HolidayCountdown_hudIconDaysLeftPlural",{"quantity":daysLeft}),
               "countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))
            });
         }
         var hudIconIndex:int = 0;
         if(m_config["hudIconIndex"])
         {
            hudIconIndex = int(m_config["hudIconIndex"]);
         }
         var hudIconData:Object = {
            "hudIconIndex":hudIconIndex,
            "iconTooltip":timeText
         };
         var daysLeftWithOffboarding:int = daysLeft + int(m_config["extraDays"]);
         if(hudIconIndex == HolidayCountdownIconStates.NEW_GIFT)
         {
            hudIconData.message = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdown_hudIconNewGift"),{"countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))});
         }
         else if(hudIconIndex == HolidayCountdownIconStates.DAYS_LEFT)
         {
            if(daysLeftWithOffboarding == 1)
            {
               hudIconData.message = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdown_hudIconDaysLeftSingular"),{"countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))});
            }
            else
            {
               hudIconData.message = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdown_hudIconDaysLeftPlural"),{
                  "quantity":daysLeftWithOffboarding,
                  "countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))
               });
            }
         }
         var currentDay:int = HolidayCountdownManager.getDaysSinceCampaignStarted();
         var duration:int = int(m_config["duration"]);
         if(currentDay >= duration)
         {
            currentDay = duration - 1;
         }
         hudIconData.helperItemIcon = Global.farmGameSettingsManager.getFarmItemByCode("HB").icon;
         var helperFarmItem:FarmItem = HolidayCountdownManager.getHelperItemByIndex(currentDay);
         if(helperFarmItem != null && helperFarmItem.icon != null)
         {
            hudIconData.helperItemIcon = helperFarmItem.icon;
         }
         else
         {
            ErrorManager.addError("hud icon helper item is null when currentDay=" + currentDay);
         }
         var giftItemCode:String = HolidayCountdownManager.getItemCodeByIndex(currentDay);
         hudIconData.giftItemIcon = Global.farmGameSettingsManager.getFarmItemByCode("HB").icon;
         if(giftItemCode != "")
         {
            giftFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(giftItemCode);
            if(giftFarmItem != null && giftFarmItem.icon != null)
            {
               hudIconData.giftItemIcon = giftFarmItem.icon;
            }
            else
            {
               ErrorManager.addError("hud icon gift item (" + giftItemCode + ") is null when currentDay=" + currentDay);
            }
         }
         else
         {
            ErrorManager.addError("hud icon gift item code is blank when currentDay=" + currentDay);
         }
         var iconName:String = getFeatureName();
         var hudExperiment:int = Global.experimentManager.getExperimentVariant(HUD_EXPERIMENT);
         var icon_variant:QueuedIcon = null;
         if(hudExperiment > 1)
         {
            iconName2 = iconName + "_Variant" + hudExperiment;
            icon_variant = Global.hud.rightSideIconQueue.addIcon(iconName2,DynamicIconQueue.ADD_BY_PRIORITY,null,hudIconData,false);
         }
         if(icon_variant != null)
         {
            m_hudIcon = icon_variant;
         }
         else
         {
            m_hudIcon = Global.hud.rightSideIconQueue.addIcon(iconName,DynamicIconQueue.ADD_BY_PRIORITY,null,hudIconData,false);
         }
         m_hudIcon.toolTipWidth = HUDICON_TOOLTIP_WIDTH;
         m_hudIcon.contentManip = recordIconShowStats;
      }
      
      public static function hasAcquiredAllItems() : Boolean
      {
         return m_acquiredAllItems;
      }
      
      public static function recordHudIconStats(phylum:String) : void
      {
         var zclass:String = null;
         var mode:int = (m_hudIcon as HolidayCountdownMessageIcon).mode;
         switch(mode)
         {
            case HolidayCountdownIconStates.ATTRACT:
               zclass = "normal_state";
               break;
            case HolidayCountdownIconStates.DONE:
               zclass = "received_item_state";
               break;
            case HolidayCountdownIconStates.NEW_GIFT:
               zclass = "new_item_state";
               break;
            default:
               zclass = String(mode);
         }
         FarmStatsManager.count(getStatCounter(),STAT_HUD_ICON_SUBCOUNTER,phylum,zclass);
      }
      
      public static function recordIconShowStats(iconContent:DisplayObject) : void
      {
         recordHudIconStats("impressions");
      }
      
      public static function recordDialogStats(phylum:String, zclass:String) : void
      {
         FarmStatsManager.count(getStatCounter(),STAT_MAIN_DIALOG_SUBCOUNTER,phylum,zclass);
      }
      
      public static function displayDialog(trackBackoff:Boolean = false) : void
      {
         Global.player.setFeatureLastShown(HolidayCountdownManager.getFeatureName(),GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
         (m_hudIcon as HolidayCountdownMessageIcon).showAttractMode();
         m_trackBackoff = trackBackoff;
         destroyDialog();
         var inIngameSurveyExperiment:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_INGAME_SURVEYS) == Experiments.VARIANT_FLASH_INGAME_SURVEYS_ON;
         if(Boolean(m_config != null) && Boolean(m_config["swf"]) && Boolean(m_config["featureName"]))
         {
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.COUNTDOWN))
            {
               if(inIngameSurveyExperiment)
               {
                  m_countWindow = new CountdownWindow(TemplateUIUtility.COUNTDOWN1_TEMPLATE_SWF,m_config["featureName"]);
               }
               else
               {
                  m_countWindow = new CountdownWindow(TemplateUIUtility.COUNTDOWN_TEMPLATE_SWF,m_config["featureName"]);
               }
            }
            else
            {
               m_countWindow = new CountdownWindow(m_config["swf"],m_config["featureName"]);
            }
            UI.displayPopup(m_countWindow);
            FeatureTrackingManager.instance.uiOpen(m_config["featureName"]);
         }
      }
      
      public static function get dialogBackground() : String
      {
         var result:String = "";
         if(Boolean(m_config) && Boolean(m_config["dialogBackground"]))
         {
            result = m_config["dialogBackground"];
         }
         return result;
      }
      
      public static function get textColor() : String
      {
         var result:String = "";
         if(Boolean(m_config) && Boolean(m_config["textColor"]))
         {
            result = m_config["textColor"];
         }
         return result;
      }
      
      public static function get replaySwf() : String
      {
         var result:String = "";
         if(m_config["replaySwf"])
         {
            result = m_config["replaySwf"];
         }
         return result;
      }
      
      public static function canUnlockDay(day:int) : Boolean
      {
         var highestUnlocked:int = 0;
         var result:Boolean = false;
         var nDays:int = int(m_config["unlockPlusNDays"]);
         if(nDays == -1)
         {
            result = true;
         }
         else
         {
            highestUnlocked = HolidayCountdownManager.getDaysSinceCampaignStarted();
            do
            {
               if(highestUnlocked + nDays >= day)
               {
                  result = true;
                  break;
               }
               highestUnlocked++;
            }
            while(m_unlockedIndices[highestUnlocked] != null);
         }
         return result;
      }
      
      public static function refreshDialog() : void
      {
         if(m_countWindow)
         {
            m_countWindow.refreshWindow();
         }
      }
      
      public static function dialogClosed() : void
      {
         if(m_trackBackoff)
         {
            Global.player.incrementBackoffInterval(HolidayCountdownManager.getFeatureName());
            FarmStatsManager.count(HolidayCountdownManager.getStatCounter(),HolidayCountdownManager.STAT_IDLE_POP_SUBCOUNTER,"cancels");
            m_trackBackoff = false;
         }
      }
      
      public static function updateItemsData(items:Object) : void
      {
         m_config["items"] = items;
      }
      
      public static function showShareBonusDialog() : void
      {
         var bonusItem:FarmItem = null;
         var title:String = null;
         var message:String = null;
         var message2:String = null;
         if(m_config["bonusPrizeItem"])
         {
            bonusItem = Global.farmGameSettingsManager.getFarmItemByName(m_config["bonusPrizeItem"]);
            title = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,"HolidayCountdownShareBonusTitle");
            message = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownShareBonusBody"),{
               "item":bonusItem.friendlyTitle,
               "countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))
            });
            message2 = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownShareBonusBottom"));
            if(m_config["customShareDialog"])
            {
               UI.displayPopup(new CountdownRewardDialog(m_config["customShareDialog"],title,message,message2,bonusItem),false);
            }
            else
            {
               m_bonusDialog = UI.showMessage(message,UI.BUTTON_LAYOUT_SHARE,title,bonusItem.iconRelativeUrl,true,onShareBonusDialogClose);
            }
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,getStatCounter() + "-share_bonus_prize",StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         }
      }
      
      public static function shouldShowWhatIsThis() : Number
      {
         var seenWhatIsThis:int = -1;
         if(getDaysSinceCampaignStarted() < Math.round(m_config["duration"] / 2))
         {
            if(m_data["seenWhatIsThis"] == null)
            {
               seenWhatIsThis = 0;
            }
            else if(m_data["seenWhatIsThis"] >= WHAT_IS_THIS_MAX_OCCURANCE)
            {
               seenWhatIsThis = -1;
            }
         }
         return seenWhatIsThis;
      }
      
      public static function setSeenWhatIsThis(count:int = 3) : void
      {
         m_data["seenWhatIsThis"] = count;
         if(count <= WHAT_IS_THIS_MAX_OCCURANCE)
         {
            TransactionManager.addTransaction(new THolidayCountdownSeenWhatIsThis(count));
         }
      }
      
      public static function getHDTWImage(slot:Number) : String
      {
         return m_config["HDTWImage" + slot.toString()];
      }
      
      public static function onShareBonusDialogClose(event:WidgetControllerEvent) : void
      {
         var bonusItem:FarmItem = null;
         var message:String = null;
         TransactionManager.addTransaction(new THolidayCountdownPublishBonusFeed(),true);
         if(m_bonusDialog)
         {
            m_bonusDialog.destroy();
         }
         if(HolidayCountdownManager.canRestartCountdown())
         {
            UI.displayPopup(new CountdownReplayPopup(HolidayCountdownManager.replaySwf),false);
         }
         else if(HolidayCountdownManager.restartCount() > 0)
         {
            bonusItem = Global.farmGameSettingsManager.getFarmItemByName(m_config["bonusPrizeItem"]);
            message = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("Replay_LimitReached"),{"item":bonusItem.friendlyTitle});
            m_finishedDialog = UI.showMessage(message,UI.BUTTON_LAYOUT_OK,null,null,false,trackUserFinishedCountdownReplays);
            FarmStatsManager.count(HolidayCountdownManager.getStatCounter(),HolidayCountdownManager.STAT_COMPLETED_DIALOG_SUBCOUNTER,"no_more_repeat","ok_button","impressions");
         }
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,getStatCounter() + "-share_bonus_prize",StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
      }
      
      private static function trackUserFinishedCountdownReplays(isAccept:Boolean) : void
      {
         if(isAccept)
         {
            FarmStatsManager.count(HolidayCountdownManager.getStatCounter(),HolidayCountdownManager.STAT_COMPLETED_DIALOG_SUBCOUNTER,"no_more_repeat","ok_button","clicks");
         }
         if(m_finishedDialog)
         {
            m_finishedDialog.destroy();
         }
      }
      
      public static function destroyDialog() : void
      {
         if(m_countWindow)
         {
            m_countWindow.close();
         }
      }
      
      public static function getHelperItemByIndex(index:int) : FarmItem
      {
         var helperItemCode:String = null;
         var helperItem:FarmItem = null;
         if(Boolean(m_config["itemHelpers"]) && Boolean(m_config["itemHelpers"][index]) && Boolean(m_config["itemHelpers"][index]["helperItem"]))
         {
            helperItemCode = m_config["itemHelpers"][index]["helperItem"];
            if(helperItemCode)
            {
               helperItem = Global.farmGameSettingsManager.getFarmItemByCode(helperItemCode);
            }
         }
         else if(m_config["itemHelpers"] == null)
         {
            ErrorManager.addError("m_config[\'itemHelpers\'] is null");
         }
         else if(m_config["itemHelpers"][index] == null)
         {
            ErrorManager.addError("m_config[\'itemHelpers\'][index] is null when index=" + index);
         }
         else if(m_config["itemHelpers"][index]["helperItem"] == null)
         {
            ErrorManager.addError("m_config[\'itemHelpers\'][index][\'helperItem\'] is null when index=" + index);
         }
         return helperItem;
      }
      
      public static function getProgressToNextReward(index:int) : Number
      {
         var itemCode:String = getItemCodeByIndex(index);
         var result:int = 0;
         if(Boolean(itemCode) && Boolean(m_data[itemCode]))
         {
            result = m_data[itemCode].length % requiredHelperCount(index);
         }
         return result;
      }
      
      public static function requiredHelperCount(index:int) : Number
      {
         var result:Number = 0;
         if(Boolean(m_config) && Boolean(m_config["itemHelpers"]))
         {
            result = Number(m_config["itemHelpers"][index]["helperCount"]);
         }
         return result;
      }
      
      public static function hasReachedMaxProgress(index:int) : Boolean
      {
         var itemCode:String = getItemCodeByIndex(index);
         var result:Boolean = false;
         if(itemCode != "" && Boolean(m_data[itemCode]))
         {
            result = Boolean(m_data[itemCode]) && m_data[itemCode].length >= maxProgress(index);
         }
         return result;
      }
      
      public static function maxProgress(index:int) : Number
      {
         return requiredHelperCount(index) * m_config["itemCountLimit"];
      }
      
      public static function finishProgressForFirstReward(index:int) : void
      {
         var itemCode:String = getItemCodeByIndex(index);
         if(!m_data[itemCode])
         {
            m_data[itemCode] = new Array();
         }
         for(var i:int = int(m_data[itemCode].length); i < requiredHelperCount(index); i++)
         {
            m_data[itemCode].push(1);
         }
      }
      
      public static function addProgressForFirstReward(index:int) : void
      {
         var itemCode:String = getItemCodeByIndex(index);
         if(!m_data[itemCode])
         {
            m_data[itemCode] = new Array();
         }
         m_data[itemCode].push(1);
         recalculateHasAllItems();
      }
      
      public static function getUnlockPrice(index:int) : int
      {
         var unlockPrice:int = -1;
         if(Boolean(m_config["itemCost"]) && Boolean(m_config["itemCost"][index]) && Boolean(m_config["itemCost"][index]["premium"]))
         {
            unlockPrice = int(m_config["itemCost"][index]["premium"]);
         }
         return unlockPrice;
      }
      
      public static function getCompleteNowPrice() : int
      {
         var itemCostInfo:Object = null;
         var itemCost:int = 0;
         var premium:int = 0;
         var completeNowPrice:int = 0;
         var index:int = 0;
         for each(itemCostInfo in m_config["itemCost"])
         {
            itemCost = int(itemCostInfo["cash"]);
            premium = int(itemCostInfo["premium"]);
            if(m_unlockedIndices[index] == null && index > HolidayCountdownManager.getDaysSinceCampaignStarted())
            {
               completeNowPrice += itemCost + premium;
            }
            else if(getOwnedItemCount(index) == 0)
            {
               completeNowPrice += itemCost;
            }
            index++;
         }
         return completeNowPrice;
      }
      
      private static function recalculateHasAllItems() : void
      {
         var hasAll:Boolean = false;
         var index:int = 0;
         var itemCostInfo:Object = null;
         if(!m_acquiredAllItems)
         {
            hasAll = true;
            index = 0;
            for each(itemCostInfo in m_config["itemCost"])
            {
               if(getOwnedItemCount(index) == 0)
               {
                  hasAll = false;
                  break;
               }
               index++;
            }
            m_acquiredAllItems = hasAll;
         }
      }
      
      public static function canPostItemOfTheDayReward(index:int) : Boolean
      {
         var featureLastShown:Number = NaN;
         var canPostFeed:Boolean = false;
         var itemCode:String = getItemCodeByIndex(index);
         if(itemCode)
         {
            if(!m_data[itemCode] || getOwnedItemCount(index) < 1)
            {
               canPostFeed = true;
            }
         }
         if(canPostFeed)
         {
            featureLastShown = Global.player.getFeatureLastShown(HolidayCountdownManager.rewardType);
            if(featureLastShown >= GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - HolidayCountdownManager.individualRewardTimeLimit && m_unlockedTime <= featureLastShown)
            {
               canPostFeed = false;
            }
         }
         return canPostFeed;
      }
      
      public static function getOwnedItemCount(index:int) : int
      {
         var result:int = 0;
         var itemCode:String = getItemCodeByIndex(index);
         if(Boolean(itemCode) && Boolean(m_data[itemCode]) && Boolean(m_data[itemCode].length) && requiredHelperCount(index) != 0)
         {
            result = Math.floor(m_data[itemCode].length / requiredHelperCount(index));
         }
         return result;
      }
      
      public static function getItemCodeByIndex(index:int) : String
      {
         var itemCode:String = "";
         if(index >= 0 && null != m_config["items"][index])
         {
            itemCode = m_config["items"][index];
         }
         return itemCode;
      }
      
      public static function getItemCostByIndex(index:int) : int
      {
         var cost:int = 0;
         var itemCode:String = null;
         var helperCount:int = 0;
         var currentProgress:int = 0;
         var costPerHelper:Number = NaN;
         if(index >= 0 && null != m_config["itemCost"][index]["cash"])
         {
            cost = int(m_config["itemCost"][index]["cash"]);
         }
         if(isProrationEnabled())
         {
            itemCode = getItemCodeByIndex(index);
            helperCount = int(m_config["itemHelpers"][index]["helperCount"]);
            currentProgress = m_data[itemCode] ? int(m_data[itemCode].length) : 0;
            if(currentProgress < helperCount)
            {
               costPerHelper = cost / helperCount;
               cost -= Math.floor(costPerHelper * currentProgress);
            }
         }
         return cost;
      }
      
      private static function isProrationEnabled() : Boolean
      {
         var result:Boolean = false;
         var smartCountdownVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_COUNTDOWN);
         var smartQuestVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_QUESTS);
         if(smartQuestVariant >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START && (smartCountdownVariant == Experiments.VARIANT_COUNTDOWN_PRORATE_ONLY || smartCountdownVariant == Experiments.VARIANT_SMART_COUNTDOWN_WITH_PRORATE))
         {
            result = true;
         }
         return result;
      }
      
      public static function getCountdownCompletionHistory() : Array
      {
         var result:Array = null;
         if(Boolean(m_data) && Boolean(m_data["countdownCompletionHistory"]))
         {
            result = m_data["countdownCompletionHistory"];
         }
         else
         {
            result = [];
         }
         return result;
      }
      
      public static function getItemPackageByIndex(index:int) : String
      {
         var packageCount:String = null;
         if(index >= 0 && null != m_config["packageCount"][index])
         {
            packageCount = m_config["packageCount"][index];
         }
         return packageCount;
      }
      
      public static function getCurrentItemCode() : String
      {
         var currentItemIndex:int = getDaysSinceCampaignStarted();
         return getItemCodeByIndex(currentItemIndex);
      }
      
      public static function getDaysSinceCampaignStarted() : int
      {
         var startDate:Number = FarmGameUtil.synchronizedDateToNumber(m_config["startDate"]);
         var headStartHours:Number = Number(m_config["headStartHours"]);
         var timeDiff:Number = m_featureLoadingTime - startDate;
         if(timeDiff < 0 && headStartHours >= 0)
         {
            timeDiff += headStartHours * FarmGameUtil.NUM_MSECS_IN_HOUR;
         }
         timeDiff /= FarmGameUtil.NUM_MSECS_IN_DAY;
         return int(Math.floor(timeDiff));
      }
      
      public static function getDaysLeftInCampaign() : int
      {
         var daysSoFar:int = getDaysSinceCampaignStarted();
         return int(m_config["duration"]) - daysSoFar;
      }
      
      public static function extraDaysLeft() : int
      {
         var extraDays:int = 0;
         var result:int = -1;
         var daysLeft:int = HolidayCountdownManager.getDaysLeftInCampaign();
         if(daysLeft <= 0)
         {
            extraDays = int(m_config["extraDays"]);
            result = daysLeft + extraDays;
         }
         return result;
      }
      
      public static function getNumberOfExtraDays() : int
      {
         return int(m_config["extraDays"]);
      }
      
      public static function buyItemByIndex(index:int) : void
      {
         var daysSinceCampaignStarted:int = getDaysSinceCampaignStarted();
         if(index >= 0 && (index <= daysSinceCampaignStarted || m_unlockedIndices[index] != null || HolidayCountdownManager.hasAcquiredAllItems()))
         {
            TransactionManager.addTransaction(new THolidayCountdownBuyItem(index,HolidayCountdownManager.getItemPackageByIndex(index)),true);
            finishProgressForFirstReward(index);
            recalculateHasAllItems();
         }
      }
      
      public static function unlockIndex(index:int) : void
      {
         TransactionManager.addTransaction(new THolidayCountdownUnlockItem(index),true);
         m_unlockedIndices[index] = true;
         m_unlockedTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      public static function isIndexUnlocked(index:int) : Boolean
      {
         return m_unlockedIndices[index] != null;
      }
      
      public static function bonusItemCost() : String
      {
         var result:String = null;
         if(m_config["bonusPrizeItemCost"])
         {
            result = m_config["bonusPrizeItemCost"];
         }
         return result;
      }
      
      public static function getBonusItem() : FarmItem
      {
         var result:FarmItem = null;
         if(m_config["bonusPrizeItem"])
         {
            result = Global.farmGameSettingsManager.getFarmItemByName(m_config["bonusPrizeItem"]);
         }
         return result;
      }
      
      public static function buyBonusItem() : void
      {
         if(m_config["bonusPrizeItem"])
         {
            TransactionManager.addTransaction(new THolidayCountdownBuyItem(),true);
         }
      }
      
      public static function getFeatureName() : String
      {
         var featureName:String = DEFAULT_FEATURE_NAME;
         if(Boolean(m_config) && Boolean(m_config["featureName"]))
         {
            featureName = m_config["featureName"];
         }
         return featureName;
      }
      
      public static function getStatCounter() : String
      {
         return getFeatureName();
      }
      
      public static function interactedWithDialog() : void
      {
         if(m_trackBackoff)
         {
            m_trackBackoff = false;
            FarmStatsManager.count(HolidayCountdownManager.getStatCounter(),HolidayCountdownManager.STAT_IDLE_POP_SUBCOUNTER,"first_click");
         }
      }
      
      public static function showSeedPopup(seedName:String) : void
      {
         UI.displayPopup(new GenericPopup(ZLocUtils.t("HolidayCountdown","GetSeeds",{"crop":seedName})));
      }
      
      public static function shouldShowToaster() : FarmItem
      {
         var result:FarmItem = null;
         if((HolidayCountdownManager.getDaysLeftInCampaign() > 0 || HolidayCountdownManager.extraDaysLeft() != -1) && m_newReceivedItem != "")
         {
            result = Global.farmGameSettingsManager.getFarmItemByCode(m_newReceivedItem);
         }
         return result;
      }
      
      public static function shouldAutoPop() : Boolean
      {
         var i:int = 0;
         var itemsLeftToAskFor:Boolean = false;
         var result:Boolean = false;
         if(m_config)
         {
            for(i = 0; i <= m_config["duration"]; i++)
            {
               if(canPostItemOfTheDayReward(i))
               {
                  itemsLeftToAskFor = true;
                  break;
               }
            }
            result = m_config["shouldPopDuringIdleTime"] && m_config["shouldPopDuringIdleTime"] == "true" && itemsLeftToAskFor && Global.player.canShowFeatureWithBackoff(getFeatureName()) && Global.player.getFeatureLastShown(getFeatureName()) + FarmGameUtil.NUM_SECS_IN_DAY < GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND && !Global.worldManager.isVisiting();
         }
         return result;
      }
      
      public static function getFeatureSpecificKey(key:String) : String
      {
         var result:String = key;
         if(Boolean(m_config) && Boolean(m_config["featureName"]) && ZLocUtils.hasString(HolidayCountdownManager.DEFAULT_FEATURE_NAME,m_config["featureName"] + "_" + key))
         {
            result = m_config["featureName"] + "_" + key;
         }
         return result;
      }
      
      public static function displayAndTrackDialog() : void
      {
         if(m_config)
         {
            HolidayCountdownManager.displayDialog(true);
            FarmStatsManager.count(HolidayCountdownManager.getStatCounter(),HolidayCountdownManager.STAT_IDLE_POP_SUBCOUNTER,"impressions");
         }
      }
      
      public static function canRestartCountdown() : Boolean
      {
         var inExperiment:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_REPEATABLE_COUNTDOWN) == Experiments.VARIANT_FLASH_REPEATABLE_COUNTDOWN_ON;
         return inExperiment && m_config["maxReplays"] && restartCount() < m_config["maxReplays"] && hasAcquiredAllItems();
      }
      
      public static function isRepeatingCountdown() : Boolean
      {
         var inExperiment:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_REPEATABLE_COUNTDOWN) == Experiments.VARIANT_FLASH_REPEATABLE_COUNTDOWN_ON;
         return inExperiment && m_config["maxReplays"] && !hasAcquiredAllItems() && restartCount() > 0;
      }
      
      public static function restartCountdown() : void
      {
         var itemCode:String = null;
         if(canRestartCountdown())
         {
            TransactionManager.addTransaction(new TGenericTransaction("HolidayCountdownService","restartCountdown"),true);
            ++m_data["replayCount"];
            for each(itemCode in m_config["items"])
            {
               m_data[itemCode] = [];
            }
            acquiredAllItems = false;
            refreshDialog();
            FarmStatsManager.count(HolidayCountdownManager.getStatCounter(),HolidayCountdownManager.STAT_COMPLETED_DIALOG_SUBCOUNTER,"keep_going","ok_button","clicks");
         }
      }
      
      public static function restartCount() : int
      {
         return m_data["replayCount"];
      }
      
      public static function unlockAllIndices() : void
      {
         for(var i:int = 0; i < m_config["items"].length; i++)
         {
            m_unlockedIndices[i] = true;
         }
      }
   }
}

