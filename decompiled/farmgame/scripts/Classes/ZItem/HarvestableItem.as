package Classes.ZItem
{
   import Classes.HarvestYield;
   import Classes.Mastery;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class HarvestableItem extends FarmItem
   {
      
      protected static const UNSET_MASTERY:int = -1;
      
      protected static const HAS_MASTERY_TRUE:int = 1;
      
      protected static const HAS_MASTERY_FALSE:int = 0;
      
      protected static const UNSET_ORGANIC:int = -1;
      
      protected static const HAS_ORGANIC_TRUE:int = 1;
      
      protected static const HAS_ORGANIC_FALSE:int = 0;
      
      private var m_coinYield:Number = -559038227;
      
      private var m_growTime:Number = -559038227;
      
      private var m_harvestYields:Vector.<HarvestYield> = null;
      
      protected var m_mastery:Mastery = null;
      
      protected var m_bushelItemCode:String = "";
      
      protected var m_hasMastery:int = -1;
      
      protected var m_hasOrganic:int = -1;
      
      protected var m_isMasterable:int = -1;
      
      protected var m_masteryTarget:String;
      
      public var harvestTime:Number = 0;
      
      protected var m_patchTime:Number = 0;
      
      public function HarvestableItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override protected function onConstruction(itemXML:XML, itemData:BaseDataSource) : void
      {
         super.onConstruction(itemXML,itemData);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_dataSource.hasProperty("bushelItemCode"))
            {
               this.m_bushelItemCode = m_dataSource.getString("bushelItemCode");
            }
         }
         else if(itemXML.hasOwnProperty("bushelItemCode"))
         {
            this.m_bushelItemCode = itemXML.bushelItemCode;
         }
      }
      
      public function get coinYield() : Number
      {
         var coinYieldString:String = null;
         if(this.m_coinYield == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_coinYield = m_dataSource.getNumber("coinYield");
            }
            else
            {
               coinYieldString = getXMLProperty(m_itemXML,"coinYield");
               if(coinYieldString == null)
               {
                  this.m_coinYield = 0;
               }
               else
               {
                  this.m_coinYield = Number(coinYieldString);
               }
            }
         }
         return this.m_coinYield;
      }
      
      public function get harvestYields() : Vector.<HarvestYield>
      {
         var harvestConfigsArr:Array = null;
         var lenHarvestConfigs:int = 0;
         var harvestConfigIdx:int = 0;
         var curHarvestYield:HarvestYield = null;
         var harvestConfigs:XMLList = null;
         var numHarvestConfigs:int = 0;
         var harvestCfgIdx:int = 0;
         var harvestYield:HarvestYield = null;
         if(this.m_harvestYields == null)
         {
            this.m_harvestYields = new Vector.<HarvestYield>();
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               harvestConfigsArr = m_dataSource.getArray("harvestYield");
               lenHarvestConfigs = int(harvestConfigsArr.length);
               for(harvestConfigIdx = 0; harvestConfigIdx < lenHarvestConfigs; harvestConfigIdx++)
               {
                  curHarvestYield = HarvestYield.factory(null,harvestConfigsArr[harvestConfigIdx]);
                  if(curHarvestYield)
                  {
                     this.m_harvestYields.push(curHarvestYield);
                  }
               }
            }
            else
            {
               harvestConfigs = this.m_itemXML..harvestYield;
               numHarvestConfigs = harvestConfigs.length();
               for(harvestCfgIdx = 0; harvestCfgIdx < numHarvestConfigs; harvestCfgIdx++)
               {
                  harvestYield = HarvestYield.factory(harvestConfigs[harvestCfgIdx],null);
                  if(harvestYield)
                  {
                     this.m_harvestYields.push(harvestYield);
                  }
               }
            }
         }
         return this.m_harvestYields;
      }
      
      public function get growTime() : Number
      {
         var growTimeString:String = null;
         if(this.m_growTime == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_growTime = m_dataSource.getNumber("growTime");
            }
            else
            {
               growTimeString = getXMLProperty(m_itemXML,"growTime");
               if(growTimeString == null)
               {
                  this.m_growTime = 0;
               }
               else
               {
                  this.m_growTime = Number(growTimeString);
               }
            }
         }
         return this.m_growTime;
      }
      
      public function getHarvestTime() : String
      {
         var dayInSeconds:Number = NaN;
         var result:String = "";
         var harvestLocStr:String = "";
         var harvestLocObj:Object = {};
         if(this.growTime < 1)
         {
            dayInSeconds = Global.farmGameSettingsManager.getNumber("inGameDaySeconds");
            this.harvestTime = dayInSeconds / 60 / 60 * this.growTime;
            harvestLocStr = "GrowthHours";
            harvestLocObj.quantity = this.harvestTime;
            harvestLocObj.Hour_word = ZLocUtils.tk("Dialogs","Hour_word","",harvestLocObj.quantity);
         }
         else
         {
            harvestLocStr = "GrowthDays";
            harvestLocObj.quantity = this.growTime;
            harvestLocObj.Day_word = ZLocUtils.tk("Dialogs","Day_word","",harvestLocObj.quantity);
         }
         return ZLocUtils.t("Dialogs",harvestLocStr,harvestLocObj);
      }
      
      public function get masteryTarget() : String
      {
         if(!this.m_masteryTarget)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_masteryTarget = m_dataSource.getString("masteryTarget");
            }
            else
            {
               this.m_masteryTarget = m_itemXML.masteryTarget;
            }
         }
         return this.m_masteryTarget;
      }
      
      public function get hasMastery() : Boolean
      {
         if(this.m_hasMastery < 0)
         {
            if(this.isMasterable() || this.masteryTarget != "")
            {
               this.m_hasMastery = HAS_MASTERY_TRUE;
            }
            else
            {
               this.m_hasMastery = HAS_MASTERY_FALSE;
            }
         }
         return this.m_hasMastery > 0;
      }
      
      public function get hasOrganic() : Boolean
      {
         var hasOrganic:Boolean = false;
         if(this.m_hasOrganic == UNSET_ORGANIC)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               hasOrganic = m_dataSource.getBoolean("organic");
               if(hasOrganic)
               {
                  this.m_hasOrganic = HAS_ORGANIC_TRUE;
               }
               else
               {
                  this.m_hasOrganic = HAS_ORGANIC_FALSE;
               }
            }
            else if(m_itemXML.hasOwnProperty("@organic") && m_itemXML.@organic == "true")
            {
               this.m_hasOrganic = HAS_ORGANIC_TRUE;
            }
            else
            {
               this.m_hasOrganic = HAS_ORGANIC_FALSE;
            }
         }
         return this.m_hasOrganic == HAS_ORGANIC_TRUE;
      }
      
      public function get organicTotal() : int
      {
         var result:int = HAS_ORGANIC_FALSE;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(this.hasOrganic && m_dataSource.hasProperty("organicCert"))
            {
               result = m_dataSource.getInt("organicCert","orgCount");
            }
         }
         else if(this.hasOrganic && m_itemXML.hasOwnProperty("organicCert"))
         {
            result = int(m_itemXML.organicCert.attribute("orgCount"));
         }
         return result;
      }
      
      public function isMasterable() : Boolean
      {
         var mastery:Boolean = false;
         if(this.m_isMasterable < 0)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               mastery = m_dataSource.getBoolean("mastery");
               if(mastery)
               {
                  this.m_isMasterable = HAS_MASTERY_TRUE;
               }
               else
               {
                  this.m_isMasterable = HAS_MASTERY_FALSE;
               }
            }
            else if(!m_itemXML.hasOwnProperty("@mastery"))
            {
               this.m_isMasterable = HAS_MASTERY_FALSE;
            }
            else
            {
               this.m_isMasterable = m_itemXML.@mastery == "true" ? HAS_MASTERY_TRUE : HAS_MASTERY_FALSE;
            }
         }
         return this.m_isMasterable > 0;
      }
      
      public function get mastery() : Mastery
      {
         if(this.m_mastery == null)
         {
            this.m_mastery = Global.farmGameSettingsManager.getMasteryByCode(code);
         }
         return this.m_mastery;
      }
      
      public function get masteryYield() : int
      {
         var result:int = 0;
         if(this.hasMastery)
         {
            result = 1;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(m_dataSource.hasProperty("masteryYield"))
               {
                  result = m_dataSource.getInt("masteryYield");
               }
            }
            else if(m_itemXML.hasOwnProperty("masteryYield"))
            {
               result = int(m_itemXML.masteryYield);
            }
         }
         return result;
      }
      
      public function get masteryStars() : int
      {
         return this.mastery.currentLevel;
      }
      
      public function get masteryStartsString() : String
      {
         return (this.mastery.currentLevel + 1).toString();
      }
      
      public function get masteryProgress() : int
      {
         return this.mastery.remainingCropsToNextLevel;
      }
      
      override public function set patchTime(newTime:Number) : void
      {
         this.m_patchTime = newTime;
      }
      
      override public function get patchTime() : Number
      {
         return this.m_patchTime;
      }
      
      public function get bushelItemCode() : String
      {
         if(this.m_bushelItemCode == "")
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_bushelItemCode = getDataProperty(m_dataSource,"bushelItemCode");
            }
            else
            {
               this.m_bushelItemCode = getXMLProperty(m_itemXML,"bushelItemCode");
            }
            if(this.m_bushelItemCode == "")
            {
               this.m_bushelItemCode = null;
            }
         }
         return this.m_bushelItemCode;
      }
      
      override public function flush() : void
      {
         super.flush();
         this.m_mastery = null;
         this.m_hasMastery = -1;
         this.m_hasOrganic = UNSET_ORGANIC;
      }
   }
}

