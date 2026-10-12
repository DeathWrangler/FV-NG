package Transactions
{
   import Classes.Building;
   import Classes.FeatureBuilding;
   import Managers.FarmStatsManager;
   
   public class TBuildingPlace extends TPlace
   {
      
      private var m_building:Building;
      
      public function TBuildingPlace(building:Building, isGift:Boolean = false, containerId:int = 0, expansionLevel:int = 1, giftMetadataIndex:Number = 0, currency:String = "")
      {
         super(building);
         this.m_building = building;
         m_params.isGift = isGift;
         m_params.isStorageWithdrawal = containerId;
         m_params.isInventoryWithdrawal = containerId == Global.worldManager.getCurrentWorldStorageId();
         m_params.expansionLevel = expansionLevel;
         m_params.giftMetadataIndex = giftMetadataIndex;
         m_params.currency = currency;
         if(building.getMetadata() != null)
         {
            m_params.metadata = building.getMetadata();
         }
         if(m_params.isGift == true)
         {
            Global.player.removeGift(building);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         var building:Building = m_object as Building;
         FarmStatsManager.count("Constructable","place_structure",building.getItem().name);
         if(building)
         {
            building.onBuildComplete(result);
         }
      }
      
      override protected function updateShareBuyInfo(result:Object) : void
      {
         if(Boolean(this.m_building) && Boolean(this.m_building as FeatureBuilding) && Boolean((this.m_building as FeatureBuilding).slotmachine))
         {
            (this.m_building as FeatureBuilding).slotmachine.onSharePlacement(result);
         }
         else
         {
            super.updateShareBuyInfo(result);
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = super.getTransactionData();
         result.isStorageWithdrawl = m_params.isStorageWithdrawal;
         return result;
      }
   }
}

