package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemKeywordDO extends BaseDataObject
   {
      
      public var word:String;
      
      public function ItemKeywordDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.word);
      }
   }
}

