package Managers
{
   import Classes.Collections.Collectible;
   import Classes.Collections.Collection;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TLECollections;
   import Transactions.TSetFeatureFrequencyTimestamp;
   import Widgets.Windows.LESet.LESetToasterWindow;
   import Widgets.Windows.LESetWindow;
   
   public class LESetManager
   {
      
      private static var m_endMessage:String;
      
      public static var LESET_PROMO_ID:String = "LESet";
      
      private static const FEATURE_FREQ_NAME:String = "LESetCollection";
      
      private static const FLASHPARAM_LE_SET_NAME:String = "LE_SET_NAME";
      
      private static var collectionName:String = null;
      
      public static var themeName:String = "none";
      
      private static var collectionCode:String = "";
      
      private static var m_collection:Collection = null;
      
      private static var m_rewardItem:FarmItem = null;
      
      private static var m_congratsAsset:String = "assets/dialogs/FV_RPGenericPopUp.swf";
      
      private static var m_congratsMessage:String = "none";
      
      public function LESetManager()
      {
         super();
      }
      
      public static function init() : void
      {
         var colNameParts:Array = null;
         var tradeInRewards:Array = null;
         var giftName:String = null;
         if(Boolean(Global.flashHotParams) && Global.flashHotParams.hasOwnProperty(FLASHPARAM_LE_SET_NAME))
         {
            collectionName = Global.flashHotParams[FLASHPARAM_LE_SET_NAME];
         }
         if(Boolean(collectionName) && collectionName != "")
         {
            colNameParts = collectionName.split("_");
            if(colNameParts.length > 1)
            {
               themeName = "theme_" + colNameParts[1];
            }
            if(collectionName != "none")
            {
               m_collection = CollectionsManager.getInstance().getCollection(collectionName);
               if(m_collection)
               {
                  collectionCode = m_collection.code;
                  tradeInRewards = m_collection.getTradeInRewards();
                  if(Boolean(tradeInRewards) && Boolean(tradeInRewards.length > 0) && Boolean(tradeInRewards[0].hasOwnProperty("gift")))
                  {
                     giftName = tradeInRewards[0].gift;
                     if(Boolean(giftName) && giftName != "")
                     {
                        m_rewardItem = Global.farmGameSettingsManager.getFarmItemByName(giftName);
                     }
                  }
               }
               m_congratsMessage = ZLocUtils.t("Dialogs","LESetBonus_Congrats",{"theme":ZLocUtils.t("Dialogs",themeName)});
            }
         }
         m_endMessage = ZLocUtils.t("Dialogs","LESetBonus_EndMessage");
      }
      
      public static function displayDialog(throughInit:Boolean = false, collectionCompleted:Boolean = false) : void
      {
         if(checkAllGates())
         {
            if(throughInit)
            {
               TransactionManager.addTransaction(new TSetFeatureFrequencyTimestamp(FEATURE_FREQ_NAME));
            }
            StatsManager.count("dialog","reward_purch_set_1","view");
            UI.displayPopup(new LESetWindow(collectionCompleted),true);
         }
      }
      
      public static function endPopup(callback:Function) : void
      {
         var endPromoPopup:GenericPopup = new GenericPopup(m_endMessage,GenericPopup.TYPE_OK,callback);
         UI.displayPopup(endPromoPopup,false);
      }
      
      public static function isApartOfCollection(data:FarmItem) : Boolean
      {
         var curCollectables:Array = null;
         var item:Collectible = null;
         var isApart:Boolean = false;
         if(m_collection != null)
         {
            curCollectables = m_collection.getCollectibles();
            for each(item in curCollectables)
            {
               if(item.code == data.code)
               {
                  isApart = true;
                  break;
               }
            }
         }
         return isApart;
      }
      
      private static function isInCollection(data:FarmItem) : Boolean
      {
         var curCollectables:Array = null;
         var item:Collectible = null;
         var isOwned:Boolean = false;
         if(m_collection != null)
         {
            curCollectables = m_collection.getCollectibles();
            for each(item in curCollectables)
            {
               if(item.code == data.code)
               {
                  if(item.numOwned > 0)
                  {
                     isOwned = true;
                  }
                  break;
               }
            }
         }
         return isOwned;
      }
      
      public static function fireToaster() : void
      {
         if(checkAllGates())
         {
            StatsManager.count("toaster","reward_purch_set","view");
            ToasterManager.getInstance().add(new LESetToasterWindow());
         }
      }
      
      public static function updateCollectionCounts(itemCode:String, amount:int) : void
      {
         if(Global.player.collectionCounters[itemCode])
         {
            Global.player.collectionCounters[itemCode] += amount;
         }
         else
         {
            Global.player.collectionCounters[itemCode] = amount;
         }
      }
      
      public static function addItemToCollection(data:FarmItem) : Boolean
      {
         var result:Boolean = false;
         TransactionManager.addTransaction(new TLECollections(data.code));
         updateCollectionCounts(data.code,1);
         if(tradeInCollection() == true)
         {
            result = true;
         }
         return result;
      }
      
      public static function displayCongratulationsDialog() : void
      {
         var rewardPopup:GenericIconPopup = new GenericIconPopup(m_congratsMessage,GenericPopup.ACCEPT,null,getCurrentCollectionRewardData().iconUrl,false,false,"",false);
         StatsManager.count("dialog","reward_purch_set_2","view");
         UI.displayPopup(rewardPopup,false);
      }
      
      public static function displayWhatsThis() : void
      {
         var m_whatsThisMessage:String = ZLocUtils.t("Dialogs","LESetBonus_WhatsThis",{"count":m_collection.getTotalCollectablesCount()});
         var m_howDoesThisWorkPopup:GenericPopup = new GenericPopup(m_whatsThisMessage,GenericPopup.TYPE_OK,null,GenericPopup.GENERIC_ASSET_MED);
         UI.displayPopup(m_howDoesThisWorkPopup,false);
      }
      
      public static function tradeInCollection() : Boolean
      {
         if(checkAllGates())
         {
            return m_collection.tradeIn();
         }
         return false;
      }
      
      public static function getCurrentCollectionRewardData() : FarmItem
      {
         return m_rewardItem;
      }
      
      public static function getCurrentCollectionData() : Array
      {
         var isOwned:Boolean = false;
         var item:Collectible = null;
         var curCollectables:Array = m_collection.getCollectibles();
         var items:Array = new Array();
         for each(item in curCollectables)
         {
            isOwned = false;
            if(item.numOwned > 0)
            {
               isOwned = true;
            }
            items.push({
               "item":Global.farmGameSettingsManager.getFarmItemByCode(item.code),
               "owned":isOwned
            });
         }
         return items;
      }
      
      public static function getCurrentCollectionSize() : int
      {
         return m_collection.getTotalCollectablesCount();
      }
      
      public static function getNumberOwned() : int
      {
         return m_collection.getCurrentUniqueCollectablesCount();
      }
      
      public static function getCurrentCollectionName() : String
      {
         return m_collection.name;
      }
      
      public static function getRemaingCost() : int
      {
         return m_collection.getCashBuyAllAmount();
      }
      
      public static function getRemainingTime() : Number
      {
         return m_collection.expireTimeSecs;
      }
      
      public static function buyAll() : void
      {
         TransactionManager.addTransaction(new TLECollections(null,m_collection.name));
         tradeInCollection();
      }
      
      public static function checkAllGates() : Boolean
      {
         return checkDateGate();
      }
      
      public static function checkDateGate() : Boolean
      {
         return m_collection != null && m_collection.isDateGated();
      }
      
      public static function handleLESetTransaction(transactionResult:Object, placedItem:FarmItem) : void
      {
         if(Boolean(placedItem) && Boolean(transactionResult.hasOwnProperty("LESet")) && transactionResult.LESet == true)
         {
            updateCollectionCounts(placedItem.code,1);
            if(transactionResult.item != null)
            {
               Global.player.addGift(transactionResult.item,"0",1);
               tradeInCollection();
               displayDialog(false,true);
            }
            else
            {
               fireToaster();
            }
         }
      }
   }
}

