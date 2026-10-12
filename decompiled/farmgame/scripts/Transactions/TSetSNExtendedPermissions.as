package Transactions
{
   public class TSetSNExtendedPermissions extends TFarmTransaction
   {
      
      private var m_permissions:Object = {};
      
      public function TSetSNExtendedPermissions(permissions:Object)
      {
         this.m_permissions = permissions;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("SNPermissionsService.setSNExtendedPermissions",this.m_permissions);
      }
   }
}

