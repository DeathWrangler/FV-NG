package Classes.TimedActions
{
   import Classes.MapResource;
   import Managers.OffboardingManager;
   
   public class FeatureBuildingDeprecationTimedAction extends TimedAction
   {
      
      public function FeatureBuildingDeprecationTimedAction(totalTime:Number, data:Object, retryCount:int = 0)
      {
         super(totalTime,data,retryCount);
      }
      
      override protected function performHelper(data:Object) : Object
      {
         var result:MapResource = null;
         if(data is MapResource)
         {
            result = data as MapResource;
            if(Global.player.postInitFinished)
            {
               if(OffboardingManager.needsOffBoardingAndReplacement(result))
               {
                  OffboardingManager.handleOffBoarding(result,false);
               }
               else
               {
                  result = null;
               }
            }
            else
            {
               result = null;
               reAddToQueue();
            }
         }
         return result;
      }
      
      override protected function getClassName() : Class
      {
         return FeatureBuildingDeprecationTimedAction;
      }
   }
}

