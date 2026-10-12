package Classes.crafting
{
   import Classes.MarketStallBuilding;
   import Classes.ZItem.FarmItem;
   
   public class BushelsFoundSummary
   {
      
      private var m_bushelItem:FarmItem;
      
      private var m_stall:MarketStallBuilding;
      
      private var m_quantity:int;
      
      private var m_rewardUrl:String;
      
      public function BushelsFoundSummary(bushelItem:FarmItem, stall:MarketStallBuilding, quantity:int, rewardUrl:String)
      {
         super();
         this.m_bushelItem = bushelItem;
         this.m_stall = stall;
         this.m_quantity = quantity;
         this.m_rewardUrl = rewardUrl;
      }
      
      public function get rewardUrl() : String
      {
         return this.m_rewardUrl;
      }
      
      public function get quantity() : int
      {
         return this.m_quantity;
      }
      
      public function set quantity(value:int) : void
      {
         this.m_quantity = value;
      }
      
      public function get bushelItem() : FarmItem
      {
         return this.m_bushelItem;
      }
      
      public function get cropItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(this.bushelItem.crop);
      }
      
      public function get stall() : MarketStallBuilding
      {
         return this.m_stall;
      }
      
      public function onFeedDisplayed() : void
      {
         this.m_rewardUrl = "";
      }
   }
}

