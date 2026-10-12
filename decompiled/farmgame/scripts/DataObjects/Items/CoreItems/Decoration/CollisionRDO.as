package DataObjects.Items.CoreItems.Decoration
{
   import DataObjects.BaseDataObject;
   
   public class CollisionRDO extends BaseDataObject
   {
      
      public var value:String;
      
      public function CollisionRDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.value);
      }
   }
}

