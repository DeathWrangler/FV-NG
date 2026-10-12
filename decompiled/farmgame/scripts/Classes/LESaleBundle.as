package Classes
{
   import Classes.ZItem.FarmItem;
   import Engine.Managers.TransactionManager;
   import Transactions.TLEBundleBuy;
   import Transactions.TLEBundleDecline;
   
   public class LESaleBundle
   {
      
      private var m_name:String;
      
      private var m_discount:Number;
      
      private var m_salePrices:Object;
      
      private var m_targetCustomer:String;
      
      private var m_salesObjects:Array;
      
      public function LESaleBundle(name:String, discount:Number, targetCustomer:String, salePrices:Object)
      {
         super();
         this.m_name = name;
         this.m_discount = discount;
         this.m_targetCustomer = targetCustomer;
         this.m_salePrices = salePrices;
         this.generateSaleObjects();
      }
      
      private function generateSaleObjects() : void
      {
         var key:String = null;
         var item:FarmItem = null;
         this.m_salesObjects = new Array();
         for(key in this.m_salePrices)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(key);
            if(item)
            {
               this.m_salesObjects.push(item);
            }
         }
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get discount() : Number
      {
         return this.m_discount;
      }
      
      public function get targetCustomer() : String
      {
         return this.m_targetCustomer;
      }
      
      public function get salePrices() : Object
      {
         return this.m_salePrices;
      }
      
      public function get saleObjects() : Array
      {
         return this.m_salesObjects;
      }
      
      public function getSalePrice(farmItem:FarmItem) : int
      {
         return this.m_salePrices[farmItem.code];
      }
      
      public function getBundleSalePrice() : int
      {
         var price:int = 0;
         var total:int = 0;
         for each(price in this.m_salePrices)
         {
            total += price;
         }
         return total;
      }
      
      public function attemptBundleItemPurchase(farmItem:FarmItem) : void
      {
         var saleLEItemCodes:Array = null;
         if(farmItem)
         {
            saleLEItemCodes = new Array(farmItem.code);
            TransactionManager.addTransaction(new TLEBundleBuy(this,saleLEItemCodes));
         }
      }
      
      public function attemptFullBundlePurchase() : void
      {
         var key:String = null;
         var saleLEItemCodes:Array = new Array();
         for(key in this.m_salePrices)
         {
            saleLEItemCodes.push(key);
         }
         TransactionManager.addTransaction(new TLEBundleBuy(this,saleLEItemCodes));
      }
      
      public function declineBundlePurchase() : void
      {
         TransactionManager.addTransaction(new TLEBundleDecline());
      }
   }
}

