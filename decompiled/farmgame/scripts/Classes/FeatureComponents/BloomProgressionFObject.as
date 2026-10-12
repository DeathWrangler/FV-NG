package Classes.FeatureComponents
{
   import Classes.Constants.BloomConstants;
   import Classes.FeatureBuilding;
   
   public class BloomProgressionFObject extends BaseImageProgressionObject
   {
      
      public function BloomProgressionFObject(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function setProgression() : void
      {
         var worldTime:Number = NaN;
         var builtNumber:int = int(BloomConstants.BULB);
         var state:String = m_owner.getState();
         if(m_owner.getItem().subType == BloomConstants.FULL_BLOOM_SUBTYPE)
         {
            if(state == FeatureBuilding.STATE_RIPE || state == FeatureBuilding.STATE_DISPLAY)
            {
               builtNumber = int(BloomConstants.FULL_BLOOM_RIPE);
            }
            else
            {
               builtNumber = int(BloomConstants.FULL_BLOOM_BARE);
            }
         }
         else if(Boolean(m_owner.expand) && Boolean(m_owner.expand.storageLevel == 1) && state != FeatureBuilding.STATE_DISPLAY)
         {
            if(m_owner.getTotalExpansionPartCount() > m_owner.getNumberOfPartsNeeded() / 2)
            {
               builtNumber = int(BloomConstants.BULB_HALF_DONE);
            }
         }
         else if(Boolean(m_owner.expand) && Boolean(m_owner.expand.storageLevel >= 2) || state == FeatureBuilding.STATE_DISPLAY)
         {
            worldTime = Global.worldTime;
            if(state == FeatureBuilding.STATE_RIPE || state == FeatureBuilding.STATE_DISPLAY)
            {
               builtNumber = int(BloomConstants.SINGLE_BLOOM_RIPE);
            }
            else if(state == FeatureBuilding.STATE_WITHERED)
            {
               builtNumber = int(BloomConstants.WITHERED);
            }
            else
            {
               builtNumber = int(BloomConstants.SINGLE_BLOOM_BARE);
            }
         }
         m_owner.setOverlayOverride(builtNumber + 1,false);
      }
   }
}

