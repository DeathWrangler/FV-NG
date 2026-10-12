package Classes.FeatureCrafting
{
   import Engine.Managers.TransactionManager;
   import Managers.FeatureCraftingManager;
   import Transactions.TGenericTransaction;
   
   public class FeatureCraftingInventoryPart
   {
      
      private var m_inventory:FeatureCraftingInventory;
      
      private var m_iconUrl:String;
      
      private var m_name:String;
      
      private var m_friendlyTitle:String;
      
      private var m_count:int;
      
      private var m_required:int;
      
      private var m_cost:int;
      
      public function FeatureCraftingInventoryPart(inventory:FeatureCraftingInventory, config:XML)
      {
         super();
         this.m_inventory = inventory;
         this.m_name = config.@name.toString();
         this.m_iconUrl = config.@iconUrl.toString();
         this.m_cost = parseInt(config.@cost.toString());
         this.m_required = parseInt(config.@required.toString());
         this.m_count = 0;
         this.m_friendlyTitle = "";
      }
      
      public function setUserData(data:Object) : void
      {
         this.m_count = data as int;
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_inventory.system;
      }
      
      public function get inventory() : FeatureCraftingInventory
      {
         return this.m_inventory;
      }
      
      public function getCompleteRequirementCost() : int
      {
         var result:int = 0;
         if(this.m_required > this.m_count)
         {
            result = (this.m_required - this.m_count) * this.m_cost;
         }
         return result;
      }
      
      public function completeRequirement() : void
      {
         this.m_count = Math.max(this.m_count - this.m_required,0);
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get friendlyTitle() : String
      {
         if(!this.m_friendlyTitle)
         {
            this.m_friendlyTitle = this.m_inventory.system.getLocalizedString("InventoryPart_" + this.m_name);
         }
         return this.m_friendlyTitle;
      }
      
      public function get iconUrl() : String
      {
         return this.m_iconUrl;
      }
      
      public function get cost() : int
      {
         return this.m_cost;
      }
      
      public function get count() : int
      {
         return this.m_count;
      }
      
      public function get required() : int
      {
         return this.m_required;
      }
      
      public function canBuy(amount:int = 1) : Boolean
      {
         return this.m_count + amount <= this.m_required;
      }
      
      public function buy(amount:int = 1) : Boolean
      {
         var cost:int = 0;
         var params:Array = null;
         var result:Boolean = false;
         if(this.canBuy(amount))
         {
            cost = amount * this.m_cost;
            if(Global.player.canBuyCash(cost))
            {
               result = true;
               Global.player.cash -= cost;
               this.m_count += amount;
               params = [this.system.name,this.m_inventory.name,this.m_name,amount];
               TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"buyInventoryPart",null,params));
            }
         }
         return result;
      }
      
      public function incrementQuantity(amount:int = 1) : void
      {
         this.m_count += amount;
      }
   }
}

