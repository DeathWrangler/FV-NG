package DataObjects.Items.Bushel
{
   import DataObjects.Items.BaseItemDO;
   
   public class BushelItemDO extends BaseItemDO
   {
      
      [XmlAttribute]
      public var grantsLicense:Boolean;
      
      public var crop:String;
      
      public var shareableBushel:int;
      
      public var stallLifeSpan:int;
      
      public function BushelItemDO()
      {
         super();
      }
   }
}

