package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import DataSources.BaseDataSource;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Transactions.TGenericWorldObjectTransaction;
   
   public class WitherManager extends FeatureManager implements IWitherComponent
   {
      
      private var m_witherDays:Number = -1;
      
      private var m_canRevert:Boolean = true;
      
      public function WitherManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var witherFeature:XMLList = null;
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(FeatureManager.WITHER_FEATURE_NAME);
            if(featureData)
            {
               if(featureData.hasProperty("witherDays"))
               {
                  this.m_witherDays = featureData.getNumber("witherDays");
               }
               if(featureData.hasProperty("canRevert"))
               {
                  this.m_canRevert = featureData.getBoolean("canRevert");
               }
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            witherFeature = featuresXML.(@name == FeatureManager.WITHER_FEATURE_NAME);
            if(witherFeature != null)
            {
               if(witherFeature.hasOwnProperty("witherDays"))
               {
                  this.m_witherDays = Number(witherFeature.witherDays);
               }
               if(witherFeature.hasOwnProperty("canRevert"))
               {
                  this.m_canRevert = witherFeature.canRevert;
               }
            }
         }
      }
      
      public function get witherDays() : Number
      {
         return this.m_witherDays;
      }
      
      public function isWithered() : Boolean
      {
         return this.getWitherPercentage() == 100;
      }
      
      private function getWitherPercentage() : Number
      {
         var witherTime:Number = NaN;
         var alpha:Number = NaN;
         var m_plantTime:Number = m_owner.plantTime;
         if(m_plantTime > 0 && this.m_witherDays != -1)
         {
            witherTime = m_owner.witherTime(Global.farmGameSettingsManager.getNumber("inGameDaySeconds",82800) * this.m_witherDays * FarmGameUtil.NUM_MSECS_IN_SECOND);
            alpha = (Global.worldTime - m_plantTime) / (witherTime - m_plantTime);
            return Math.min(Math.floor(alpha * 100),100);
         }
         return 0;
      }
      
      public function onClick() : void
      {
         var newLevel:Number = NaN;
         var ownerItem:FarmItem = owner.getFarmItem();
         StatsManager.count(ownerItem.name,"wither","cleanWither",String(owner.plantTime),String(Global.worldTime));
         TransactionManager.addTransaction(new TGenericWorldObjectTransaction(owner,"wither"),true);
         if(this.m_canRevert && Boolean(owner.expand))
         {
            newLevel = owner.expand.storageLevel - 1;
            if(newLevel >= 0)
            {
               owner.expand.storageLevel = newLevel;
               owner.storageLevel = newLevel;
               owner.expand.refreshPartData();
               StatsManager.count(ownerItem.name,"wither","lostALevel",String(newLevel));
            }
         }
         owner.plantTime = Global.worldTime;
         owner.setState(FeatureBuilding.STATE_BARE);
         owner.conditionallyRedraw(true);
      }
   }
}

