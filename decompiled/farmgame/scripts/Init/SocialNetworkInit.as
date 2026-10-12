package Init
{
   import Classes.Player;
   import Engine.Init.InitializationAction;
   import Engine.Managers.TransactionManager;
   import flash.events.Event;
   
   public class SocialNetworkInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "SocialNetworkInit";
      
      protected var m_skipSN:Boolean = false;
      
      public function SocialNetworkInit(skip:Boolean)
      {
         super(INIT_ID);
         this.m_skipSN = skip;
         addDependency(ZGameSettingsInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         if(this.m_skipSN)
         {
            Global.player = new Player(null);
            dispatchEvent(new Event(Event.COMPLETE));
         }
         this.postExecute();
      }
      
      protected function postExecute() : void
      {
         if(!Global.farmGame.prefetchTInitUserOn)
         {
            TransactionManager.additionalSignedParams.masterId = Global.farmSocialNetwork.getLoggedInMasterId();
            TransactionManager.additionalSignedParams.snId = Global.farmSocialNetwork.getSocialNetworkId();
            TransactionManager.additionalSignedParams.uid = Global.farmSocialNetwork.getLoggedInUserId();
            TransactionManager.additionalSignedParams.sigTime = Global.farmSocialNetwork.getSigTime();
            TransactionManager.additionalSignedParams.token = GlobalEngine.getFlashVar("token") as String;
            TransactionManager.additionalSignedParams.authBypass = GlobalEngine.getFlashVar("authBypass");
         }
      }
   }
}

