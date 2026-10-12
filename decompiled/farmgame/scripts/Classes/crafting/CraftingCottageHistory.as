package Classes.crafting
{
   import Managers.Crafting.CraftingConstants;
   
   public class CraftingCottageHistory
   {
      
      private var m_transactionHistory:Array;
      
      private var m_lastViewedTS:Number;
      
      private var m_xpGain:int;
      
      private var m_viewedThisSession:Boolean = false;
      
      private var m_pendingLevelUpFeed:Object;
      
      public function CraftingCottageHistory(transactionHistory:Array, lastViewedTS:Number, xpGain:int, pendingLevelUpFeed:Object)
      {
         super();
         this.m_transactionHistory = transactionHistory ? transactionHistory : [];
         this.m_lastViewedTS = lastViewedTS;
         this.m_xpGain = xpGain;
         this.m_pendingLevelUpFeed = pendingLevelUpFeed;
      }
      
      public function getLevelUpFeedInfo() : Object
      {
         return this.m_pendingLevelUpFeed;
      }
      
      public function hasFreshTransactions() : Boolean
      {
         return (Boolean(this.coinsGained) || Boolean(this.xpGained)) && !this.m_viewedThisSession;
      }
      
      public function setViewed() : void
      {
         this.m_viewedThisSession = true;
      }
      
      public function getSlotFrameItems(showAllHistory:Boolean = true) : Array
      {
         var frameItem:Object = null;
         var record:Object = null;
         var recipeItem:RecipeItem = null;
         var frameItems:Array = [];
         for(var i:int = 0; i < this.m_transactionHistory.length; i++)
         {
            record = this.m_transactionHistory[i];
            if((record[CraftingConstants.LOGFIELD_ACTION] == CraftingConstants.LOGACTION_RECIPE_LVL || record[CraftingConstants.LOGFIELD_ACTION] == CraftingConstants.LOGACTION_SOLD) && (showAllHistory || this.m_lastViewedTS < record[CraftingConstants.LOGFIELD_TIMESTAMP]))
            {
               frameItem = record[CraftingConstants.LOGFIELD_DATA];
               recipeItem = Global.craftConfigSettings.getRecipeById(frameItem[CraftingConstants.LOGDATA_RECIPE_ID]);
               if(recipeItem)
               {
                  frameItem[CraftingConstants.LOGFIELD_ACTION] = record[CraftingConstants.LOGFIELD_ACTION];
                  frameItem[CraftingConstants.LOGFIELD_TIMESTAMP] = record[CraftingConstants.LOGFIELD_TIMESTAMP];
                  frameItems.push(frameItem);
               }
            }
         }
         return frameItems;
      }
      
      public function get friendsSold() : int
      {
         var friends:int = 0;
         for(var i:int = 0; i < this.m_transactionHistory.length; i++)
         {
            if(this.m_transactionHistory[i][CraftingConstants.LOGFIELD_ACTION] == CraftingConstants.LOGACTION_SOLD && this.m_transactionHistory[i][CraftingConstants.LOGFIELD_TIMESTAMP] > this.m_lastViewedTS)
            {
               friends += this.m_transactionHistory[i][CraftingConstants.LOGFIELD_DATA][CraftingConstants.LOGDATA_UID].length;
               if(this.m_transactionHistory[i][CraftingConstants.LOGFIELD_DATA].hasOwnProperty(CraftingConstants.LOGDATA_UID_OVERFLOW))
               {
                  friends += this.m_transactionHistory[i][CraftingConstants.LOGFIELD_DATA][CraftingConstants.LOGDATA_UID_OVERFLOW];
               }
            }
         }
         return friends;
      }
      
      public function get xpGained() : int
      {
         return this.m_xpGain;
      }
      
      public function get coinsGained() : int
      {
         var coins:int = 0;
         for(var i:int = 0; i < this.m_transactionHistory.length; i++)
         {
            if(this.m_transactionHistory[i][CraftingConstants.LOGFIELD_ACTION] == CraftingConstants.LOGACTION_SOLD && this.m_transactionHistory[i][CraftingConstants.LOGFIELD_TIMESTAMP] > this.m_lastViewedTS)
            {
               coins += this.m_transactionHistory[i][CraftingConstants.LOGFIELD_DATA][CraftingConstants.LOGDATA_PRICE] * this.m_transactionHistory[i][CraftingConstants.LOGFIELD_DATA][CraftingConstants.LOGDATA_QTY];
            }
         }
         return coins;
      }
   }
}

