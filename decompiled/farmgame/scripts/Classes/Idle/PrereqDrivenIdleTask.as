package Classes.Idle
{
   import Classes.Quest.PrerequisiteUtility;
   
   public class PrereqDrivenIdleTask extends BaseIdleTask
   {
      
      protected var m_featureName:String;
      
      public function PrereqDrivenIdleTask(featureName:String)
      {
         super();
         this.m_featureName = featureName;
      }
      
      override public function get canFire() : Boolean
      {
         return Boolean(this.m_featureName) && PrerequisiteUtility.checkPrereqByName(this.m_featureName + "_idle_task_prereq");
      }
   }
}

