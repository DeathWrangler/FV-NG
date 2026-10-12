package Transactions
{
   public class TSendEmailPasscode extends TFarmTransaction
   {
      
      protected var m_itemName:String;
      
      public function TSendEmailPasscode(itemName:String)
      {
         super();
         this.m_itemName = itemName;
         if(this.m_itemName == "")
         {
            canPerform = false;
         }
      }
      
      override public function perform() : void
      {
         signedCall("ZAPIClientService.sendEmailPasscode",this.m_itemName);
      }
   }
}

