package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems
{
   import DataObjects.BaseDataObject;
   
   public class ItemAOEDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var locKey:String;
      
      [XmlAttribute]
      public var consolidateBonusOnSourceMove:Boolean;
      
      [XmlAttribute(§default§="true")]
      public var showTargetBonusOnSourceMouseOver:Boolean;
      
      public var bonuses:AOEBonusesDO;
      
      public var targets:AOETargetsDO;
      
      public var areas:AOEAreasDO;
      
      public function ItemAOEDO()
      {
         super();
      }
   }
}

