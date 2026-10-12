package Classes.ItemBuffs
{
   import Classes.ItemBuff;
   import Classes.ZItem.FarmItem;
   import Managers.FarmGameSettingsManager;
   
   public class IBPollinatedCrop extends ItemBuff
   {
      
      protected const SEC_IN_DAY:uint = 86400;
      
      public function IBPollinatedCrop(itemBuffName:String, itemCode:String, startTime:int)
      {
         super(itemBuffName,itemCode,startTime);
      }
      
      override public function hasExpired() : Boolean
      {
         var itemBuff:FarmItem = getItem();
         var serverTime:Number = GlobalEngine.serverTime / 1000;
         var expireTime:Number = m_startTime + this.getSeedExpireVal(itemBuff);
         return serverTime > expireTime;
      }
      
      private function getSeedExpireVal(item:FarmItem) : int
      {
         var seedExpire:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            seedExpire = item.getIntFromDataSource("seedexpire");
         }
         else
         {
            seedExpire = int(item.xml.seedexpire);
         }
         return seedExpire;
      }
      
      public function daysRemaining() : uint
      {
         var itemBuff:FarmItem = getItem();
         var serverTime:Number = GlobalEngine.serverTime / 1000;
         var expireTime:Number = m_startTime + this.getSeedExpireVal(itemBuff);
         return Math.max(Math.ceil((expireTime - serverTime) / this.SEC_IN_DAY));
      }
   }
}

