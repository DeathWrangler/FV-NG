package Classes.consumables
{
   import Classes.Consumable;
   import GameMode.GMVehicleUpgrade;
   
   public class CVehiclePart extends Consumable
   {
      
      private var m_isGift:Boolean = true;
      
      public function CVehiclePart(itemName:String)
      {
         super(itemName);
      }
      
      override public function initialize(data:Object) : void
      {
         if(Boolean(data) && data.hasOwnProperty("isGift"))
         {
            this.m_isGift = Boolean(data.isGift);
         }
      }
      
      override public function onUse() : void
      {
         if(this.canUse())
         {
            Global.world.addGameMode(new GMVehicleUpgrade(m_item.name,this.m_isGift),false);
         }
      }
      
      override public function isOptimistic() : Boolean
      {
         return true;
      }
      
      override public function canUse() : Boolean
      {
         return true;
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         Global.world.addGameMode(new GMVehicleUpgrade(this.getItem().name,isGift),false);
      }
   }
}

