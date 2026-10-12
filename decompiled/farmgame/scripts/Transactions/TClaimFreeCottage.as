package Transactions
{
   public class TClaimFreeCottage extends TFarmTransaction
   {
      
      private var m_Callback:Function;
      
      private var m_SelectionItemCode:String;
      
      public function TClaimFreeCottage(selectionItemCode:String, callBack:Function = null)
      {
         super();
         this.m_Callback = callBack;
         this.m_SelectionItemCode = selectionItemCode;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onClaimFreeCottage",this.m_SelectionItemCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != result)
         {
            if(null != this.m_Callback)
            {
               this.m_Callback(result);
            }
         }
      }
   }
}

