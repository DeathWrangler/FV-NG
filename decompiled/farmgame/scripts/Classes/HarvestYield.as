package Classes
{
   import Classes.Constants.XMLKeys;
   import DataSources.BaseDataSource;
   
   public class HarvestYield
   {
      
      public static const CLASS_CURRENCY:String = "CurrencyHarvestYield";
      
      public static const CLASS_QUEST_REWARD:String = "QuestRewardHarvestYield";
      
      public static const CLASS_EVERGROWING_REWARD:String = "EverGrowingHarvestYield";
      
      protected var m_type:String = "";
      
      protected var m_types:Array = null;
      
      protected var m_yield:Number = 0;
      
      protected var m_yields:Array = null;
      
      protected var m_displayYield:int = 0;
      
      public function HarvestYield(harvestYieldXML:XML, harvestYieldDS:BaseDataSource = null)
      {
         var typeStr:String = null;
         var yieldStr:String = null;
         super();
         if(harvestYieldDS)
         {
            if(harvestYieldDS.hasProperty("type"))
            {
               typeStr = harvestYieldDS.getString("type");
               this.m_types = typeStr.split(",");
               if(this.m_types.length == 1)
               {
                  this.m_type = this.m_types[0];
                  this.m_types = null;
               }
            }
            if(harvestYieldDS.hasProperty("yield"))
            {
               yieldStr = harvestYieldDS.getString("yield");
               this.m_yields = yieldStr.split(",");
               if(this.m_yields.length == 1)
               {
                  this.m_yield = this.m_yields[0];
                  this.m_yields = null;
               }
            }
         }
         else
         {
            if(harvestYieldXML.hasOwnProperty(XMLKeys.ATTR_TYPE))
            {
               if(harvestYieldXML[XMLKeys.ATTR_TYPE])
               {
                  this.m_types = harvestYieldXML[XMLKeys.ATTR_TYPE].split(",");
                  if(this.m_types.length == 1)
                  {
                     this.m_type = this.m_types[0];
                     this.m_types = null;
                  }
               }
            }
            if(harvestYieldXML.hasOwnProperty(XMLKeys.ATTR_YIELD))
            {
               if(harvestYieldXML[XMLKeys.ATTR_YIELD])
               {
                  this.m_yields = harvestYieldXML[XMLKeys.ATTR_YIELD].split(",");
                  if(this.m_yields.length == 1)
                  {
                     this.m_yield = this.m_yields[0];
                     this.m_yields = null;
                  }
               }
            }
         }
      }
      
      public static function factory(harvestYieldConfig:XML, harvestYieldConfigDS:BaseDataSource) : HarvestYield
      {
         var className:String = null;
         var result:HarvestYield = null;
         if(harvestYieldConfigDS)
         {
            className = harvestYieldConfigDS.getString("className");
         }
         else
         {
            className = harvestYieldConfig[XMLKeys.ATTR_CLASS_NAME];
         }
         switch(className)
         {
            case HarvestYield.CLASS_QUEST_REWARD:
               result = new QuestRewardHarvestYield(harvestYieldConfig,harvestYieldConfigDS);
               break;
            case HarvestYield.CLASS_EVERGROWING_REWARD:
               result = new EverGrowingHarvestYield(harvestYieldConfig,harvestYieldConfigDS);
               break;
            case HarvestYield.CLASS_CURRENCY:
            default:
               result = new CurrencyHarvestYield(harvestYieldConfig,harvestYieldConfigDS);
         }
         return result;
      }
      
      public function get yields() : Array
      {
         return this.m_yields;
      }
      
      public function get yield() : Number
      {
         return this.m_yield;
      }
      
      public function get displayYield() : int
      {
         return this.m_displayYield;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function applyReward(quantity:int = 1, multiplier:Number = 1, payload:SimpleHarvestableResource = null) : void
      {
      }
   }
}

