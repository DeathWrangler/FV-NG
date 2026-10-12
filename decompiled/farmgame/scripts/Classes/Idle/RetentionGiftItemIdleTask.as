package Classes.Idle
{
   import Managers.RetentionGiftItemUtil;
   import Managers.RetentionMasterManager;
   
   public class RetentionGiftItemIdleTask extends BaseIdleTask
   {
      
      public function RetentionGiftItemIdleTask(params:Object = null)
      {
         super();
      }
      
      override public function fire() : void
      {
         RetentionGiftItemUtil.awardRetentionGifts();
      }
      
      override public function get shouldAdd() : Boolean
      {
         return RetentionMasterManager.inMasterExperiment();
      }
   }
}

