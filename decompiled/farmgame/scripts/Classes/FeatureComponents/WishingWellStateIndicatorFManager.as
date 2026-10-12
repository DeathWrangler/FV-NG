package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class WishingWellStateIndicatorFManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      private static const SEEN_OFFBOARDING_WARNING:String = "wishingwell_OffboardingWarning";
      
      public static var m_postInitDataReceived:Boolean = false;
      
      public function WishingWellStateIndicatorFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function show(state:String = "default") : void
      {
      }
      
      public function showArrowIndicator() : void
      {
         this.m_owner.conditionallyRedraw(true);
      }
      
      override public function hide() : void
      {
      }
      
      override public function onMouseOver() : void
      {
      }
      
      override public function onMouseOut() : void
      {
      }
      
      override protected function setIndicatorPosition() : void
      {
      }
   }
}

