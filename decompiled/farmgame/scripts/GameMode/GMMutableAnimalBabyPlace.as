package GameMode
{
   import Classes.Building;
   import Classes.MutableAnimalBaby;
   import Classes.ZItem.FarmItem;
   
   public class GMMutableAnimalBabyPlace extends GMBuild
   {
      
      private var m_breedMetadata:String;
      
      private var m_metadataIndex:Number = 0;
      
      private var m_justWonBaby:Boolean = true;
      
      public function GMMutableAnimalBabyPlace(metadata:Object, buildingType:String = null, isGift:Boolean = false, buildingId:Number = 0, repopGift:Boolean = true, metadataIndex:Number = -1, justWonBaby:Boolean = false)
      {
         this.m_breedMetadata = metadata as String;
         this.m_metadataIndex = metadataIndex;
         this.m_justWonBaby = justWonBaby;
         super(buildingType,isGift,buildingId,repopGift);
      }
      
      override protected function getSelectedObjectClassInstance() : Building
      {
         var farmItem:FarmItem = null;
         if(this.m_justWonBaby)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(m_buildingType);
            this.m_metadataIndex = Global.player.getLastGiftMetadataIndex(farmItem.code);
         }
         return new MutableAnimalBaby(m_buildingType,this.m_breedMetadata,this.m_metadataIndex);
      }
      
      override public function disableMode() : void
      {
         var farmItem:FarmItem = null;
         super.disableMode();
         if(this.m_isGift && this.m_justWonBaby && this.m_objectPlacedSuccess)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(m_buildingType);
            Global.player.removeLastGiftMetadataIndex(farmItem.code);
         }
      }
   }
}

