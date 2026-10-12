package GameMode
{
   import Classes.Building;
   import Classes.FeatureBuilding;
   import Classes.MysterySeedling;
   import flash.events.MouseEvent;
   
   public class GMMysterySeedlingPlace extends GMBuild
   {
      
      private var m_seedling:MysterySeedling;
      
      private var m_seedlingMetadata:String;
      
      public function GMMysterySeedlingPlace(metadata:Object, itemName:String = null, isGift:Boolean = false, buildingId:Number = 0, repopGift:Boolean = true)
      {
         this.m_seedlingMetadata = metadata as String;
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
         this.m_seedling = new MysterySeedling(m_buildingType);
         if(Boolean(this.m_seedlingMetadata) && this.m_seedlingMetadata != "")
         {
            this.m_seedling.setMetadata(this.m_seedlingMetadata);
         }
         return this.m_seedling;
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var featureBuilding:FeatureBuilding = Global.world.getObjectById(m_cid) as FeatureBuilding;
         if(Boolean(featureBuilding) && Boolean(this.m_seedling) && Boolean(this.m_seedlingMetadata))
         {
            featureBuilding.lastMetaHashRemoved = this.m_seedling.getMetadataKey();
            featureBuilding.lastMetadataRemoved = this.m_seedlingMetadata;
         }
         return Boolean(super.onMouseUp(event));
      }
   }
}

