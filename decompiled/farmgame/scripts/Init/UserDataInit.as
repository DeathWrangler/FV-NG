package Init
{
   import Classes.FarmSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Engine.Init.InitializationAction;
   import Engine.Managers.TransactionManager;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   
   public class UserDataInit extends InitializationAction
   {
      
      public static var m_userData:Object;
      
      public static const INIT_ID:String = "UserDataInit";
      
      public function UserDataInit()
      {
         super(INIT_ID);
      }
      
      public static function getFirstName() : String
      {
         var result:String = "";
         if(m_userData.hasOwnProperty("first_name"))
         {
            result = m_userData["first_name"];
         }
         return result;
      }
      
      override public function execute() : void
      {
         try
         {
            m_userData = ExternalInterface.call("getUserInfo");
            this.postExecute();
            dispatchEvent(new Event(Event.COMPLETE));
         }
         catch(e:ReferenceError)
         {
            FarmGameUtil.reportClientLog("JavaScript Call getUserInfo failed in UserDataInit::execute");
         }
      }
      
      private function postExecute() : void
      {
         TransactionManager.additionalSignedParams.masterId = GlobalEngine.getFlashVar("master_id");
         if(TransactionManager.additionalSignedParams.masterId == null)
         {
            TransactionManager.additionalSignedParams.masterId = GlobalEngine.getFlashVar("fb_sig_user");
         }
         TransactionManager.additionalSignedParams.snId = FarmSocialNetwork.SNID_FACEBOOK;
         TransactionManager.additionalSignedParams.uid = GlobalEngine.getFlashVar("fb_sig_user");
         TransactionManager.additionalSignedParams.sigTime = GlobalEngine.getFlashVar("fb_sig_time");
         if(TransactionManager.additionalSignedParams.sigTime == null)
         {
            TransactionManager.additionalSignedParams.sigTime = NaN;
         }
         TransactionManager.additionalSignedParams.token = GlobalEngine.getFlashVar("token") as String;
         TransactionManager.additionalSignedParams.authBypass = GlobalEngine.getFlashVar("authBypass");
      }
   }
}

