package Classes.buffs
{
   import Classes.Quest.PrerequisiteUtility;
   import Managers.FarmGameSettingsManager;
   
   public class BWalkSpeedPrereq extends BWalkSpeed
   {
      
      public function BWalkSpeedPrereq(itemName:String)
      {
         super(itemName);
      }
      
      override public function isExpired() : Boolean
      {
         var prereqsDS:Array = null;
         var prereqs:XMLList = null;
         var result:Boolean = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            prereqsDS = getItem().getArrayFromDataSource("prereq","prereqs");
            if(prereqsDS.length > 0)
            {
               result = !PrerequisiteUtility.evalPrereqsData(prereqsDS);
            }
         }
         else
         {
            prereqs = getItem().xml.prereqs.prereq;
            if(prereqs != null)
            {
               result = !PrerequisiteUtility.evalPrereqsXML(prereqs);
            }
         }
         return result;
      }
   }
}

