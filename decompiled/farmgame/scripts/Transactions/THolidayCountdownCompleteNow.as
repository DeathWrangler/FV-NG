package Transactions
{
   import Classes.ZItem.FarmItem;
   import Classes.storage.StorageItem;
   import Display.BuySeedPackages;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.HolidayCountdownManager;
   
   public class THolidayCountdownCompleteNow extends TFarmTransaction
   {
      
      private var m_completeNowPrice:int;
      
      public function THolidayCountdownCompleteNow(price:int)
      {
         this.m_completeNowPrice = price;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("HolidayCountdownService.completeNow",this.m_completeNowPrice);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var addedItems:Array = null;
         var i:int = 0;
         var farmItem:FarmItem = null;
         var seed:FarmItem = null;
         var seedsPurchased:Number = NaN;
         var storedSeed:StorageItem = null;
         var message:String = null;
         if(result)
         {
            addedItems = result.addedItems;
            for(i = 0; i < addedItems.length; i++)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(addedItems[i]);
               if(farmItem.className == "CSeedPackage")
               {
                  seed = BuySeedPackages.getSeedFromSeedPackageName(farmItem.name);
                  seedsPurchased = Global.farmGameSettingsManager.getInt(HolidayCountdownManager.getItemPackageByIndex(i),50);
                  storedSeed = StorageItem.getStorageItem(farmItem.code,[seedsPurchased]);
                  if(Boolean(storedSeed && !storedSeed.isEmpty() && storedSeed.item) && Boolean(storedSeed.item.className) && storedSeed.item.className == "CSeedPackage")
                  {
                     Global.player.addSeedItem(storedSeed);
                  }
               }
               else
               {
                  Global.player.addGift(farmItem.name);
               }
            }
         }
         else
         {
            message = "Error occurred...";
            UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,null,"zzz",true);
            HolidayCountdownManager.destroyDialog();
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = {};
         result.method = "completeNow";
         result.purchasedAll = true;
         return result;
      }
   }
}

