package Transactions
{
   import Classes.util.FacebookSocialNetwork;
   import Managers.FarmStatsManager;
   
   public class TRevokeEmailPermission extends TFarmTransaction
   {
      
      private var m_onFinishEmailPermissionsCallback:Function = null;
      
      private var m_permissionSource:int = 0;
      
      private var m_statCategory:String = null;
      
      public function TRevokeEmailPermission(finishEmailPermissionCallback:Function = null, permissionSource:int = 0, statCategory:String = null)
      {
         super();
         this.m_permissionSource = permissionSource;
         if(finishEmailPermissionCallback != null)
         {
            this.m_onFinishEmailPermissionsCallback = finishEmailPermissionCallback;
         }
         if(statCategory != null)
         {
            this.m_statCategory = statCategory;
         }
      }
      
      override public function perform() : void
      {
         signedCall("ZAPIClientService.revokeEmailPermission");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).showEmailPermissionWithSource(this.m_onFinishEmailPermissionsCallback,this.m_permissionSource);
            if(this.m_statCategory != null)
            {
               FarmStatsManager.count("emailPermission","allow_email",this.m_statCategory);
            }
         }
      }
   }
}

