package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class ImageProgressionFLevelObject extends BaseImageProgressionObject
   {
      
      public function ImageProgressionFLevelObject(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function setProgression() : void
      {
         var storageLevel:int = m_owner.storageLevel;
         if(storageLevel > 3)
         {
            storageLevel = 3;
         }
         m_owner.setOverlayOverride(storageLevel,false);
      }
   }
}

