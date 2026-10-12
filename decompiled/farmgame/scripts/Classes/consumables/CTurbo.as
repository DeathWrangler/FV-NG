package Classes.consumables
{
   import Classes.Constants.WorldsConstants;
   import Classes.Consumable;
   
   public class CTurbo extends Consumable
   {
      
      private var m_targetedUserId:String = "";
      
      public function CTurbo(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         Global.player.turboChargers += getItem().count;
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         this.m_targetedUserId = userID;
         if(Global.world.getEquipment() != null || Global.worldManager.currentWorldType != WorldsConstants.WORLD_ID_HOME)
         {
            super.consume(isGift,allowReshopping,userID,isFree,storageId,itemCount);
         }
      }
   }
}

