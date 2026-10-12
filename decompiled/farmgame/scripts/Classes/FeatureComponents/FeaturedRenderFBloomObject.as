package Classes.FeatureComponents
{
   import Classes.Constants.BloomConstants;
   import Classes.FeatureBuilding;
   
   public class FeaturedRenderFBloomObject extends FeaturedRenderFObject
   {
      
      public function FeaturedRenderFBloomObject(itemName:String, building:FeatureBuilding, metadata:String = "")
      {
         super(itemName,building,metadata);
      }
      
      override public function getCurrentImageName() : String
      {
         var subtype:String = null;
         var isBuildingHarvestable:Boolean = false;
         var builtNumber:uint = 0;
         var result:String = null;
         if(m_item)
         {
            subtype = m_item.subType;
            isBuildingHarvestable = m_building.isHarvestable();
            builtNumber = 0;
            if(subtype == BloomConstants.FULL_BLOOM_SUBTYPE)
            {
               builtNumber = isBuildingHarvestable ? BloomConstants.FULL_BLOOM_RIPE : BloomConstants.FULL_BLOOM_BARE;
            }
            else
            {
               builtNumber = isBuildingHarvestable ? BloomConstants.SINGLE_BLOOM_RIPE : BloomConstants.SINGLE_BLOOM_BARE;
            }
            result = "built_" + builtNumber;
         }
         return result;
      }
   }
}

