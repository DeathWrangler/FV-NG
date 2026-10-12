package Transactions
{
   import Engine.Transactions.Transaction;
   import Managers.HolidayCountdownManager;
   
   public class THolidayCountdownUnlockItem extends Transaction
   {
      
      protected var m_index:int;
      
      public function THolidayCountdownUnlockItem(index:int = -1)
      {
         this.m_index = index;
         super();
      }
      
      override public function perform() : void
      {
         if(this.m_index >= 0)
         {
            signedCall("HolidayCountdownService.unlockIndex",this.m_index);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         var unlockPrice:int = HolidayCountdownManager.getUnlockPrice(this.m_index);
         if(Boolean(result) && unlockPrice >= 0)
         {
            Global.player.cash -= unlockPrice;
         }
      }
   }
}

