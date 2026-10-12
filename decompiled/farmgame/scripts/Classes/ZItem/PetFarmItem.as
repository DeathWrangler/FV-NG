package Classes.ZItem
{
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class PetFarmItem extends AnimalItem
   {
      
      public const IMAGE_SCALE_ADULT:Number = 1;
      
      private var m_petXml:XML = null;
      
      private var m_trickXmlList:XMLList = null;
      
      public function PetFarmItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      public function init(petSetXml:XML, petItemXml:XML) : void
      {
         this.m_petXml = petItemXml;
         this.m_trickXmlList = petSetXml.trick;
      }
      
      public function get itemColor() : Number
      {
         return this.m_petXml.@itemColor;
      }
      
      public function get itemScale() : Number
      {
         return this.m_petXml.@itemScale;
      }
      
      public function get showCash() : Boolean
      {
         var res:Boolean = false;
         if(Boolean(this.m_petXml) && this.m_petXml.@showCash.toString() == "true")
         {
            res = true;
         }
         return res;
      }
      
      public function get kibbleBonus() : int
      {
         var kibble:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_dataSource.hasProperty("kibbleBonus"))
            {
               kibble = m_dataSource.getInt("kibbleBonus");
            }
         }
         else if(xml.kibbleBonus)
         {
            kibble = int(xml.kibbleBonus);
         }
         return kibble;
      }
      
      public function get imageScaleAdult() : Number
      {
         var scaleAdult:Number = this.IMAGE_SCALE_ADULT;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_dataSource.hasProperty("imageScaleAdult"))
            {
               scaleAdult = m_dataSource.getNumber("imageScaleAdult");
            }
         }
         else if(xml.imageScaleAdult[0])
         {
            scaleAdult = Number(xml.imageScaleAdult[0]);
         }
         return scaleAdult;
      }
      
      public function getLevelTrick(level:int) : String
      {
         var trickName:String = null;
         var trickXml:XMLList = null;
         if(this.m_trickXmlList)
         {
            trickXml = this.m_trickXmlList.(@level == level);
            if(trickXml.length())
            {
               trickName = trickXml[0].@name;
            }
         }
         return trickName;
      }
      
      public function getTrickHarvestType(level:int) : String
      {
         var trickHarvestType:String = null;
         var trickXml:XMLList = null;
         if(this.m_trickXmlList)
         {
            trickXml = this.m_trickXmlList.(@level == level);
            if(trickXml.length())
            {
               trickHarvestType = trickXml[0].@harvestType;
            }
         }
         return trickHarvestType;
      }
      
      public function getTrickConsumable(level:int) : String
      {
         var trickConsumable:String = null;
         var trickXml:XMLList = null;
         if(this.m_trickXmlList)
         {
            trickXml = this.m_trickXmlList.(@level == level);
            if(trickXml.length())
            {
               trickConsumable = trickXml[0].@consumable;
            }
         }
         return trickConsumable;
      }
   }
}

