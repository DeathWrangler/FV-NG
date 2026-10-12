package DataObjects.Items.CoreItems
{
   import DataObjects.BaseDataObject;
   
   public class ItemRewardGiftDO extends BaseDataObject
   {
      
      public var gift:String;
      
      public function ItemRewardGiftDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.gift);
      }
   }
}

