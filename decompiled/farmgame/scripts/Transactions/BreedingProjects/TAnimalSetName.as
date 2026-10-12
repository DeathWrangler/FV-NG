package Transactions.BreedingProjects
{
   import Classes.FeatureBuilding;
   import Transactions.TFarmTransaction;
   
   public class TAnimalSetName extends TFarmTransaction
   {
      
      private var m_itemCode:String = "";
      
      private var m_metadataHash:String = "";
      
      private var m_name:String = "";
      
      private var m_worldId:Number = -1;
      
      private var m_building:FeatureBuilding;
      
      private var m_callback:Function = null;
      
      public function TAnimalSetName(itemCode:String, metadataHash:String, name:String, worldId:Number = 1, building:FeatureBuilding = null, callback:Function = null)
      {
         this.m_itemCode = itemCode;
         this.m_metadataHash = metadataHash;
         this.m_name = name;
         this.m_worldId = worldId;
         this.m_building = building;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("AnimalBreedingService.onSetAnimalName",this.m_itemCode,this.m_metadataHash,this.m_name,this.m_worldId,this.m_building ? this.m_building.getSaveObject() : null);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

