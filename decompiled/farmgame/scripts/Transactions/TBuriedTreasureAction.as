package Transactions
{
   import Engine.Transactions.Transaction;
   import Managers.BuriedTreasureManager;
   
   public class TBuriedTreasureAction extends Transaction
   {
      
      protected var m_treasureId:String;
      
      protected var m_action:String;
      
      public function TBuriedTreasureAction(treasureId:String, action:String)
      {
         super();
         this.m_treasureId = treasureId;
         this.m_action = action;
      }
      
      override public function perform() : void
      {
         signedCall("BuriedTreasureService.on" + this.m_action,this.m_treasureId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.hasOwnProperty("featureData"))
         {
            BuriedTreasureManager.instance.setFeatureData(result.featureData);
         }
      }
   }
}

