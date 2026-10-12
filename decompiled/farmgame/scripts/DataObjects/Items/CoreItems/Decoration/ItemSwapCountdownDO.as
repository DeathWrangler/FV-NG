package DataObjects.Items.CoreItems.Decoration
{
   import DataObjects.BaseDataObject;
   
   public class ItemSwapCountdownDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var itemDeprecationEntry:String;
      
      [XmlAttribute]
      public var displayCountExperimentGate:String;
      
      public function ItemSwapCountdownDO()
      {
         super();
      }
   }
}

