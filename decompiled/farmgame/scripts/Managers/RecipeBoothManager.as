package Managers
{
   import Classes.Constants.MFSConstants;
   import Classes.FeatureBuilding;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Transactions.TRefreshGifts;
   import Widgets.Windows.RecipeBooth.RecipeBoothResultWindow;
   import Widgets.Windows.RecipeBooth.RecipeBoothWindow;
   
   public class RecipeBoothManager
   {
      
      private static var m_currentContentsWindow:RecipeBoothWindow;
      
      public static const SERVICE_NAME:String = "RecipeBoothService";
      
      public static const KEY_FEATURE_NAME:String = "featureName";
      
      public static const KEY_BATCH_NAME:String = "batchName";
      
      public static const KEY_INGREDIENTS:String = "ingredients";
      
      public static const KEY_ITEM_NAME:String = "itemName";
      
      public static const KEY_MINIMUM:String = "minimum";
      
      public static const KEY_COUNT:String = "count";
      
      public static const KEY_LOOT_ITEMS:String = "lootItems";
      
      public static const KEY_LOOT_ITEM:String = "lootItem";
      
      public static const KEY_LOOT_QUANTITY:String = "lootQuantity";
      
      public static const KEY_REWARD_ITEM:String = "rewardItem";
      
      public static const KEY_REWARD_LINK:String = "rewardLink";
      
      private static const ACTION_READY_FEATURE_FREQUENCY_KEY:String = "LeaderboardActionReady";
      
      private static const ACTION_READY_FEATURE_FREQUENCY:String = "LeaderboardActionReadyFeatureFrequency";
      
      private static var m_gameSettings:Object = {};
      
      public function RecipeBoothManager()
      {
         super();
      }
      
      public static function get currentContentsWindow() : RecipeBoothWindow
      {
         return m_currentContentsWindow;
      }
      
      public static function set currentContentsWindow(value:RecipeBoothWindow) : void
      {
         m_currentContentsWindow = value;
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
      
      private static function getBatchItemsWonFeatureOptionName(batchName:String) : String
      {
         return batchName + "_itemsWon";
      }
      
      public static function getBatchItemWonCount(featureName:String, batchName:String, itemName:String) : int
      {
         var result:int = 0;
         var optionName:String = getBatchItemsWonFeatureOptionName(batchName);
         var itemsWon:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureName,optionName) as Object;
         if(Boolean(itemsWon) && Boolean(itemsWon.hasOwnProperty(itemName)) && itemsWon[itemName] as int >= 0)
         {
            result = itemsWon[itemName] as int;
         }
         return result;
      }
      
      public static function incrementBatchItemWonCount(featureName:String, batchName:String, itemName:String) : void
      {
         var optionName:String = getBatchItemsWonFeatureOptionName(batchName);
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
      
      public static function sendMakeRecipeTransaction(featureName:String, batchName:String, ingredientCounts:Object) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"makeRecipe",sendMakeRecipeTransactionCallback,[featureName,batchName,ingredientCounts]),true);
      }
      
      private static function sendMakeRecipeTransactionCallback(result:Object) : void
      {
         var resultFeatureName:String = null;
         var resultBatchName:String = null;
         var lootItemName:String = null;
         var lootQuantity:int = 0;
         if(result)
         {
            resultFeatureName = result[KEY_FEATURE_NAME];
            resultBatchName = result[KEY_BATCH_NAME];
            if(Boolean(result) && Boolean(resultFeatureName) && Boolean(resultBatchName))
            {
               lootItemName = result[KEY_LOOT_ITEM] as String;
               lootQuantity = int(result[KEY_LOOT_QUANTITY]);
               incrementBatchItemWonCount(resultFeatureName,resultBatchName,lootItemName);
               Global.player.addGift(lootItemName,"0",lootQuantity);
               if(Boolean(m_currentContentsWindow) && m_currentContentsWindow.featureName == resultFeatureName)
               {
                  m_currentContentsWindow.handleRedemptionResult(result);
               }
               showMakeRecipeResultWindow(result);
            }
         }
      }
      
      private static function showMakeRecipeResultWindow(result:Object) : void
      {
         var resultFeatureName:String = null;
         var resultBatchName:String = null;
         var closeCallback:Function = null;
         if(result)
         {
            resultFeatureName = result[KEY_FEATURE_NAME];
            resultBatchName = result[KEY_BATCH_NAME];
            if(Boolean(resultFeatureName) && Boolean(resultBatchName))
            {
               if(Boolean(m_currentContentsWindow) && m_currentContentsWindow.featureName == resultFeatureName)
               {
                  closeCallback = m_currentContentsWindow.onMakeRecipeResultWindowClose;
               }
               UI.displayPopup(new RecipeBoothResultWindow(resultFeatureName,result,closeCallback),false);
            }
         }
      }
      
      public static function requestIngredient(building:FeatureBuilding, requestItem:FarmItem, callback:Function = null, askType:String = null, feedBundleName:String = "featureBuildingAskPart") : void
      {
         var friendSpec:Object = null;
         var friendTabOrder:Array = null;
         var buildingItem:BuildingItem = null;
         switch(askType)
         {
            case FeatureBuilding.ASK_PARTS_MFS_ASKITEMS_REACTS:
               friendSpec = {"tabNameSingleParts":[MFSConstants.TYPE_SINGLE_PARTS]};
               friendTabOrder = ["tabNameSingleParts"];
               buildingItem = building.getItem() as BuildingItem;
               MFSRequestManager.getInstance().makeAskItemsRequest(buildingItem.name,requestItem.name,"","","",friendSpec,friendTabOrder);
               if(buildingItem)
               {
                  FeatureTrackingManager.instance.sendR4R(buildingItem.buildingName);
               }
               if(callback != null)
               {
                  callback(true);
               }
               break;
            default:
               building.requestExpansionPart(requestItem,callback,askType,feedBundleName);
         }
      }
   }
}

