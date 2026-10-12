package Transactions
{
   import Classes.ZItem.FarmItem;
   import Classes.storage.StorageItem;
   import Classes.util.ZLocUtils;
   import Display.BuySeedPackages;
   import Managers.HolidayCountdownManager;
   
   public class THolidayCountdownBuyItem extends TFarmTransaction
   {
      
      protected var m_index:int;
      
      protected var m_package:String;
      
      public function THolidayCountdownBuyItem(index:int = -1, packageName:String = "CSeedPackageSize")
      {
         this.m_index = index;
         this.m_package = packageName;
         super();
      }
      
      override public function perform() : void
      {
         if(this.m_index >= 0)
         {
            signedCall("HolidayCountdownService.buyItemByIndex",this.m_index);
         }
         else
         {
            signedCall("HolidayCountdownService.buyBonusItem");
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         var farmItem:FarmItem = null;
         var config:Object = null;
         var seed:FarmItem = null;
         var seedsPurchased:Number = NaN;
         var storedSeed:StorageItem = null;
         if(Boolean(result) && Boolean(result.itemCode) && Boolean(result.itemCost))
         {
            HolidayCountdownManager.destroyDialog();
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(result.itemCode);
            if(result.updatedData)
            {
               config = result.updatedData["config"];
               if(config != null && config["bonusPrizeItem"] != null && config["justReceivedBonus"] == true && farmItem.name != config["bonusPrizeItem"])
               {
                  Global.player.addGift(config["bonusPrizeItem"]);
               }
               HolidayCountdownManager.showShareBonusDialog();
            }
            Global.player.cash -= result.itemCost;
            if(farmItem.className == "CSeedPackage")
            {
               seed = BuySeedPackages.getSeedFromSeedPackageName(farmItem.name);
               seedsPurchased = Global.farmGameSettingsManager.getInt(this.m_package,50);
               storedSeed = StorageItem.getStorageItem(farmItem.code,[seedsPurchased]);
               if(Boolean(storedSeed && !storedSeed.isEmpty() && storedSeed.item) && Boolean(storedSeed.item.className) && storedSeed.item.className == "CSeedPackage")
               {
                  Global.player.addSeedItem(storedSeed);
                  HolidayCountdownManager.showSeedPopup(ZLocUtils.tk_pk(seed.friendlyName).getString());
               }
            }
            else
            {
               Global.player.addGift(farmItem.name);
               farmItem.onUse(Global.world.GIFTBOX_ID);
            }
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = {};
         if(this.m_index >= 0)
         {
            result.method = "buyItemByIndex";
         }
         else
         {
            result.method = "buyBonusItem";
         }
         result.purchasedItemCode = HolidayCountdownManager.getItemCodeByIndex(this.m_index);
         return result;
      }
   }
}

