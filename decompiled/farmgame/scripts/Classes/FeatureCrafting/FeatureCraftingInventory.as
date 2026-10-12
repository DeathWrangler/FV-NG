package Classes.FeatureCrafting
{
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FeatureCraftingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingStorageWindow;
   
   public class FeatureCraftingInventory
   {
      
      private var m_system:FeatureCraftingSystem;
      
      private var m_name:String;
      
      private var m_level:int;
      
      private var m_capacityIncrement:int;
      
      private var m_maxCapacity:int;
      
      private var m_parts:Array;
      
      private var m_friendlyTitle:String;
      
      public function FeatureCraftingInventory(system:FeatureCraftingSystem, config:XML)
      {
         var partXml:XML = null;
         super();
         this.m_system = system;
         this.m_name = config.@name;
         this.m_capacityIncrement = parseInt(config.@capacityIncrement.toString());
         this.m_maxCapacity = parseInt(config.@maxCapacity.toString());
         this.m_friendlyTitle = "";
         this.m_parts = [];
         for each(partXml in config.parts.part)
         {
            this.m_parts.push(new FeatureCraftingInventoryPart(this,partXml));
         }
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_system;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get level() : int
      {
         return this.m_level;
      }
      
      public function parts() : Array
      {
         return this.m_parts;
      }
      
      public function get friendlyTitle() : String
      {
         if(!this.m_friendlyTitle)
         {
            this.m_friendlyTitle = this.m_system.getLocalizedString("Inventory_" + this.m_name);
         }
         return this.m_friendlyTitle;
      }
      
      public function allGoodsForInventory() : Array
      {
         return this.m_system.getGoodsForInventory(this.m_name);
      }
      
      public function completeNowCost() : int
      {
         var part:FeatureCraftingInventoryPart = null;
         var result:int = 0;
         for each(part in this.m_parts)
         {
            result += part.getCompleteRequirementCost();
         }
         return result;
      }
      
      public function get currentCount() : int
      {
         var good:FeatureCraftingGood = null;
         var result:int = 0;
         var allGoods:Array = this.allGoodsForInventory();
         for each(good in allGoods)
         {
            result += good.inventoryCount;
         }
         return result;
      }
      
      public function get currentLimit() : int
      {
         return this.m_level * this.m_capacityIncrement;
      }
      
      public function canAddInventory(amount:int = 1) : Boolean
      {
         return this.currentCount + amount <= this.currentLimit;
      }
      
      public function hasReachedMaxInventory() : Boolean
      {
         return this.currentLimit >= this.m_maxCapacity;
      }
      
      public function completeNow() : Boolean
      {
         var cost:int = 0;
         var part:FeatureCraftingInventoryPart = null;
         var result:Boolean = false;
         if(!this.hasReachedMaxInventory())
         {
            cost = this.completeNowCost();
            if(Global.player.canBuyCash(cost))
            {
               Global.player.cash -= cost;
               ++this.m_level;
               for each(part in this.m_parts)
               {
                  part.completeRequirement();
               }
               TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"buyExpandInventory",null,[this.m_system.name,this.m_name]));
               this.finishExpanding();
            }
         }
         return result;
      }
      
      public function canExpandNow() : Boolean
      {
         var part:FeatureCraftingInventoryPart = null;
         var result:Boolean = false;
         if(!this.hasReachedMaxInventory())
         {
            result = true;
            for each(part in this.m_parts)
            {
               if(part.count < part.required)
               {
                  result = false;
                  break;
               }
            }
         }
         return result;
      }
      
      public function expandInventory() : Boolean
      {
         var part:FeatureCraftingInventoryPart = null;
         var result:Boolean = false;
         if(this.canExpandNow())
         {
            ++this.m_level;
            for each(part in this.m_parts)
            {
               part.completeRequirement();
            }
            TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"expandInventory",null,[this.m_system.name,this.m_name]));
            this.finishExpanding();
         }
         return result;
      }
      
      public function setMinCapacity(minCapacity:int) : void
      {
         var minCapacityLevel:int = Math.ceil(minCapacity / this.m_capacityIncrement);
         if(this.m_level < minCapacityLevel)
         {
            this.m_level = minCapacityLevel;
         }
      }
      
      public function displayFullMessage() : void
      {
         var messageText:String = this.m_system.getLocalizedString("InventoryFullMessage",{"storageName":this.friendlyTitle});
         UI.displayMessage(messageText,GenericPopup.TYPE_OK,this.onInventoryFullMessageClose,"InventoryFullMessage",true);
         StatsManager.count(this.m_system.name,"storage_full_dialog",this.m_name,String(this.currentLimit),String(Global.player.level));
      }
      
      protected function onInventoryFullMessageClose(event:GenericPopupEvent) : void
      {
         var inventory:FeatureCraftingInventory = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            inventory = this.m_system.getInventory(this.m_name);
            FeatureCraftingStorageWindow.display(inventory,true);
         }
      }
      
      public function setUserData(data:Object) : void
      {
         var part:FeatureCraftingInventoryPart = null;
         if(data.hasOwnProperty("parts"))
         {
            for each(part in this.m_parts)
            {
               if(data.parts.hasOwnProperty(part.name))
               {
                  part.setUserData(data.parts[part.name]);
               }
            }
         }
         this.m_level = data.level;
      }
      
      private function finishExpanding() : void
      {
         if(this.m_system.currentContentsWindow)
         {
            this.m_system.currentContentsWindow.refreshInventoryCounts();
         }
      }
   }
}

