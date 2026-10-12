package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class WishingFountainWithAnimImageProgressionFObject extends WishingFountainImageProgressionFObject
   {
      
      public function WishingFountainWithAnimImageProgressionFObject(owner:FeatureBuilding)
      {
         super(owner);
         m_owner.allowAnimation = false;
      }
      
      override public function setProgression() : void
      {
         super.setProgression();
         m_owner.allowAnimation = true;
         m_owner.play();
      }
   }
}

