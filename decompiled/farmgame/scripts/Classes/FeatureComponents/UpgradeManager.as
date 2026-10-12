package Classes.FeatureComponents
{
   import Classes.Building;
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.Vector3;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Transactions.TGenericWorldObjectTransaction;
   
   public class UpgradeManager extends FeatureManager implements IUpgradeComponent
   {
      
      private var m_upgradeCost:int = -1;
      
      private var m_upgradeItem:String = "";
      
      private var m_ownerFarmItem:FarmItem;
      
      private var m_upgradeFarmItem:FarmItem;
      
      public function UpgradeManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var upgradeFeature:XMLList = null;
         super(owner);
         this.m_ownerFarmItem = owner.getFarmItem();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = this.m_ownerFarmItem.getFeatureDataByName(FeatureManager.UPGRADE_FEATURE_NAME);
            if(featureData)
            {
               if(featureData.hasProperty("upgradeCost"))
               {
                  this.m_upgradeCost = featureData.getInt("upgradeCost");
               }
               if(featureData.hasProperty("upgradeItem"))
               {
                  this.m_upgradeItem = featureData.getString("upgradeItem");
               }
            }
         }
         else
         {
            featuresXML = this.m_ownerFarmItem.getFeaturesXML();
            upgradeFeature = featuresXML.(@name == FeatureManager.UPGRADE_FEATURE_NAME);
            if(upgradeFeature != null)
            {
               if(upgradeFeature.hasOwnProperty("upgradeCost"))
               {
                  this.m_upgradeCost = int(upgradeFeature.upgradeCost);
               }
               if(upgradeFeature.hasOwnProperty("upgradeItem"))
               {
                  this.m_upgradeItem = upgradeFeature.upgradeItem;
               }
            }
         }
      }
      
      public function upgrade() : void
      {
         this.m_upgradeFarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_upgradeItem);
         StatsManager.count(this.m_ownerFarmItem.name,"AttemptingUpgrade",this.m_upgradeItem,String(this.m_upgradeCost));
         var msg:String = "";
         if(ZLocUtils.hasString("Dialogs",this.m_ownerFarmItem.name + "UpgradeConfirmation"))
         {
            msg = ZLocUtils.t("Dialogs",this.m_ownerFarmItem.name + "UpgradeConfirmation");
         }
         else
         {
            msg = ZLocUtils.t("Dialogs",this.m_ownerFarmItem.type + "UpgradeConfirmation",{
               "item":ZLocUtils.tk_pk_asTitle(m_owner.getItemFriendlyName()),
               "quantity":this.m_upgradeCost
            });
         }
         var confirmation:GenericIconPopup = new GenericIconPopup(msg,GenericPopup.TYPE_OK,this.upgradeCallback,this.m_upgradeFarmItem.icon);
         UI.displayPopup(confirmation,true,"FeatureBuildingUpgradeConfirmation",true);
      }
      
      public function upgradeCallback(event:GenericPopupEvent) : void
      {
         var itemClass:Class = null;
         var replacementResource:MapResource = null;
         var position:Vector3 = null;
         var id:Number = NaN;
         var metaData:Object = null;
         var persistentDataKey:String = null;
         if(event.button == GenericPopup.OK)
         {
            if(Global.player.canBuyCash(this.m_upgradeCost))
            {
               itemClass = this.m_upgradeFarmItem.getMapResourceClass();
               replacementResource = new itemClass(this.m_upgradeItem);
               position = owner.getPosition();
               id = owner.getId();
               metaData = owner.getMetadata();
               persistentDataKey = owner.persistentDataKey;
               if(replacementResource)
               {
                  Global.player.removeLimitedItem(this.m_ownerFarmItem.name);
                  owner.detach();
                  Global.player.cash -= this.m_upgradeCost;
                  TransactionManager.addTransaction(new TGenericWorldObjectTransaction(owner,"upgradeBuilding"),true);
                  replacementResource.setMetadata(metaData);
                  replacementResource.attachToPersistentData(persistentDataKey);
                  replacementResource.setOuter(Global.world);
                  replacementResource.setPosition(position.x,position.y,position.z);
                  replacementResource.conditionallyReattach();
                  replacementResource.setId(id);
                  if(replacementResource is Building)
                  {
                     (replacementResource as Building).setState(FeatureBuilding.STATE_BUILT);
                  }
                  else if(replacementResource is SimpleHarvestableResource)
                  {
                     (replacementResource as SimpleHarvestableResource).setState(FeatureBuilding.STATE_BARE);
                  }
                  replacementResource.update();
                  replacementResource.reloadImage();
                  StatsManager.count(this.m_ownerFarmItem.name,"UpgradeSuccess",this.m_upgradeFarmItem.name);
               }
            }
         }
         else
         {
            StatsManager.count(this.m_ownerFarmItem.name,"UpgradeCanceled","ClickedX");
         }
      }
   }
}

