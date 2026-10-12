package DataObjects.Items.CoreItems.Decoration
{
   import DataObjects.BaseDataObject;
   
   public class HarvestSourcesSourceDO extends BaseDataObject
   {
      
      public var source:String;
      
      public function HarvestSourcesSourceDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.source);
      }
   }
}

