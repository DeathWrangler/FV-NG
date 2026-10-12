package Transactions
{
   import Classes.Constants.Experiments;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   
   public class TGetMOTD extends TFarmTransaction
   {
      
      private var m_motdSeenFlag:String = null;
      
      protected var m_onCompleteCallback:Function;
      
      public function TGetMOTD(motdSeenFlag:String, onCompleteCallback:Function = null)
      {
         super();
         this.m_motdSeenFlag = motdSeenFlag;
         this.m_onCompleteCallback = onCompleteCallback;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getMOTD",this.m_motdSeenFlag);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && !result.hasOwnProperty("error") && result.hasOwnProperty("motdData"))
         {
            if(this.m_onCompleteCallback != null)
            {
               this.m_onCompleteCallback(result.motdData);
            }
         }
         else if(result.hasOwnProperty("error"))
         {
            ErrorManager.addError("TGetMOTD server errorData on " + this.m_motdSeenFlag + ": " + result.error);
         }
         else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_IGNORE_MISSING_MOTD_ERRORS) == 1)
         {
            UI.displayMessage(ZLocUtils.t("FarmGame","RefreshGame"),GenericPopup.TYPE_OK,FarmGameUtil.redirectHome,"",true);
         }
         else
         {
            ErrorManager.addError("TGetMOTD: Server could not return MOTD: " + this.m_motdSeenFlag);
         }
      }
      
      override protected function onFault(errorType:int, errorData:String) : void
      {
         ErrorManager.addError("TGetMOTD server errorData: " + errorData);
      }
      
      override public function isFaultable() : Boolean
      {
         return false;
      }
   }
}

