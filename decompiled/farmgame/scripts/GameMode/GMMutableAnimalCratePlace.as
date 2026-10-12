package GameMode
{
   import Classes.Building;
   import Classes.FeatureBuilding;
   import Classes.MutableAnimalCrate;
   import flash.events.MouseEvent;
   
   public class GMMutableAnimalCratePlace extends GMBuild
   {
      
      private var m_animalCrate:MutableAnimalCrate;
      
      private var m_babyMetadata:String;
      
      public function GMMutableAnimalCratePlace(metadata:Object, itemName:String = null, isGift:Boolean = false, buildingId:Number = 0, repopGift:Boolean = true)
      {
         this.m_babyMetadata = metadata as String;
         m_cid = buildingId;
         if(isGift)
         {
            m_storedOrigin = Global.world.GIFTBOX_ID;
         }
         else
         {
            m_storedOrigin = buildingId;
         }
         super(itemName,isGift,buildingId,repopGift);
      }
      
      override protected function getSelectedObjectClassInstance() : Building
      {
         this.m_animalCrate = new MutableAnimalCrate(m_buildingType);
         if(Boolean(this.m_babyMetadata) && this.m_babyMetadata != "")
         {
            this.m_animalCrate.setMetadata(this.m_babyMetadata);
         }
         return this.m_animalCrate;
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var featureBuilding:FeatureBuilding = Global.world.getObjectById(m_cid) as FeatureBuilding;
         if(featureBuilding != null)
         {
            featureBuilding.lastMetaHashRemoved = this.m_animalCrate.getMetadataKey();
            featureBuilding.lastMetadataRemoved = this.m_babyMetadata;
         }
         return Boolean(super.onMouseUp(event));
      }
   }
}

