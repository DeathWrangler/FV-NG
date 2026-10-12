package Transactions
{
   import Classes.Equipment;
   import Classes.GarageBuilding;
   import Classes.feed.VehicleLevelUpFeed;
   
   public class TAddPartToEquipmentInGarage extends TFarmTransaction
   {
      
      private var m_buildingId:Number;
      
      private var m_key:String;
      
      private var m_isGift:Boolean;
      
      private var m_equipment:Equipment;
      
      public function TAddPartToEquipmentInGarage(id:Number, key:String, isGift:Boolean = false)
      {
         this.m_buildingId = id;
         this.m_key = key;
         this.m_isGift = isGift;
         var building:GarageBuilding = Global.world.getObjectById(this.m_buildingId) as GarageBuilding;
         var explodedKey:Array = this.m_key.split(":");
         var newKey:String = explodedKey[0] + ":" + (int(explodedKey[1]) + 1);
         this.m_equipment = building.getEquipmentObject(newKey);
         super();
      }
      
      override public function perform() : void
      {
         signedCall("EquipmentWorldService.onAddPartToEquipmentInGarage",this.m_buildingId,this.m_key,this.m_isGift);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var feed:VehicleLevelUpFeed = null;
         if(Boolean(result) && Boolean(result.rewardUrl))
         {
            feed = new VehicleLevelUpFeed(result.rewardUrl,this.m_equipment);
            feed.startFeedFlow();
         }
      }
   }
}

