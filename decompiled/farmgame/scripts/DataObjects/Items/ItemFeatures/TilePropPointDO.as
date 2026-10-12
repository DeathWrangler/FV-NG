package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class TilePropPointDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var x:int;
      
      [XmlAttribute]
      public var y:int;
      
      public function TilePropPointDO()
      {
         super();
      }
   }
}

