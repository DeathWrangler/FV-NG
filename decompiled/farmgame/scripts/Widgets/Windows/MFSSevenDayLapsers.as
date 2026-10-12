package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetSevenDayLapsers;
   
   public class MFSSevenDayLapsers extends MFSAskItems
   {
      
      public function MFSSevenDayLapsers(friendSpec:Object, friendTabOrder:Array, requestItem:FarmItem, featureName:String, source:String, completeCallback:Function)
      {
         if(friendSpec == null)
         {
            friendSpec = {"NO_TABS":[MFSConstants.NO_TABS]};
         }
         super(friendSpec,friendTabOrder,requestItem,featureName,source,null);
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetSevenDayLapsers(false,onFriendPopulation),true);
      }
   }
}

