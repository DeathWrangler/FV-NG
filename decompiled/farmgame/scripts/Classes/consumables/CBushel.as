package Classes.consumables
{
   import Classes.Buff;
   import Classes.Consumable;
   import Classes.ZItem.BushelItem;
   import Classes.ZItem.SeedItem;
   import Classes.buffs.*;
   import Classes.crafting.CraftingStatsManager;
   
   public class CBushel extends Consumable
   {
      
      public static const BUSHEL:String = "bushel";
      
      public function CBushel(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         var bushelItem:BushelItem = this.m_item as BushelItem;
         var crop:SeedItem = bushelItem.seedItem;
         Global.player.buffs["BBushel"] = new Object();
         Global.player.buffs["BBushel"].crop = crop.code;
         var type:int = BBushel.getEligibleBushelBuffType(crop.code);
         CraftingStatsManager.recordBushelUsed(type);
         Global.player.buffs["BBushel"].type = type;
         Global.player.buffs["BBushel"].time = Math.floor(GlobalEngine.serverTime / 1000);
         var buff:Buff = new BBushel("BBushel");
         if(buff)
         {
            buff.apply(true);
         }
      }
      
      override public function isOptimistic() : Boolean
      {
         return true;
      }
   }
}

