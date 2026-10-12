package Classes
{
   public interface IOffboardResource
   {
      
      function needsOffBoardingAndReplacement() : Boolean;
      
      function getOffboardingReplacementResource() : MapResource;
   }
}

