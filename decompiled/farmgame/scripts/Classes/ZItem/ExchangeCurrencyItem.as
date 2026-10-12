package Classes.ZItem
{
   import DataSources.BaseDataSource;
   import Engine.Managers.TransactionManager;
   import Transactions.TBuyCurrency;
   
   public class ExchangeCurrencyItem extends ConsumableItem
   {
      
      public function ExchangeCurrencyItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         Global.player.updateWorldCurrency(this.subType,this.count);
         Global.player.cash -= cash;
         var sourceString:String = Boolean(extraData) && extraData.hasOwnProperty("source") ? extraData["source"] : "market";
         TransactionManager.addTransaction(new TBuyCurrency(name,sourceString));
         return true;
      }
   }
}

