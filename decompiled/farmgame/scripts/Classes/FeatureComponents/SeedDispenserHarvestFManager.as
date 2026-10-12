package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.SeedDispenserSeedConfig;
   import Classes.Mastery;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.SeedItem;
   import Classes.storage.StorageItem;
   import Classes.util.ZLocUtils;
   import Managers.SeedDispenserManager;
   import Managers.ToasterManager;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.IconTitleToasterWindow;
   
   public class SeedDispenserHarvestFManager extends HarvestFManager implements IHarvestComponent
   {
      
      public function SeedDispenserHarvestFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      public function get featureName() : String
      {
         return m_owner ? m_owner.getItemName() : "";
      }
      
      override public function getHarvestCurrency() : String
      {
         return Currency.COINS;
      }
      
      override public function getHarvestAmount() : int
      {
         var result:int = 0;
         if(!this.harvestReward)
         {
            result = getLimitedCoinYield();
         }
         return result;
      }
      
      override public function get harvestReward() : FarmItem
      {
         var result:FarmItem = null;
         var seedItem:SeedItem = null;
         var mastery:Mastery = null;
         var isMastered:Boolean = false;
         var seedPackageItemName:String = null;
         var activeSeed:SeedDispenserSeedConfig = SeedDispenserManager.getActiveSeed(this.featureName);
         if(activeSeed)
         {
            seedItem = Global.farmGameSettingsManager.getFarmItemByName(activeSeed.name) as SeedItem;
            if(seedItem)
            {
               mastery = seedItem.mastery;
               isMastered = Boolean(mastery) && mastery.hasAllMasteries();
               if(!isMastered)
               {
                  seedPackageItemName = seedItem.seedpackage;
                  result = Global.farmGameSettingsManager.getFarmItemByName(seedPackageItemName);
               }
            }
         }
         return result;
      }
      
      override public function onPreHarvest() : void
      {
         var rewardAmount:int = 0;
         var storedSeed:StorageItem = null;
         var iconUrl:String = null;
         var ownerItemName:String = null;
         var title:String = null;
         var body:String = null;
         var rewardItem:FarmItem = this.harvestReward;
         if(Boolean(rewardItem) && rewardItem.className == "CSeedPackage")
         {
            rewardAmount = SeedDispenserManager.getSeedPackageSize(this.featureName,m_owner.expand.storageLevel);
            storedSeed = StorageItem.getStorageItem(rewardItem.code,[rewardAmount]);
            if(Boolean(storedSeed) && !storedSeed.isEmpty())
            {
               Global.player.addSeedItem(storedSeed);
               iconUrl = rewardItem.iconUrl;
               ownerItemName = owner.getItemName();
               title = ZLocUtils.t("Dialogs",ownerItemName + "_PostHarvestToasterTitle",{
                  "item":rewardItem.friendlyTitle,
                  "count":rewardAmount
               });
               body = ZLocUtils.t("Dialogs",ownerItemName + "_PostHarvestToasterBody",{
                  "item":rewardItem.friendlyTitle,
                  "count":rewardAmount
               });
               ToasterManager.getInstance().add(new IconTitleToasterWindow(title,body,iconUrl,TOAST_ASSET,TOAST_ASSET_SCALEFACTOR));
            }
         }
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
      }
   }
}

