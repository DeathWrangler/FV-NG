package Classes.crafting
{
   import flash.utils.Dictionary;
   
   public class ShoppingState
   {
      
      private var m_maxBagsPerUser:Number;
      
      private var m_maxPurchasesPerDay:Number;
      
      private var m_maxCraftingBagsPerUser:Number;
      
      private var m_maxCraftingPurchasesPerDay:Number;
      
      private var m_bagsUsed:Dictionary = new Dictionary();
      
      private var m_craftingBagsUsed:Dictionary = new Dictionary();
      
      private var m_lastGetBushelsRequestTS:Number = 0;
      
      public function ShoppingState()
      {
         super();
      }
      
      public function get maxPurchasesPerDay() : Number
      {
         return this.m_maxPurchasesPerDay;
      }
      
      public function get maxCraftingPurchasesPerDay() : Number
      {
         return this.m_maxCraftingPurchasesPerDay;
      }
      
      public function getTotalDailyPurchases() : int
      {
         var bagsUsed:int = 0;
         Global.player.craftingState.checkCraftingRollOver();
         var total:int = 0;
         for each(bagsUsed in this.m_bagsUsed)
         {
            total += bagsUsed;
         }
         return total;
      }
      
      public function getTotalDailyCraftingPurchases() : int
      {
         var bagsUsed:int = 0;
         Global.player.craftingState.checkCraftingRollOver();
         var total:int = 0;
         for each(bagsUsed in this.m_craftingBagsUsed)
         {
            total += bagsUsed;
         }
         return total;
      }
      
      public function set maxPurchasesPerDay(newMaxPurchasesPerDay:Number) : void
      {
         this.m_maxPurchasesPerDay = newMaxPurchasesPerDay;
      }
      
      public function set maxCraftingPurchasesPerDay(newMaxCraftingPurchasesPerDay:Number) : void
      {
         this.m_maxCraftingPurchasesPerDay = newMaxCraftingPurchasesPerDay;
      }
      
      public function get maxBagsPerUser() : Number
      {
         return this.m_maxBagsPerUser;
      }
      
      public function get maxCraftingBagsPerUser() : Number
      {
         return this.m_maxCraftingBagsPerUser;
      }
      
      public function set maxCraftingBagsPerUser(newMaxCraftingBagsPerUser:Number) : void
      {
         this.m_maxCraftingBagsPerUser = newMaxCraftingBagsPerUser;
      }
      
      public function set maxBagsPerUser(newMaxBagsPerUser:Number) : void
      {
         this.m_maxBagsPerUser = newMaxBagsPerUser;
      }
      
      public function set lastGetBushelsRequestTS(newLastGetBushelsRequestTS:Number) : void
      {
         this.m_lastGetBushelsRequestTS = newLastGetBushelsRequestTS;
      }
      
      public function get lastGetBushelsRequestTS() : Number
      {
         return this.m_lastGetBushelsRequestTS;
      }
      
      public function clearBags() : void
      {
         this.m_bagsUsed = new Dictionary();
         this.m_craftingBagsUsed = new Dictionary();
      }
      
      public function addBagsUsed(uid:String, bagsUsed:int) : void
      {
         if(this.m_bagsUsed[uid] == null)
         {
            this.m_bagsUsed[uid] = 0;
         }
         this.m_bagsUsed[uid] = int(Math.max(this.m_bagsUsed[uid] + bagsUsed,0));
      }
      
      public function addCraftingBagsUsed(uid:String, bagsUsed:int) : void
      {
         if(this.m_craftingBagsUsed[uid] == null)
         {
            this.m_craftingBagsUsed[uid] = 0;
         }
         this.m_craftingBagsUsed[uid] = int(Math.max(this.m_craftingBagsUsed[uid] + bagsUsed,0));
      }
      
      public function getBagsUsedByUser(uid:String) : int
      {
         Global.player.craftingState.checkCraftingRollOver();
         var result:int = 0;
         if(this.m_bagsUsed[uid] != null)
         {
            result = int(this.m_bagsUsed[uid]);
         }
         return result;
      }
      
      public function getCraftingBagsUsedByUser(uid:String) : int
      {
         Global.player.craftingState.checkCraftingRollOver();
         var result:int = 0;
         if(this.m_craftingBagsUsed[uid] != null)
         {
            result = int(this.m_craftingBagsUsed[uid]);
         }
         return result;
      }
   }
}

