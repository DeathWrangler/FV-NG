package Classes.TimedActions
{
   import Classes.AreasOfEffect.AOEBonusData;
   import Classes.MapResource;
   import Managers.AOEManager;
   
   public class AOEStateChangeTimedAction extends ArrayTimedAction
   {
      
      public function AOEStateChangeTimedAction(totalTime:Number, data:Array, index:int = 0, retryCount:int = 0)
      {
         super(totalTime,data,index,retryCount);
      }
      
      override protected function performHelper(data:Object) : Object
      {
         var bonuses:AOEBonusData = null;
         var result:MapResource = null;
         if(data is MapResource)
         {
            result = data as MapResource;
            if(result.isCurrentImageFullyLoaded())
            {
               if(result.isAoeTarget())
               {
                  bonuses = AOEManager.getInstance().computeBonusesForResource(result,false);
                  if(bonuses.possibleStates != null && bonuses.possibleStates.length > 0)
                  {
                     result.applyAoeAffects(bonuses);
                  }
                  else
                  {
                     result.unapplyAoeAffects();
                  }
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
         return AOEStateChangeTimedAction;
      }
   }
}

