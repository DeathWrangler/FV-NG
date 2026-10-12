package Managers.Crafting
{
   import Classes.Constants.Experiments;
   import Classes.Friend;
   import Classes.crafting.MarketInventoryItem;
   import Classes.crafting.RecipeItem;
   
   public class CraftedGoodOffering
   {
      
      private var m_inventory:Array;
      
      private var m_offeredBy:String;
      
      public function CraftedGoodOffering(inventory:Array, offeredBy:String)
      {
         super();
         this.m_inventory = inventory;
         this.m_offeredBy = offeredBy;
      }
      
      public static function loadFromServerObject(offering:Object) : CraftedGoodOffering
      {
         var itemOffered:MarketInventoryItem = null;
         var items:Array = new Array();
         for(var j:int = 0; j < offering[CraftingConstants.TABBREV_INVENTORY].length; j++)
         {
            itemOffered = new MarketInventoryItem();
            itemOffered.quantity = offering[CraftingConstants.TABBREV_INVENTORY][j][CraftingConstants.TABBREV_QUANTITY];
            itemOffered.expires = 0;
            itemOffered.itemCode = offering[CraftingConstants.TABBREV_INVENTORY][j][CraftingConstants.TABBREV_ITEMCODE];
            itemOffered.price = offering[CraftingConstants.TABBREV_INVENTORY][j][CraftingConstants.TABBREV_PRICE];
            itemOffered.level = MarketViewManager.getInstance().getRecipeSkillLevelForUser(offering.uid,itemOffered.itemCode);
            items.push(itemOffered);
         }
         return new CraftedGoodOffering(items,offering.uid);
      }
      
      public function get offeredBy() : String
      {
         return this.m_offeredBy;
      }
      
      public function get hasValidUser() : Boolean
      {
         var friendData:Friend = Global.friendManager.getFriendData(this.m_offeredBy);
         var validUser:Boolean = !isNaN(Number(this.m_offeredBy)) && friendData != null;
         if(validUser && Boolean(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTINGHIDE_NULLUSERS)))
         {
            validUser = friendData.name != "";
         }
         return validUser;
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
            if(!thisItem.hasExpired() && thisItem.price > 0 && thisItem.quantity > 0)
            {
               result.push(thisItem);
            }
         }
         return this.sortLevelDecending(result);
      }
      
      private function sortLevelDecending(arrayIn:Array) : Array
      {
         var itemA:MarketInventoryItem = null;
         var itemB:MarketInventoryItem = null;
         var recipeLevelA:int = 0;
         var recipeLevelb:int = 0;
         var i:int = 0;
         var arrayOut:Array = [];
         for each(itemA in arrayIn)
         {
            if(arrayOut.length == 0)
            {
               arrayOut.push(itemA);
            }
            else
            {
               for(i = 0; i < arrayOut.length; i++)
               {
                  itemB = arrayOut[i];
                  if(itemA.level > itemB.level)
                  {
                     arrayOut.splice(i,0,itemA);
                     break;
                  }
                  if(i == arrayOut.length - 1)
                  {
                     arrayOut.push(itemA);
                     break;
                  }
               }
            }
         }
         return arrayOut;
      }
      
      public function removeGoodsOfCraftType(craftType:String) : void
      {
         var itemIter:* = 0;
         var inventoryItem:MarketInventoryItem = null;
         var recipeItem:RecipeItem = null;
         if(this.inventory)
         {
            while(itemIter < this.inventory.length)
            {
               inventoryItem = this.inventory[itemIter];
               recipeItem = Global.craftConfigSettings.getRecipeByProductItemCode(inventoryItem.itemCode);
               if(Boolean(recipeItem) && recipeItem.craft == craftType)
               {
                  this.inventory.splice(itemIter,1);
                  itemIter--;
               }
               itemIter++;
            }
            if(Boolean(this.inventory) && this.inventory.length == 0)
            {
               this.m_offeredBy = "0";
            }
         }
      }
   }
}

