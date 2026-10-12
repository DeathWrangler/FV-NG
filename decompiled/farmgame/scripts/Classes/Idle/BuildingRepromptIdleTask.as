package Classes.Idle
{
   import Managers.BuildingManager;
   
   public class BuildingRepromptIdleTask extends BaseIdleTask
   {
      
      private var m_repromptData:Object = null;
      
      private var m_repromptLag:int = 0;
      
      private var m_mouseIdle:int = 3000;
      
      public function BuildingRepromptIdleTask(repromptData:Object, repromptLag:int = 0, mouseIdleSecs:int = 3)
      {
         this.m_repromptData = repromptData;
         this.m_repromptLag = repromptLag * 1000;
         this.m_mouseIdle = mouseIdleSecs * 1000;
         super();
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return this.m_mouseIdle;
      }
      
      override public function fire() : void
      {
         BuildingManager.getInstance().doBuildingReprompt(this.m_repromptData);
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > this.m_repromptLag;
      }
   }
}

