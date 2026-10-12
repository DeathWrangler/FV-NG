package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class WishingFountainImageProgressionFObject extends BaseImageProgressionObject
   {
      
      public static const BUILT_STATE_PREFIX:String = "built_";
      
      private var m_builtStates:Vector.<int> = new Vector.<int>();
      
      public function WishingFountainImageProgressionFObject(owner:FeatureBuilding)
      {
         super(owner);
         this.m_builtStates = owner.getImageStates(BUILT_STATE_PREFIX);
      }
      
      override public function setProgression() : void
      {
         if(this.m_builtStates.length > 0)
         {
            m_owner.setOverlayOverride(m_owner.getCorrectSuffix(this.m_builtStates),false);
         }
      }
   }
}

