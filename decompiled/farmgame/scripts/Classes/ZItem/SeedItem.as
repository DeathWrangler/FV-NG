package Classes.ZItem
{
   import Classes.Combine;
   import Classes.RotatableCombine;
   import Classes.RotatableSeeder;
   import Classes.Seeder;
   import DataSources.BaseDataSource;
   import Display.UI;
   import GameMode.GMCombine;
   import GameMode.GMCombineAll;
   import GameMode.GMMarketPlant;
   import GameMode.GMSeeder;
   import GameMode.GMSeederAll;
   import Managers.FarmGameSettingsManager;
   import Managers.TurboPPHManager;
   
   public class SeedItem extends HarvestableItem
   {
      
      protected static const m_defaultTerrains:Array = new Array(FarmGameSettingsManager.TERRAIN_LAND,FarmGameSettingsManager.TERRAIN_UNDERWATER,FarmGameSettingsManager.TERRAIN_EARTH);
      
      protected var m_seedpackage:String = null;
      
      protected var m_seedpackagecode:String = null;
      
      protected var m_isHybrid:Boolean = false;
      
      protected var m_isLockIfNone:Boolean = false;
      
      public function SeedItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override protected function onConstruction(itemXML:XML, itemData:BaseDataSource) : void
      {
         super.onConstruction(itemXML,itemData);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_isHybrid = m_dataSource.getBoolean("isHybrid");
            this.m_isLockIfNone = m_dataSource.getBoolean("lockIfNone");
         }
         else
         {
            this.m_isHybrid = itemXML.hasOwnProperty("@isHybrid") && Boolean(itemXML.@isHybrid);
            this.m_isLockIfNone = itemXML.hasOwnProperty("@lockIfNone") && Boolean(itemXML.@lockIfNone);
         }
      }
      
      override protected function getDefaultTerrains() : Array
      {
         return SeedItem.m_defaultTerrains;
      }
      
      public function get seedpackage() : String
      {
         if(this.m_seedpackage == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_seedpackage = getDataProperty(m_dataSource,"seedpackage");
            }
            else
            {
               this.m_seedpackage = getXMLProperty(m_itemXML,"seedpackage");
            }
         }
         return this.m_seedpackage;
      }
      
      override public function onUse(buildingId:int = 0, extraData:Object = null) : void
      {
         if(Global.artuploadSandboxMode)
         {
            Global.world.addGameMode(new GMMarketPlant(name));
         }
         super.onUse(buildingId,extraData);
      }
      
      override public function get seedpackagecode() : String
      {
         var item:FarmItem = null;
         if(this.m_seedpackagecode == null)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.seedpackage);
            if(item)
            {
               this.m_seedpackagecode = item.code;
            }
         }
         return this.m_seedpackagecode;
      }
      
      public function get superCropSeedItem() : SeedItem
      {
         return Global.farmGameSettingsManager.getSuperCropForSeedItem(this);
      }
      
      public function isSuperCrop() : Boolean
      {
         var isSuperCrop:Boolean = false;
         if(INVALID_VALUE == m_superCrop)
         {
            isSuperCrop = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               isSuperCrop = m_dataSource.getBoolean("superCrop");
            }
            else
            {
               isSuperCrop = m_itemXML.@superCrop == "true";
            }
            if(isSuperCrop)
            {
               m_superCrop = 1;
            }
            else
            {
               m_superCrop = 0;
            }
         }
         return m_superCrop == 1;
      }
      
      public function get isHybrid() : Boolean
      {
         return this.m_isHybrid;
      }
      
      public function get isLockIfNone() : Boolean
      {
         return this.m_isLockIfNone;
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var seeder:Seeder = null;
         var combine:Combine = null;
         switch(UI.marketLaunchReference)
         {
            case UI.MARKET_LAUNCH_REFERENCE_SEEDER:
               seeder = Global.world.getEquipment(Seeder,UI.marketTerrainCodes,name) as Seeder;
               if(seeder == null)
               {
                  seeder = Global.world.getEquipment(RotatableSeeder,UI.marketTerrainCodes,name) as RotatableSeeder;
               }
               if(TurboPPHManager.getInstance().turboSelected)
               {
                  Global.world.addGameMode(new GMSeederAll(Global.farmGameSettingsManager.getFarmItemByName(name),seeder));
               }
               else
               {
                  Global.world.addGameMode(new GMSeeder(Global.farmGameSettingsManager.getFarmItemByName(name),seeder));
               }
               break;
            case UI.MARKET_LAUNCH_REFERENCE_COMBINE:
               combine = Global.world.getEquipment(Combine,UI.marketTerrainCodes) as Combine;
               if(combine == null)
               {
                  combine = Global.world.getEquipment(RotatableCombine,UI.marketTerrainCodes) as Combine;
               }
               if(TurboPPHManager.getInstance().turboSelected)
               {
                  Global.world.addGameMode(new GMCombineAll(Global.farmGameSettingsManager.getFarmItemByName(name),combine));
               }
               else
               {
                  Global.world.addGameMode(new GMCombine(Global.farmGameSettingsManager.getFarmItemByName(name),combine));
               }
               break;
            default:
               Global.world.addGameMode(new GMMarketPlant(name));
         }
         patchTime = GlobalEngine.serverTime;
         UI.marketLaunchReference = null;
         UI.marketTerrainCodes = null;
         return true;
      }
      
      override public function get xpGained() : Number
      {
         return 0;
      }
      
      override public function getPreviewState() : String
      {
         return "grown";
      }
      
      override protected function defaultPreview() : Boolean
      {
         return !this.isLicenseGated;
      }
   }
}

