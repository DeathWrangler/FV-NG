package Managers.Crafting
{
   import Classes.crafting.MarketInventoryItem;
   
   public class MarketStallOffering
   {
      
      private var m_inventory:Array;
      
      private var m_offeredBy:String;
      
      public function MarketStallOffering(inventory:Array, offeredBy:String)
      {
         super();
         this.m_inventory = inventory;
         this.m_offeredBy = offeredBy;
      }
      
      public static function loadFromServerObject(offering:Object) : MarketStallOffering
      {
         var itemOffered:MarketInventoryItem = null;
         var items:Array = new Array();
         for(var j:int = 0; j < offering[CraftingConstants.TABBREV_INVENTORY].length; j++)
         {
            itemOffered = new MarketInventoryItem();
            itemOffered.quantity = 1;
            itemOffered.expires = offering[CraftingConstants.TABBREV_INVENTORY][j][CraftingConstants.TABBREV_TIMESTAMP];
            itemOffered.itemCode = offering[CraftingConstants.TABBREV_INVENTORY][j][CraftingConstants.TABBREV_ITEMCODE];
            items.push(itemOffered);
         }
         return new MarketStallOffering(items,offering.uid);
      }
      
      public function get offeredBy() : String
      {
         return this.m_offeredBy;
      }
      
      public function get hasValidUser() : Boolean
      {
         return !isNaN(Number(this.m_offeredBy)) && Global.friendManager.getFriendData(this.m_offeredBy) != null;
      }
      
      public function get inventory() : Array
      {
         return this.m_inventory;
      }
      
      public function get availableInventory() : Array
      {
         var thisItem:MarketInventoryItem = null;
         var result:Array = new Array();
         for(var i:int = 0; i < this.m_inventory.length; i++)
         {
            thisItem = this.inventory[i];
            if(!thisItem.hasExpired())
            {
               result.push(thisItem);
            }
         }
         return result;
      }
   }
}

