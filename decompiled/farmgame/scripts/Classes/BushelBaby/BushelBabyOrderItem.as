package Classes.BushelBaby
{
   import Classes.ZItem.FarmItem;
   
   public class BushelBabyOrderItem
   {
      
      private var m_npcLevel:BushelBabyNPCLevel;
      
      private var m_item:FarmItem;
      
      private var m_numRequired:int;
      
      public function BushelBabyOrderItem(npcLevel:BushelBabyNPCLevel, configObj:Object)
      {
         super();
         this.m_npcLevel = npcLevel;
         this.m_numRequired = configObj.required;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(configObj.name);
      }
      
      public function get npcLevel() : BushelBabyNPCLevel
      {
         return this.m_npcLevel;
      }
      
      public function get item() : FarmItem
      {
         return this.m_item;
      }
      
      public function get itemCount() : int
      {
         return Global.player.craftingState.totalBushelBabiesCraftItemByItemCode(this.item.code);
      }
      
      public function get numRequired() : int
      {
         return this.m_numRequired;
      }
      
      public function get hasEnough() : Boolean
      {
         return this.itemCount >= this.m_numRequired;
      }
   }
}

