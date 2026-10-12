package Transactions
{
   import Engine.Managers.ErrorManager;
   
   public class TCompleteSocialPlumbingAction extends TFarmTransaction
   {
      
      protected var m_className:String = "";
      
      protected var m_targetFriendId:String = "";
      
      public function TCompleteSocialPlumbingAction(className:String, targetFriendId:String)
      {
         if(!GlobalEngine.getFlashVar("OPS_SOCIAL_PLUMBING_CLEANUP_TMPRT"))
         {
            super();
            this.m_className = className;
            this.m_targetFriendId = targetFriendId;
         }
         if(GlobalEngine.getFlashVar("OPS_SOCIAL_PLUMBING_CLEANUP_LOGGING_TMPRT"))
         {
            ErrorManager.addInfo("SocialPlumingService cleanup: TCompleteSocialPlumbingAction still in use");
         }
      }
      
      override public function perform() : void
      {
         signedCall("SocialPlumbingService.updateDailyTask",this.m_className,this.m_targetFriendId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
         }
      }
   }
}

