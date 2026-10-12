package Managers.Crafting
{
   import flash.utils.Dictionary;
   
   public class MarketView
   {
      
      private var m_lastUpdated:Number;
      
      private var m_marketStallInventory:Dictionary;
      
      private var m_craftedGoodInventory:Dictionary;
      
      private var m_craftingSkill:Dictionary;
      
      private var m_timestampDictionary:Dictionary;
      
      public function MarketView()
      {
         super();
         this.m_marketStallInventory = new Dictionary();
         this.m_craftedGoodInventory = new Dictionary();
         this.m_craftingSkill = new Dictionary();
         this.m_timestampDictionary = new Dictionary();
         this.m_lastUpdated = 0;
      }
      
      public function get marketStallInventory() : Dictionary
      {
         return this.m_marketStallInventory;
      }
      
      public function get craftedGoodInventory() : Dictionary
      {
         return this.m_craftedGoodInventory;
      }
      
      public function get craftingSkills() : Dictionary
      {
         return this.m_craftingSkill;
      }
      
      public function set craftingSkills(craftSkillDic:Dictionary) : void
      {
         this.m_craftingSkill = craftSkillDic;
      }
      
      public function get timestampDictionary() : Dictionary
      {
         return this.m_timestampDictionary;
      }
      
      public function get lastUpdated() : Number
      {
         return this.m_lastUpdated;
      }
      
      public function set lastUpdated(newLastUpdated:Number) : void
      {
         this.m_lastUpdated = newLastUpdated;
      }
      
      public function getUserAge(uid:String) : Number
      {
         var serverTime:Number = Math.floor(GlobalEngine.serverTime / 1000);
         return Math.max(0,serverTime - this.m_timestampDictionary[uid]);
      }
      
      public function getUserIsStale(uid:String) : Boolean
      {
         return this.getUserAge(uid) > CraftingConstants.MAX_INDIVIDUAL_STALL_AGE;
      }
      
      public function setUserLastUpdated(uid:String, newLastUpdated:Number) : void
      {
         this.m_timestampDictionary[uid] = newLastUpdated;
      }
   }
}

