package Transactions
{
   import Classes.ZItem.FarmItem;
   
   public class TGetLQBundleRemaining extends TFarmTransaction
   {
      
      protected var m_item:FarmItem;
      
      private var m_transactionCompleteCallBack:Function;
      
      public function TGetLQBundleRemaining(itemName:String, transactionCompleteCallback:Function = null)
      {
         super();
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.m_transactionCompleteCallBack = transactionCompleteCallback;
      }
      
      override public function perform() : void
      {
         signedCall("LimitedQuantityBundleService.getBundlesRemaining",this.m_item.name);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_transactionCompleteCallBack != null)
         {
            this.m_transactionCompleteCallBack(result,this.m_item.name);
         }
      }
   }
}

