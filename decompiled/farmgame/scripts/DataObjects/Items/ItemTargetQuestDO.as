package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemTargetQuestDO extends BaseDataObject
   {
      
      public var quest:String;
      
      public function ItemTargetQuestDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.quest);
      }
   }
}

