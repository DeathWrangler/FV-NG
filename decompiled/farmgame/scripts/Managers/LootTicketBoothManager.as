package Managers
{
   import Classes.FeatureDataObjects.LootTicketBoothFeatureConfig;
   import Classes.FeatureDataObjects.LootTicketBoothStageConfig;
   import Classes.ZItem.FarmItem;
   import Classes.consumables.CLootTicket;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Transactions.TRefreshGifts;
   import Widgets.Windows.Generic.GenericItemWithShareCheckboxWindow;
   import Widgets.Windows.Generic.GenericItemWithShareCheckboxWindowParams;
   import Widgets.Windows.LootTicketBooth.LootTicketBoothWindow;
   
   public class LootTicketBoothManager
   {
      
      private static var m_currentContentsWindow:LootTicketBoothWindow;
      
      public static const SERVICE_NAME:String = "LootTicketBoothService";
      
      public static const KEY_FEATURE_NAME:String = "featureName";
      
      public static const KEY_STAGE_NAME:String = "stageName";
      
      public static const KEY_LOOT_TABLES:String = "lootTables";
      
      public static const KEY_LOOT_ITEM:String = "lootItem";
      
      public static const KEY_LOOT_QUANTITY:String = "lootQuantity";
      
      public static const KEY_REWARD_ITEM:String = "rewardItem";
      
      public static const KEY_REWARD_LINK:String = "rewardLink";
      
      private static var m_featureConfigs:Object = {};
      
      private static var m_gameSettings:Object = {};
      
      public function LootTicketBoothManager()
      {
         super();
      }
      
      public static function get currentContentsWindow() : LootTicketBoothWindow
      {
         return m_currentContentsWindow;
      }
      
      public static function set currentContentsWindow(value:LootTicketBoothWindow) : void
      {
         m_currentContentsWindow = value;
      }
      
      public static function getFeatureConfig(featureName:String) : LootTicketBoothFeatureConfig
      {
         var result:LootTicketBoothFeatureConfig = null;
         var featureXML:XML = null;
         if(m_featureConfigs[featureName])
         {
            result = m_featureConfigs[featureName] as LootTicketBoothFeatureConfig;
         }
         else
         {
            featureXML = Global.farmGameSettingsManager.getFeatureXML(featureName);
            if(featureXML)
            {
               result = new LootTicketBoothFeatureConfig(featureXML);
               m_featureConfigs[featureName] = result;
            }
         }
         return result;
      }
      
      public static function getStages(featureName:String, checkPrereqs:Boolean = true) : Array
      {
         var result:Array = null;
         var featureConfig:LootTicketBoothFeatureConfig = getFeatureConfig(featureName);
         if(featureConfig)
         {
            result = featureConfig.getStages(checkPrereqs);
         }
         return result;
      }
      
      public static function getStage(featureName:String, stageName:String) : LootTicketBoothStageConfig
      {
         var result:LootTicketBoothStageConfig = null;
         var featureConfig:LootTicketBoothFeatureConfig = getFeatureConfig(featureName);
         if(featureConfig)
         {
            result = featureConfig.getStageByName(stageName);
         }
         return result;
      }
      
      public static function getNextStage(featureName:String, stageName:String) : LootTicketBoothStageConfig
      {
         var result:LootTicketBoothStageConfig = null;
         var stageIndex:int = 0;
         var stage:LootTicketBoothStageConfig = null;
         var nextStageIndex:int = 0;
         var stages:Array = getStages(featureName);
         if(stages)
         {
            for(stageIndex = 0; stageIndex < stages.length; stageIndex++)
            {
               stage = stages[stageIndex] as LootTicketBoothStageConfig;
               if(stage.name == stageName)
               {
                  nextStageIndex = stageIndex + 1;
                  if(stages.length > nextStageIndex)
                  {
                     result = stages[nextStageIndex];
                  }
                  break;
               }
            }
         }
         return result;
      }
      
      public static function getGameSettings(featureName:String) : Object
      {
         var result:Object = null;
         var firstTimePlaceSeenFlag:String = null;
         if(m_gameSettings[featureName])
         {
            result = m_gameSettings[featureName];
         }
         else
         {
            firstTimePlaceSeenFlag = featureName + "_FirstTimePlace";
            if(!Global.player.getSeenFlag(firstTimePlaceSeenFlag))
            {
               TransactionManager.addTransaction(new TRefreshGifts());
            }
            sendGetGameSettingsTransaction(featureName);
         }
         return result;
      }
      
      private static function sendGetGameSettingsTransaction(featureName:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getGameSettings",sendGetGameSettingsTransactionCallback,[featureName]),true);
      }
      
      private static function sendGetGameSettingsTransactionCallback(result:Object) : void
      {
         var resultFeatureName:String = null;
         if(Boolean(result) && Boolean(result[KEY_FEATURE_NAME]))
         {
            resultFeatureName = result[KEY_FEATURE_NAME];
            m_gameSettings[resultFeatureName] = result;
            if(Boolean(m_currentContentsWindow) && m_currentContentsWindow.featureName == resultFeatureName)
            {
               m_currentContentsWindow.gameSettings = result;
            }
         }
      }
      
      public static function getStageTitle(featureName:String, stageName:String) : String
      {
         return ZLocUtils.t("Dialogs",featureName + "_" + stageName + "_Title");
      }
      
      private static function getStageUnlockedFeatureOptionName(stageName:String) : String
      {
         return stageName + "_unlocked";
      }
      
      public static function isStageUnlocked(featureName:String, stageName:String) : Boolean
      {
         var result:Boolean = false;
         var partItemName:String = null;
         var partItemNeeded:int = 0;
         var optionName:String = null;
         var stageConfig:LootTicketBoothStageConfig = getStage(featureName,stageName);
         if(stageConfig)
         {
            partItemName = stageConfig.partItemName;
            partItemNeeded = stageConfig.partItemNeeded as int;
            if(Boolean(partItemName) && partItemNeeded > 0)
            {
               optionName = getStageUnlockedFeatureOptionName(stageName);
               result = FeatureOptionsManager.getInstance().getFeatureOption(featureName,optionName) as Boolean;
            }
            else
            {
               result = true;
            }
         }
         return result;
      }
      
      public static function setStageUnlocked(featureName:String, stageName:String) : void
      {
         var optionName:String = null;
         var stageConfig:LootTicketBoothStageConfig = getStage(featureName,stageName);
         if(stageConfig)
         {
            Global.player.removeGiftWithKey(Global.farmGameSettingsManager.getFarmItemCodeByName(stageConfig.partItemName),stageConfig.partItemNeeded);
            optionName = getStageUnlockedFeatureOptionName(stageName);
            FeatureOptionsManager.getInstance().setFeatureOption(featureName,optionName,true);
            sendUnlockStageTransaction(featureName,stageName);
         }
      }
      
      public static function getLastStageUnlocked(featureName:String) : LootTicketBoothStageConfig
      {
         var result:LootTicketBoothStageConfig = null;
         var stages:Array = null;
         var stageConfig:LootTicketBoothStageConfig = null;
         var featureConfig:LootTicketBoothFeatureConfig = getFeatureConfig(featureName);
         if(featureConfig)
         {
            stages = featureConfig.getStages();
            if(stages)
            {
               for each(stageConfig in stages)
               {
                  if(LootTicketBoothManager.isStageUnlocked(featureName,stageConfig.name))
                  {
                     result = stageConfig;
                  }
               }
            }
         }
         return result;
      }
      
      private static function sendUnlockStageTransaction(featureName:String, stageName:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"unlockStage",sendUnlockStageTransactionCallback,[featureName,stageName]),true);
      }
      
      private static function sendUnlockStageTransactionCallback(result:Object) : void
      {
         if(Boolean(result) && Boolean(result[KEY_FEATURE_NAME]))
         {
            showUnlockStageResultWindow(result);
         }
      }
      
      private static function showUnlockStageResultWindow(result:Object) : void
      {
         var params:GenericItemWithShareCheckboxWindowParams = null;
         var featureConfig:LootTicketBoothFeatureConfig = null;
         var stageTitle:String = null;
         var stageConfig:LootTicketBoothStageConfig = null;
         var ticketItemName:String = null;
         var rewardLink:String = null;
         var rewardItem:FarmItem = null;
         var bundleData:Object = null;
         var resultFeatureName:String = result[KEY_FEATURE_NAME];
         var resultStageName:String = result[KEY_STAGE_NAME];
         if(Boolean(resultFeatureName) && Boolean(resultStageName))
         {
            params = new GenericItemWithShareCheckboxWindowParams();
            featureConfig = getFeatureConfig(resultFeatureName);
            if(featureConfig)
            {
               params.dialogAssetUrl = featureConfig.resultDialogUrl;
            }
            params.titleText = ZLocUtils.t("Dialogs","LootTicketBooth_UnlockStageResultDialog_Title");
            params.shareText = ZLocUtils.t("Dialogs","LootTicketBooth_UnlockStageResultDialog_Share");
            params.buttonText = ZLocUtils.t("Dialogs","LootTicketBooth_UnlockStageResultDialog_Accept");
            stageTitle = getStageTitle(resultFeatureName,resultStageName);
            params.itemText = ZLocUtils.t("Dialogs","LootTicketBooth_UnlockStageResultDialog_Item",{"stage":stageTitle});
            stageConfig = getStage(resultFeatureName,resultStageName);
            ticketItemName = stageConfig.ticketItemName;
            params.item = Global.farmGameSettingsManager.getFarmItemByName(ticketItemName);
            if(Boolean(result[KEY_REWARD_ITEM]) && Boolean(result[KEY_REWARD_LINK]))
            {
               rewardLink = result[KEY_REWARD_LINK];
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(result[KEY_REWARD_ITEM]);
               if(rewardItem)
               {
                  bundleData = {};
                  bundleData["reward_link"] = rewardLink;
                  bundleData["images"] = [{
                     "href":"{SN_APP_URL}" + rewardLink,
                     "src":rewardItem.iconUrl
                  }];
                  bundleData["creative"] = resultFeatureName;
                  bundleData["stageName"] = stageTitle;
                  bundleData["rewardItemName"] = rewardItem.friendlyTitle;
                  params.feedAction = resultFeatureName + "_UnlockStageReward";
                  params.feedBundleData = bundleData;
               }
            }
            UI.displayPopup(new GenericItemWithShareCheckboxWindow(params),false);
         }
      }
      
      private static function getStageItemsWonFeatureOptionName(stageName:String) : String
      {
         return stageName + "_itemsWon";
      }
      
      public static function getStageItemWon(featureName:String, stageName:String, itemName:String) : int
      {
         var result:int = 0;
         var optionName:String = getStageItemsWonFeatureOptionName(stageName);
         var itemsWon:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureName,optionName) as Object;
         if(Boolean(itemsWon) && Boolean(itemsWon.hasOwnProperty(itemName)) && itemsWon[itemName] as int >= 0)
         {
            result = itemsWon[itemName] as int;
         }
         return result;
      }
      
      public static function incrementStageItemWon(featureName:String, stageName:String, itemName:String) : void
      {
         var optionName:String = getStageItemsWonFeatureOptionName(stageName);
         var itemsWon:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureName,optionName) as Object;
         if(!itemsWon)
         {
            itemsWon = {};
         }
         if(itemsWon.hasOwnProperty(itemName) && itemsWon[itemName] as int >= 0)
         {
            ++itemsWon[itemName];
         }
         else
         {
            itemsWon[itemName] = 1;
         }
         FeatureOptionsManager.getInstance().setFeatureOption(featureName,optionName,itemsWon);
      }
      
      public static function redeemTickets(featureName:String, stageName:String) : void
      {
         var stageConfig:LootTicketBoothStageConfig = getStage(featureName,stageName);
         if(stageConfig)
         {
            Global.player.removeGiftWithKey(Global.farmGameSettingsManager.getFarmItemCodeByName(stageConfig.ticketItemName),stageConfig.ticketItemNeeded);
            sendRedeemTicketsTransaction(featureName,stageName);
         }
      }
      
      private static function sendRedeemTicketsTransaction(featureName:String, stageName:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemTickets",sendRedeemTicketsTransactionCallback,[featureName,stageName]),true);
      }
      
      private static function sendRedeemTicketsTransactionCallback(result:Object) : void
      {
         var lootItemName:String = null;
         var lootQuantity:int = 0;
         var resultFeatureName:String = result[KEY_FEATURE_NAME];
         var resultStageName:String = result[KEY_STAGE_NAME];
         if(Boolean(result) && Boolean(resultFeatureName) && Boolean(resultStageName))
         {
            lootItemName = result[KEY_LOOT_ITEM] as String;
            lootQuantity = int(result[KEY_LOOT_QUANTITY]);
            incrementStageItemWon(resultFeatureName,resultStageName,lootItemName);
            Global.player.addGift(lootItemName,"0",lootQuantity);
            if(Boolean(m_currentContentsWindow) && m_currentContentsWindow.featureName == resultFeatureName)
            {
               m_currentContentsWindow.handleRedemptionResult(result);
            }
            showRedeemTicketsResultWindow(result);
         }
      }
      
      private static function showRedeemTicketsResultWindow(result:Object) : void
      {
         var params:GenericItemWithShareCheckboxWindowParams = null;
         var featureConfig:LootTicketBoothFeatureConfig = null;
         var itemName:String = null;
         var item:FarmItem = null;
         var infoText:String = null;
         var gameSettings:Object = null;
         var stageConfig:LootTicketBoothStageConfig = null;
         var rarity:String = null;
         var lootItems:Array = null;
         var lootItem:Object = null;
         var rarityText:String = null;
         var nextStage:LootTicketBoothStageConfig = null;
         var stageTitle:String = null;
         var rewardLink:String = null;
         var rewardItem:FarmItem = null;
         var bundleData:Object = null;
         var resultFeatureName:String = result[KEY_FEATURE_NAME];
         var resultStageName:String = result[KEY_STAGE_NAME];
         if(Boolean(resultFeatureName) && Boolean(resultStageName))
         {
            params = new GenericItemWithShareCheckboxWindowParams();
            featureConfig = LootTicketBoothManager.getFeatureConfig(resultFeatureName);
            if(featureConfig)
            {
               params.dialogAssetUrl = featureConfig.resultDialogUrl;
            }
            if(Boolean(m_currentContentsWindow) && m_currentContentsWindow.featureName == resultFeatureName)
            {
               params.closeCallback = m_currentContentsWindow.onRedeemTicketsResultWindowClose;
            }
            params.titleText = ZLocUtils.t("Dialogs","LootTicketBooth_RedeemTicketsResultDialog_Title");
            params.shareText = ZLocUtils.t("Dialogs","LootTicketBooth_RedeemTicketsResultDialog_Share");
            params.buttonText = ZLocUtils.t("Dialogs","LootTicketBooth_RedeemTicketsResultDialog_Accept");
            itemName = result[LootTicketBoothManager.KEY_LOOT_ITEM] as String;
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(item)
            {
               params.item = item;
               gameSettings = LootTicketBoothManager.getGameSettings(resultFeatureName);
               stageConfig = LootTicketBoothManager.getStage(resultFeatureName,resultStageName);
               lootItems = gameSettings[LootTicketBoothManager.KEY_LOOT_TABLES][stageConfig.lootTableName] as Array;
               for each(lootItem in lootItems)
               {
                  if(lootItem["itemName"] == itemName)
                  {
                     rarity = lootItem.rare;
                     break;
                  }
               }
               rarityText = ZLocUtils.t("Dialogs","LootTicketBoothRarity_" + rarity);
               params.itemText = ZLocUtils.t("Dialogs","LootTicketBooth_RedeemTicketsResultDialog_Item",{
                  "item":item.friendlyTitle,
                  "rarity":rarityText
               });
            }
            if(item.className == "CSeedPackage")
            {
               infoText = ZLocUtils.t("Dialogs","LootTicketBooth_RedeemTicketsResultDialog_SeedMessage");
            }
            else if(item.className == CLootTicket.CLASS_NAME)
            {
               nextStage = LootTicketBoothManager.getNextStage(resultFeatureName,resultStageName);
               if(nextStage)
               {
                  stageTitle = LootTicketBoothManager.getStageTitle(resultFeatureName,nextStage.name);
                  infoText = ZLocUtils.t("Dialogs","LootTicketBooth_RedeemTicketsResultDialog_PartMessage",{
                     "stage":stageTitle,
                     "total":nextStage.partItemNeeded
                  });
               }
            }
            params.infoText = infoText;
            if(Boolean(result[KEY_REWARD_ITEM]) && Boolean(result[KEY_REWARD_LINK]))
            {
               rewardLink = result[KEY_REWARD_LINK];
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(result[KEY_REWARD_ITEM]);
               if(rewardItem)
               {
                  bundleData = {};
                  bundleData["reward_link"] = rewardLink;
                  bundleData["images"] = [{
                     "href":"{SN_APP_URL}" + rewardLink,
                     "src":rewardItem.iconUrl
                  }];
                  bundleData["creative"] = resultFeatureName;
                  bundleData["lootItemName"] = item.friendlyTitle;
                  bundleData["rewardItemName"] = rewardItem.friendlyTitle;
                  params.feedAction = resultFeatureName + "_RedeemTicketsReward";
                  params.feedBundleData = bundleData;
               }
            }
            UI.displayPopup(new GenericItemWithShareCheckboxWindow(params),false);
         }
      }
   }
}

