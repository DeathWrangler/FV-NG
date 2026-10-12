package Managers
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   
   public class BackoffLogicManager
   {
      
      public function BackoffLogicManager()
      {
         super();
      }
      
      public static function checkAndUpdateBackoffPrereq(backoffPrereq:String) : Boolean
      {
         var result:Boolean = false;
         if(checkBackoffPrereq(backoffPrereq))
         {
            updateDataFromNamedPrereq(backoffPrereq);
            result = true;
         }
         return result;
      }
      
      public static function checkBackoffPrereq(backoffPrereq:String) : Boolean
      {
         return PrerequisiteUtility.checkPrereqByName(backoffPrereq);
      }
      
      public static function updateDataFromNamedPrereq(backoffPrereq:String) : void
      {
         var namedPrereq:Object = Global.farmGameSettingsManager.getPrereqByName(backoffPrereq);
         updateDataFromPrereq(namedPrereq);
      }
      
      private static function updateDataFromPrereq(prereq:Object) : void
      {
         var childPrereq:Object = null;
         if(Boolean(prereq) && Boolean(prereq[FarmGameSettingsManager.XML_CHILDREN_FIELD]))
         {
            for each(childPrereq in prereq[FarmGameSettingsManager.XML_CHILDREN_FIELD])
            {
               updateDataFromPrereq(childPrereq);
            }
         }
         else
         {
            updateDataFromSinglePrereq(prereq);
         }
      }
      
      private static function updateDataFromSinglePrereq(prereq:Object) : void
      {
         if(prereq.value)
         {
            switch(prereq.type)
            {
               case "feature_frequency":
                  if(PrerequisiteUtility.isPrerequisiteMet(prereq))
                  {
                     Global.player.setFeatureLastShown(prereq.value,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
                  }
                  break;
               case "action_count":
                  if(PrerequisiteUtility.isPrerequisiteMet(prereq))
                  {
                     Global.player.incrementActionCount(prereq.value,true);
                  }
                  else
                  {
                     Global.player.setActionCount(prereq.value,1,true);
                  }
            }
         }
      }
   }
}

