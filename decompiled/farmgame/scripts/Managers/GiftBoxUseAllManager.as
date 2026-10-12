package Managers
{
   import Classes.CreditsBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.StorageItem;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.Dialogs.GenericDialogConfig;
   import Display.UI;
   
   public class GiftBoxUseAllManager
   {
      
      private static var m_messageItem:FarmItem;
      
      private static var m_messageDialog:GenericDialog;
      
      private static const VSD_ONBOARD_ASSET:String = "assets/dialogs/4d_elements/buildableFlow/useAllGift.png";
      
      private static const VSD_HOARDING_FREQUENCY_KEY:String = "VSDHoardingPopup";
      
      public function GiftBoxUseAllManager()
      {
         super();
      }
      
      public static function isItemUseAllEnabled(item:FarmItem) : Boolean
      {
         var result:Boolean = false;
         if(Global.player.getGiftCountForItem(item.name) > 1)
         {
            if(isItemVirtualStorageDecoration(item) || isItemUseAllEligible(item))
            {
               result = true;
            }
         }
         return result;
      }
      
      public static function itemUseAllCount(item:FarmItem) : int
      {
         var buildings:Array = null;
         var building:StorageBuilding = null;
         var itemCount:int = 0;
         var maxCapacity:int = 0;
         var itemCapacityCount:int = 0;
         var capacityApplied:int = 0;
         var capacityAvailable:int = 0;
         var result:int = 0;
         if(isItemVirtualStorageDecoration(item))
         {
            buildings = Global.world.getStorageBuildings(item.basket,item.name);
            if(buildings.length > 0)
            {
               for each(building in buildings)
               {
                  if(building.isFullyBuilt())
                  {
                     itemCount = Global.player.getGiftCountForItem(item.name);
                     maxCapacity = item.max;
                     if(maxCapacity <= 0)
                     {
                        result = itemCount;
                        break;
                     }
                     itemCapacityCount = itemCount * item.count;
                     if(building is CreditsBuilding)
                     {
                        if(item.subcreditsType)
                        {
                           capacityApplied = int((building as CreditsBuilding).getCurrentSubcredits(item.subcreditsType));
                        }
                        else
                        {
                           capacityApplied = int((building as CreditsBuilding).getCurrentCredits());
                        }
                     }
                     else
                     {
                        capacityApplied = building.count;
                     }
                     capacityAvailable = maxCapacity - capacityApplied;
                     if(capacityAvailable > 0)
                     {
                        result = Math.floor(Math.min(itemCapacityCount,capacityAvailable) / item.count);
                        break;
                     }
                  }
               }
            }
         }
         else if(isItemUseAllEnabled(item))
         {
            result = Global.player.getGiftCountForItem(item.name);
         }
         return result;
      }
      
      public static function isItemVirtualStorageDecoration(item:FarmItem) : Boolean
      {
         var result:Boolean = false;
         switch(item.className)
         {
            case "FeatureCreditItem":
            case "FeedTroughItem":
            case "BeehiveItem":
               result = true;
         }
         return result;
      }
      
      public static function isItemUseAllEligible(item:FarmItem) : Boolean
      {
         var result:Boolean = false;
         switch(item.className)
         {
            case "CSocialRaffleTicket":
            case "CFuel":
            case "CCoins":
            case "CRewardConsumeAll":
            case "CTurbo":
               result = true;
         }
         return result;
      }
      
      public static function conditionallyShowVirtualStorageDecorationHoardingMessage() : Boolean
      {
         var featureItemCount:int = 0;
         var gifts:Array = null;
         var currentItem:FarmItem = null;
         var currentItemCount:int = 0;
         var i:int = 0;
         var gift:StorageItem = null;
         var useAllQuantity:int = 0;
         var basketItem:FarmItem = null;
         var config:GenericDialogConfig = null;
         var result:Boolean = false;
         var currentTime:int = GlobalEngine.serverTime / 1000;
         var lastShown:Number = Global.player.getFeatureLastShown(VSD_HOARDING_FREQUENCY_KEY);
         var featureFrequency:Number = Global.farmGameSettingsManager.getNumber("VSDHoardingPopupFeatureFrequency",86400);
         if(currentTime > lastShown + featureFrequency)
         {
            featureItemCount = Global.farmGameSettingsManager.getNumber("VSDHoardingPopupItemCount",50);
            gifts = Global.player.getGifts();
            currentItemCount = 0;
            for(i = 0; i < gifts.length; i++)
            {
               gift = gifts[i] as StorageItem;
               if(Boolean(gift) && Boolean(gift.item) && GiftBoxUseAllManager.isItemUseAllEnabled(gift.item))
               {
                  useAllQuantity = GiftBoxUseAllManager.itemUseAllCount(gift.item);
                  if(useAllQuantity >= featureItemCount && useAllQuantity > currentItemCount)
                  {
                     currentItem = gift.item;
                     currentItemCount = useAllQuantity;
                  }
               }
            }
            if(Boolean(currentItem) && GiftBoxUseAllManager.isItemVirtualStorageDecoration(currentItem))
            {
               basketItem = Global.farmGameSettingsManager.getFarmItemByName(currentItem.basket);
               config = new GenericDialogConfig();
               config.setBodyText(ZLocUtils.t("Dialogs","VirtualStorageDecorationHoardingMessage",{
                  "item":ZLocUtils.tk_pk(currentItem.friendlyName),
                  "basket":ZLocUtils.tk_pk(basketItem.friendlyName)
               }));
               config.setImageUrl(currentItem.iconUrl);
               config.showCloseButton(false);
               config.setName("VirtualStorageDecorationHoardingMessage");
               config.addButton(ZLocUtils.t("Dialogs","UseAll"),GenericDialogConfig.COLOR_GREEN,onVirtualStorageDecorationHoardingMessageAccept);
               config.addButton(ZLocUtils.t("Dialogs","Cancel"),GenericDialogConfig.COLOR_RED,onVirtualStorageDecorationHoardingMessageCancel);
               m_messageItem = currentItem;
               m_messageDialog = GenericDialog.createFromConfig(config);
               if(m_messageDialog)
               {
                  m_messageDialog.show(false);
               }
               Global.player.setFeatureLastShown(VSD_HOARDING_FREQUENCY_KEY,currentTime,true);
               result = true;
            }
         }
         return result;
      }
      
      private static function onVirtualStorageDecorationHoardingMessageAccept(isAccept:Boolean) : void
      {
         var extraData:Object = null;
         if(m_messageDialog)
         {
            m_messageDialog.destroy();
            m_messageDialog = null;
         }
         if(m_messageItem)
         {
            extraData = {};
            if(GiftBoxUseAllManager.isItemUseAllEnabled(m_messageItem))
            {
               extraData["itemCount"] = GiftBoxUseAllManager.itemUseAllCount(m_messageItem);
            }
            m_messageItem.onUse(Global.world.GIFTBOX_ID,extraData);
            m_messageItem = null;
         }
      }
      
      private static function onVirtualStorageDecorationHoardingMessageCancel(isAccept:Boolean) : void
      {
         if(m_messageDialog)
         {
            m_messageDialog.destroy();
            m_messageDialog = null;
         }
         UI.displayGiftBoxWindow();
         m_messageItem = null;
      }
   }
}

