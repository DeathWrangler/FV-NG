package Classes
{
   import Classes.ZItem.FarmItem;
   
   public class ItemBuff
   {
      
      protected var m_itemBuffName:String;
      
      protected var m_itemCode:String;
      
      protected var m_startTime:int;
      
      public function ItemBuff(itemBuffName:String, itemCode:String, startTime:int)
      {
         super();
         this.m_itemBuffName = itemBuffName;
         this.m_itemCode = itemCode;
         this.m_startTime = startTime;
      }
      
      public function get buffName() : String
      {
         return this.m_itemBuffName;
      }
      
      public function get buffItemCode() : String
      {
         return this.m_itemCode;
      }
      
      public function get startTime() : int
      {
         return this.m_startTime;
      }
      
      public function hasExpired() : Boolean
      {
         return true;
      }
      
      public function getItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByName(this.m_itemBuffName);
      }
   }
}

