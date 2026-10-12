package DataObjects.Items.CoreItems
{
   import DataObjects.BaseDataObject;
   
   public class GiftSelectionSelectNoDO extends BaseDataObject
   {
      
      public var value:String;
      
      public function GiftSelectionSelectNoDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.value);
      }
   }
}

