package DataObjects.Items.ChangeFarm
{
   import DataObjects.Items.BaseItemDO;
   
   public class ChangeFarmItemDO extends BaseItemDO
   {
      
      [XmlAttribute(§default§="true")]
      public var showBuyMessage:Boolean;
      
      [XmlAttribute(§default§="-2147483648")]
      public var size:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var squares:int;
      
      public var variablePricesByLevel:ItemVariablePricesByLevelDO;
      
      public function ChangeFarmItemDO()
      {
         super();
      }
   }
}

