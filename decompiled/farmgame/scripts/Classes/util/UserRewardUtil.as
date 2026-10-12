package Classes.util
{
   import Classes.Avatar.AvatarItem;
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.WorldLicenseRequirement;
   import Classes.ZItem.CurrencyData;
   import Classes.ZItem.FarmItem;
   import DataSources.BaseDataSource;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import GameMode.GMSetAltGraphic;
   import Managers.Crafting.CraftingManager;
   import Managers.EvolutionManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.IrrigationManager;
   import Managers.LicenseManager;
   import Managers.MapTriggerManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.PrizeMachine.PrizeMachineWindow;
   import Widgets.Windows.ScratchCardWindow;
   import flash.display.DisplayObject;
   import flash.utils.getQualifiedClassName;
   
   public class UserRewardUtil
   {
      
      public function UserRewardUtil()
      {
         super();
      }
      
      public static function getImageForReward(reward:Object) : String
      {
         var item:FarmItem = null;
         var avatarItem:AvatarItem = null;
         var result:String = "";
         if(reward != null)
         {
            switch(reward.type)
            {
               case QuestConstants.REWARD_XP:
                  result = "assets/decorations/fv_xp_icon.png";
                  break;
               case QuestConstants.REWARD_COINS:
                  result = Currency.getIcon(Currency.COINS);
                  break;
               case QuestConstants.REWARD_CASH:
                  result = Currency.getIcon(Currency.CASH);
                  break;
               case QuestConstants.REWARD_WORLD_CURRENCY:
                  result = Currency.getIcon(reward.unit);
                  break;
               case QuestConstants.REWARD_GRANT_BUSHEL_ITEM:
               case QuestConstants.REWARD_GRANT_BREEDING_ITEM:
               case QuestConstants.REWARD_GRANT_ITEM:
                  item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                  if(item != null)
                  {
                     result = item.icon;
                  }
                  break;
               case QuestConstants.REWARD_UNLOCK_ITEM:
                  break;
               case QuestConstants.REWARD_ALT_GRAPHIC_UNLOCK:
                  result = "assets/decorations/deco_infinitelights_icon.png";
                  break;
               case QuestConstants.REWARD_DISPLAY_ICON:
                  result = reward.value;
                  break;
               case QuestConstants.REWARD_UNLOCK_WORLD:
                  result = "assets/decorations/fv_Eng_shield_100.png";
                  break;
               case QuestConstants.REWARD_AVATAR_ITEM:
                  avatarItem = Global.avatarConfigSettings.getItemById(reward.value);
                  if(avatarItem != null)
                  {
                     result = avatarItem.iconPath;
                  }
                  break;
               case QuestConstants.REWARD_LICENSE:
                  item = Global.farmGameSettingsManager.getFarmItemByCode(reward.item);
                  if(item != null)
                  {
                     result = item.icon;
                  }
                  break;
               case QuestConstants.REWARD_WORLD_SCORE:
                  result = Global.worldScoreSettingsManager.getIconForScoreUnit(reward.unit);
            }
         }
         return result;
      }
      
      public static function getValueForReward(reward:Object) : String
      {
         var quantity:int = 0;
         var currencyData:CurrencyData = null;
         var inflowTuning:Number = NaN;
         var avatarItem:AvatarItem = null;
         var experimentVariant:Number = NaN;
         var result:String = "";
         if(reward != null)
         {
            switch(reward.type)
            {
               case QuestConstants.REWARD_CASH:
               case QuestConstants.REWARD_XP:
               case QuestConstants.REWARD_COINS:
               case QuestConstants.REWARD_WORLD_SCORE:
                  result = Utilities.formatNumber(parseInt(reward.value));
                  break;
               case QuestConstants.REWARD_WORLD_CURRENCY:
                  quantity = parseInt(reward.value);
                  currencyData = Global.farmGameSettingsManager.getCurrencyData(reward.unit);
                  inflowTuning = 1;
                  if(currencyData != null)
                  {
                     experimentVariant = currencyData.getDisplayVariant();
                     inflowTuning = currencyData.getInflowTuningMultiplierByVariant(experimentVariant);
                  }
                  result = Utilities.formatNumber(Math.floor(quantity * inflowTuning));
                  break;
               case QuestConstants.REWARD_GRANT_BUSHEL_ITEM:
               case QuestConstants.REWARD_GRANT_BREEDING_ITEM:
               case QuestConstants.REWARD_GRANT_ITEM:
                  result = reward.quantity != null ? ZLocUtils.t("Quests","RewardMultiplier",{"quantity":reward.quantity}) : "";
                  break;
               case QuestConstants.REWARD_UNLOCK_ITEM:
                  break;
               case QuestConstants.REWARD_ALT_GRAPHIC_UNLOCK:
                  result = ZLocUtils.tk_pk_asTitle("Items:" + reward.value + "_friendlyName");
                  break;
               case QuestConstants.REWARD_UNLOCK_WORLD:
                  result = Global.worldManager.getWorldFriendlyName(reward.value);
                  break;
               case QuestConstants.REWARD_AVATAR_ITEM:
                  avatarItem = Global.avatarConfigSettings.getItemById(reward.value);
                  if(avatarItem != null)
                  {
                     result = ZLocUtils.tk_pk_asTitle(avatarItem.friendlyName);
                  }
            }
         }
         return result;
      }
      
      public static function getRewardsVectorFromObject(rewardsObj:Object) : Vector.<Object>
      {
         var rewardsList:Array = null;
         var rewardData:Object = null;
         var rewardsData:Object = null;
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(rewardsObj != null)
         {
            if(getQualifiedClassName(rewardsObj["reward"]) == "Array")
            {
               rewardsList = rewardsObj["reward"];
               if(rewardsList)
               {
                  for each(rewardData in rewardsList)
                  {
                     rewards.push(rewardData);
                  }
               }
            }
            else
            {
               rewardsData = rewardsObj["reward"];
               rewards.push(rewardsData);
            }
         }
         return rewards;
      }
      
      public static function getRewardsVectorFromXml(xml:XML) : Vector.<Object>
      {
         var xmlRewards:XMLList = null;
         var rewardNode:XML = null;
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(xml != null)
         {
            xmlRewards = xml.descendants("reward");
            if(xmlRewards)
            {
               for each(rewardNode in xmlRewards)
               {
                  rewards.push(FarmGameUtil.xmlNodeToAttributes(rewardNode));
               }
            }
         }
         return rewards;
      }
      
      public static function getRewardsVectorFromDataSource(dataSource:BaseDataSource) : Vector.<Object>
      {
         var rewardDataArray:Array = null;
         var rewardData:BaseDataSource = null;
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(dataSource != null)
         {
            rewardDataArray = dataSource.getArray("reward");
            if(rewardDataArray.length > 0)
            {
               for each(rewardData in rewardDataArray)
               {
                  rewards.push(rewardData.getAttributesHash());
               }
            }
         }
         return rewards;
      }
      
      public static function grantUserRewardsFromObject(rewardsData:Object, multiplier:int = 1, context:Object = null) : void
      {
         var rewards:Vector.<Object> = UserRewardUtil.getRewardsVectorFromObject(rewardsData);
         grantUserRewards(rewards,false,multiplier,context);
      }
      
      public static function grantUserRewardsFromXml(xml:XML, multiplier:int = 1, context:Object = null) : void
      {
         var rewards:Vector.<Object> = UserRewardUtil.getRewardsVectorFromXml(xml);
         grantUserRewards(rewards,false,multiplier,context);
      }
      
      public static function grantUserRewardsFromDataSource(dataSource:BaseDataSource, multiplier:int = 1, context:Object = null) : void
      {
         var rewards:Vector.<Object> = UserRewardUtil.getRewardsVectorFromDataSource(dataSource);
         grantUserRewards(rewards,false,multiplier,context);
      }
      
      public static function grantUserRewardsFromArray(rewards:Array, attemptForcePlacementMode:Boolean = false, context:Object = null) : void
      {
         var reward:Object = null;
         for each(reward in rewards)
         {
            attemptForcePlacementMode = grantUserReward(reward,attemptForcePlacementMode,1,context);
         }
      }
      
      public static function grantUserRewards(rewards:Vector.<Object>, attemptForcePlacementMode:Boolean = false, multiplier:int = 1, context:Object = null) : void
      {
         var reward:Object = null;
         if(rewards != null)
         {
            for each(reward in rewards)
            {
               attemptForcePlacementMode = grantUserReward(reward,attemptForcePlacementMode,multiplier,context);
            }
         }
      }
      
      public static function grantSeasonRewards(rewards:Vector.<Object>, seasonId:int) : void
      {
         var reward:Object = null;
         if(rewards != null)
         {
            for each(reward in rewards)
            {
               if(reward.season == seasonId)
               {
                  grantUserReward(reward);
               }
            }
         }
      }
      
      public static function grantUserReward(reward:Object, attemptForcePlacementMode:Boolean = false, multiplier:int = 1, context:Object = null) : Boolean
      {
         var quantity:Number = NaN;
         var rewardWithBonus:int = 0;
         var xpValue:int = 0;
         var xpToGrant:int = 0;
         var prizeMachineOption:Object = null;
         var freeSpins:int = 0;
         var licenseType:String = null;
         var currentPopup:DisplayObject = null;
         var dt:Date = null;
         var time:Number = NaN;
         var giveawayFOptions:Object = null;
         var newValue:int = 0;
         var currencyData:CurrencyData = null;
         var inflowTuning:Number = NaN;
         var experimentVariant:Number = NaN;
         var oldXP:int = 0;
         var xpDelta:int = 0;
         var currLevel:int = 0;
         var currWorldScore:int = 0;
         var worldScoreNeeded:int = 0;
         var worldScoreToGrant:int = 0;
         var mutableState:String = null;
         var beginOOS_itemsStr:String = null;
         var items:Array = null;
         var worldItem:MapResource = null;
         var partsNeeded:Object = null;
         var partCodes:Array = null;
         var partCode:String = null;
         var currPartCode:String = null;
         var newPart:MapResource = null;
         var newData:int = 0;
         var item:FarmItem = null;
         quantity = 0;
         switch(reward.type)
         {
            case QuestConstants.REWARD_COINS:
               Global.player.updateWorldCurrency(Currency.GOLD,parseInt(reward.value) * multiplier,true);
               break;
            case QuestConstants.REWARD_CASH:
            case QuestConstants.REWARD_CASH_FROM_SCRATCH_CARD:
            case QuestConstants.REWARD_CASH_FROM_PRIZE_MACHINE:
               Global.player.cash += parseInt(reward.value) * multiplier;
               break;
            case QuestConstants.REWARD_WORLD_CURRENCY:
               if(Boolean(reward["unit"]) && Boolean(reward["value"]) && Boolean(reward.value.toString().match(/^\d+$/)))
               {
                  currencyData = Global.farmGameSettingsManager.getCurrencyData(reward.unit);
                  inflowTuning = 1;
                  if(currencyData != null)
                  {
                     experimentVariant = Global.experimentManager.getExperimentVariant(currencyData.getInflowTuningExperimentName());
                     inflowTuning = currencyData.getInflowTuningMultiplierByVariant(experimentVariant);
                  }
                  rewardWithBonus = parseInt(reward.value) * inflowTuning * multiplier;
                  Global.player.updateWorldCurrency(reward.unit as String,rewardWithBonus,true);
               }
               else
               {
                  errorInvalidReward(reward);
               }
               break;
            case QuestConstants.REWARD_UNLOCK_WORLD_CURRENCY:
               if(Boolean(reward["unit"]) && Boolean(reward["value"]) && Boolean(reward.value.toString().match(/^\d+$/)))
               {
                  Global.player.resetWorldCurrency(reward.unit as String);
                  currencyData = Global.farmGameSettingsManager.getCurrencyData(reward.unit);
                  inflowTuning = 1;
                  if(currencyData != null)
                  {
                     experimentVariant = Global.experimentManager.getExperimentVariant(currencyData.getInflowTuningExperimentName());
                     inflowTuning = currencyData.getInflowTuningMultiplierByVariant(experimentVariant);
                  }
                  rewardWithBonus = parseInt(reward.value) * inflowTuning * multiplier;
                  Global.player.updateWorldCurrency(reward.unit as String,rewardWithBonus,true);
               }
               else
               {
                  errorInvalidReward(reward);
               }
               break;
            case QuestConstants.REWARD_WORLD_SCORE:
               if(reward.hasOwnProperty("unit") && reward.hasOwnProperty("value"))
               {
                  Global.player.addWorldScore(reward["unit"],parseInt(reward["value"]) * multiplier,true);
               }
               else
               {
                  errorInvalidReward(reward);
               }
               break;
            case QuestConstants.REWARD_UNLOCK_WORLD_SCORE:
               if(reward.hasOwnProperty("unit") && reward.hasOwnProperty("value"))
               {
                  Global.player.resetWorldScore(reward["unit"]);
                  Global.player.addWorldScore(reward["unit"],parseInt(reward["value"]) * multiplier,true);
               }
               else
               {
                  errorInvalidReward(reward);
               }
               break;
            case QuestConstants.REWARD_XP:
               xpValue = parseInt(reward.value) * multiplier;
               if(xpValue > 0)
               {
                  oldXP = Global.player.xp;
                  Global.player.xp += xpValue;
                  xpDelta = Global.player.xp - oldXP;
                  if(xpDelta > 0)
                  {
                     Global.player.avatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestXP",{"xpNum":xpDelta}));
                  }
               }
               break;
            case QuestConstants.REWARD_LEVEL_UP:
               quantity = reward.quantity != null ? parseInt(reward.quantity) : 1;
               xpToGrant = Global.farmGameSettingsManager.getXPForLevel(Global.player.level + quantity) - Global.player.xp;
               Global.player.xp += xpToGrant;
               break;
            case QuestConstants.REWARD_WORLD_LEVEL_UP:
               if(reward.hasOwnProperty("unit"))
               {
                  quantity = reward.quantity != null ? parseInt(reward.quantity) : 1;
                  currLevel = Global.player.getWorldLevel(reward.unit);
                  currWorldScore = Global.player.getWorldScore(reward.unit);
                  worldScoreNeeded = Global.worldScoreSettingsManager.getRequiredScoreForLevel(reward.unit,currLevel + quantity);
                  worldScoreToGrant = Math.max(0,worldScoreNeeded - currWorldScore);
                  Global.player.addWorldScore(reward.unit,worldScoreToGrant,false);
               }
               else
               {
                  errorInvalidReward(reward);
               }
               break;
            case QuestConstants.REWARD_GRANT_EVOLUTIONFOOD:
               item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
               EvolutionManager.instance.addFeedItemToFeatureData(item.name);
               break;
            case QuestConstants.REWARD_GRANT_TIERED_QUEST_ITEM:
            case QuestConstants.REWARD_GRANT_ITEM:
               item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
               if(item != null)
               {
                  quantity = reward.quantity != null ? parseInt(reward.quantity) : 1;
                  quantity *= multiplier;
                  Global.player.addGift(item.name,"0",quantity);
                  if(attemptForcePlacementMode)
                  {
                     Global.world.enterForcePlaceMode(item.name);
                     attemptForcePlacementMode = false;
                  }
               }
               else
               {
                  errorInvalidReward("item \'" + reward.value + "\' not found.");
               }
               break;
            case QuestConstants.REWARD_GRANT_BREEDING_ITEM:
               item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
               if(item != null)
               {
                  quantity = reward.quantity != null ? parseInt(reward.quantity) : 1;
                  mutableState = Global.animalBreedingSettings.getVariantJSONByItemName(item.name,item.name);
                  Global.player.addMutableItemToGiftbox(reward.value,mutableState,quantity);
               }
               else
               {
                  errorInvalidReward("item \'" + reward.value + "\' not found.");
               }
               break;
            case QuestConstants.REWARD_GRANT_BUSHEL_ITEM:
               quantity = reward.quantity != null ? parseInt(reward.quantity) : 1;
               CraftingManager.getInstance().addItemToInventory(reward.value,quantity);
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
               {
                  beginOOS_itemsStr = "item_" + reward.value + ":" + quantity;
                  FarmStatsManager.count("beginOOS","client","add_UserRewardUtil",beginOOS_itemsStr);
               }
               break;
            case QuestConstants.REWARD_UNLOCK_ITEM:
               break;
            case QuestConstants.REWARD_PRIZE_MACHINE_CHIP:
               prizeMachineOption = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.PRIZE_MACHINE,FeatureOptionsManager.PRIZE_MACHINE);
               if(prizeMachineOption != null && prizeMachineOption.hasOwnProperty("collection_chip"))
               {
                  ++prizeMachineOption["collection_chip"];
                  FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.PRIZE_MACHINE,FeatureOptionsManager.PRIZE_MACHINE,prizeMachineOption);
               }
               else
               {
                  prizeMachineOption = {
                     "collection_chip":1,
                     "start_time":GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND
                  };
                  FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.PRIZE_MACHINE,FeatureOptionsManager.PRIZE_MACHINE,prizeMachineOption);
               }
               break;
            case QuestConstants.REWARD_PRIZE_MACHINE_FREE_SPIN:
               quantity = reward.quantity != null ? parseInt(reward.quantity) : 1;
               freeSpins = Global.player.getActionCount(PrizeMachineWindow.PRIZE_MACHINE_FREE_SPIN);
               Global.player.setActionCount(PrizeMachineWindow.PRIZE_MACHINE_FREE_SPIN,freeSpins + quantity);
               break;
            case QuestConstants.REWARD_ALT_GRAPHIC_UNLOCK:
               Global.player.setUnlimitedAltGraphicsCredits(reward.value,true);
               Global.world.addGameMode(new GMSetAltGraphic(reward.value));
               break;
            case QuestConstants.REWARD_UNLOCK_WORLD_CONTENT_LICENSE:
               licenseType = WorldLicenseRequirement.DEFAULT_WORLD_LICENSE_TYPE;
               if(reward.licenseType != null)
               {
                  licenseType = reward.licenseType;
                  Global.worldManager.addWorldContentLicense(reward.value,licenseType);
               }
               else
               {
                  errorInvalidReward("license \'" + reward.licenseType + "\' not found.");
               }
               break;
            case QuestConstants.REWARD_UNLOCK_WORLD:
               UserRewardUtil.doUnlockWorldReward(reward.value);
               break;
            case QuestConstants.REWARD_AVATAR_ITEM:
               Global.player.avatarState.grantItem(reward.value);
               break;
            case QuestConstants.REWARD_SET_ALT_GRAPHIC_STATE:
               item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
               if(item != null)
               {
                  items = Global.world.getObjectsByName(item.name);
                  for each(worldItem in items)
                  {
                     worldItem.useAltGraphic(reward.state);
                     worldItem.reloadImage();
                  }
               }
               else
               {
                  errorInvalidReward("item \'" + reward.value + "\' not found.");
               }
               break;
            case QuestConstants.REWARD_SCRATCH_CARD:
               currentPopup = UI.getCurrentPopup();
               if(currentPopup != null && currentPopup is ScratchCardWindow)
               {
                  (currentPopup as ScratchCardWindow).grantFreeCard();
               }
               break;
            case QuestConstants.REWARD_LICENSE:
               dt = new Date();
               time = (dt.getTime() + 10 * 365 * FarmGameUtil.NUM_MSECS_IN_DAY) / 1000;
               LicenseManager.getInstance().addLicense(reward.item,time);
               break;
            case QuestConstants.REWARD_SEEN_FLAG:
               Global.player.setSeenFlag(reward.value,false,true);
               break;
            case QuestConstants.REWARD_RESET_SEEN_FLAG:
               Global.player.resetSeenFlag(reward.value,false,true);
               break;
            case QuestConstants.REWARD_SET_PLOTS_GROWN:
               Global.world.growAllPlots();
               break;
            case QuestConstants.REWARD_ESCAPADE_ACCESS:
               TransactionManager.sendAllTransactions(true);
               MapTriggerManager.getInstance().createMapTriggers();
               break;
            case QuestConstants.REWARD_ACTION_COUNT_INCREMENT:
               Global.player.incrementActionCount(reward.value);
               break;
            case QuestConstants.REWARD_ADD_BUILDABLE_PART:
               if(context)
               {
                  if(context is StorageBuilding)
                  {
                     partsNeeded = (context as StorageBuilding).nextExpansionPartsNeeded();
                     partCodes = ObjectUtil.getObjectKeys(partsNeeded);
                     partCodes.sort();
                     partCode = null;
                     for each(currPartCode in partCodes)
                     {
                        if(partsNeeded[currPartCode] > 0)
                        {
                           partCode = currPartCode;
                           break;
                        }
                     }
                     if(partCode != null)
                     {
                        newPart = new MapResource(Global.farmGameSettingsManager.getFarmItemNameByCode(partCode));
                        (context as StorageBuilding).addExpansionPart(newPart);
                     }
                  }
               }
               break;
            case QuestConstants.REWARD_INC_FEATURE_OPTION:
               giveawayFOptions = FeatureOptionsManager.getInstance().getFeatureOption(reward.feature,reward.option);
               if(giveawayFOptions == null)
               {
                  giveawayFOptions = new Object();
               }
               newValue = parseInt(reward.quantity);
               if(giveawayFOptions.hasOwnProperty(reward.value))
               {
                  newValue += parseInt(giveawayFOptions[reward.value]);
               }
               giveawayFOptions[reward.value] = newValue;
               FeatureOptionsManager.getInstance().setFeatureOption(reward.feature,reward.option,giveawayFOptions);
               break;
            case QuestConstants.REWARD_SET_FEATURE_OPTION:
               if(reward.feature == "journal_notification")
               {
                  FeatureOptionsManager.getInstance().setFeatureOption(reward.feature,reward.option,reward.value);
               }
               else
               {
                  newData = parseInt(reward.value);
                  WorldSeasonsManager.getInstance().setSeasonForUser(reward.option,newData);
               }
               break;
            case QuestConstants.REWARD_IRRIGATION:
               if("actionType" in reward && "value" in reward)
               {
                  IrrigationManager.instance.addWater(reward.actionType,reward.value);
               }
         }
         return attemptForcePlacementMode;
      }
      
      public static function doUnlockWorldReward(worldName:String) : void
      {
         Global.worldManager.setWorldUnlocked(worldName);
      }
      
      private static function errorInvalidReward(reward:Object, msg:String = null) : void
      {
         if(Config.DEBUG_MODE)
         {
            if(msg == null || msg == "")
            {
               msg = ObjectUtil.objectToString(reward);
            }
            ErrorManager.addError("Invalid reward of type \'" + reward.type + "\', " + msg);
         }
      }
   }
}

