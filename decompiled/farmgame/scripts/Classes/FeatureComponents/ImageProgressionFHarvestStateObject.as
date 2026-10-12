package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class ImageProgressionFHarvestStateObject extends BaseImageProgressionObject
   {
      
      public function ImageProgressionFHarvestStateObject(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function setProgression() : void
      {
         var level:int = m_owner.getState() == FeatureBuilding.STATE_BARE ? 1 : 2;
         m_owner.setOverlayOverride(level,false);
      }
   }
}

