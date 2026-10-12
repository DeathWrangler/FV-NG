package Classes.FeatureCrafting
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureCraftingManager;
   import Transactions.TGenericTransaction;
   
   public class FeatureCraftingGood
   {
      
      private var m_system:FeatureCraftingSystem;
      
      private var m_name:String;
      
      private var m_friendlyTitle:String;
      
      private var m_storageName:String;
      
      private var m_iconUrl:String;
      
      private var m_baseCost:int;
      
      private var m_inventoryCount:int;
      
      private var m_sellPrice:int;
      
      public function FeatureCraftingGood(system:FeatureCraftingSystem, config:XML)
      {
         super();
         this.m_system = system;
         this.m_inventoryCount = 0;
         this.m_friendlyTitle = "";
         this.m_name = config.@name.toString();
         this.m_storageName = config.@storage.toString();
         this.m_iconUrl = config.@iconUrl.toString();
         this.m_baseCost = parseInt(config.@baseCost.toString());
         this.m_sellPrice = parseInt(config.@sellPrice.toString());
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_system;
      }
      
      public function get inventoryCount() : int
      {
         return this.m_inventoryCount;
      }
      
      public function incrementCount(quantity:int = 1) : void
      {
         this.m_inventoryCount += quantity;
         if(this.m_system.currentContentsWindow)
         {
            this.m_system.currentContentsWindow.showGoodOverlay(this,quantity);
         }
      }
      
      public function decrementCount(quantity:int = 1) : void
      {
         this.m_inventoryCount -= quantity;
      }
      
      public function setUserData(data:Object) : void
      {
         this.m_inventoryCount = data as int;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get friendlyTitle() : String
      {
         if(!this.m_friendlyTitle)
         {
            this.m_friendlyTitle = this.m_system.getLocalizedString("Good_" + this.m_name);
         }
         return this.m_friendlyTitle;
      }
      
      public function iconUrl() : String
      {
         return this.m_iconUrl;
      }
      
      public function get storageName() : String
      {
         return this.m_storageName;
      }
      
      public function buyGood(quantity:int = 1, source:String = "") : Boolean
      {
         var inventory:FeatureCraftingInventory = null;
         var result:Boolean = false;
         var cost:int = this.costToBuy(quantity);
         if(Global.player.canBuyCash(cost))
         {
            inventory = this.m_system.getInventory(this.m_storageName);
            if(Boolean(inventory) && inventory.canAddInventory(quantity))
            {
               Global.player.cash -= cost;
               this.incrementCount(quantity);
               result = true;
               TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"buyGood",null,[this.m_system.name,this.m_name,quantity]));
               StatsManager.count(this.m_system.name,"buy_good",source,this.m_name,String(quantity));
               if(this.m_system.currentContentsWindow)
               {
                  this.m_system.currentContentsWindow.refreshInventoryCounts();
                  this.m_system.currentContentsWindow.refreshOrders(false);
               }
               if(this.m_system.currentNPCWindow)
               {
                  this.m_system.currentNPCWindow.refreshOrders(false);
               }
            }
            else
            {
               inventory.displayFullMessage();
            }
         }
         return result;
      }
      
      public function costToBuy(quantity:int = 1) : int
      {
         return quantity * Math.ceil(this.m_baseCost * this.m_system.purchaseGoodCostMultiplier());
      }
      
      public function getSellPrice(quantity:int = 1) : int
      {
         return quantity * this.m_sellPrice;
      }
      
      public function removeFromInventory(quantity:int = 1) : Boolean
      {
         var result:Boolean = false;
         if(quantity <= this.m_inventoryCount)
         {
            this.m_inventoryCount -= quantity;
            Global.player.gold += this.getSellPrice(quantity);
            TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"removeGood",null,[this.m_system.name,this.m_name,quantity]));
            result = true;
            if(this.m_system.currentContentsWindow)
            {
               this.m_system.currentContentsWindow.refreshInventoryCounts();
               this.m_system.currentContentsWindow.refreshOrders(false);
            }
         }
         return result;
      }
   }
}

