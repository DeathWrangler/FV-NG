package Classes.FeatureComponents
{
   import Classes.Constants.BlossomConstants;
   import Classes.FeatureBuilding;
   
   public class FlowerShackProgressionFObject extends BloomProgressionFObject
   {
      
      public function FlowerShackProgressionFObject(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function setProgression() : void
      {
         var builtNumber:int = int(BlossomConstants.BLOSSOM_RIPE);
         var state:String = m_owner.getState();
         if(m_owner.getItem().subType == BlossomConstants.FULL_BLOSSOM_SUBTYPE)
         {
            if(state == FeatureBuilding.STATE_RIPE || state == FeatureBuilding.STATE_DISPLAY)
            {
               builtNumber = int(BlossomConstants.BOQUET_RIPE);
            }
            else if(state == FeatureBuilding.STATE_WITHERED)
            {
               builtNumber = int(BlossomConstants.BOQUET_WITHERED);
            }
         }
         else if(m_owner.getItem().subType == BlossomConstants.SINGLE_BLOSSOM_SUBTYPE)
         {
            if(state == FeatureBuilding.STATE_RIPE || state == FeatureBuilding.STATE_DISPLAY)
            {
               builtNumber = int(BlossomConstants.BLOSSOM_RIPE);
            }
            else if(state == FeatureBuilding.STATE_WITHERED)
            {
               builtNumber = int(BlossomConstants.BLOSSOM_WITHERED);
            }
         }
         m_owner.setOverlayOverride(builtNumber + 1,false);
      }
   }
}

