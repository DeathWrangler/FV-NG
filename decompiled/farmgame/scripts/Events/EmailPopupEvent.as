package Events
{
   public class EmailPopupEvent extends GenericPopupEvent
   {
      
      private var m_onFinishEmailPermissionsCallback:Function = null;
      
      private var m_permissionSource:int = 0;
      
      public function EmailPopupEvent(type:String, inButton:int, permissionSource:int = 0, finishEmailPermissionCallback:Function = null)
      {
         super(type,inButton);
         this.m_permissionSource = permissionSource;
         if(finishEmailPermissionCallback != null)
         {
            this.m_onFinishEmailPermissionsCallback = finishEmailPermissionCallback;
         }
      }
      
      public function get finishEmailPermissionsCallback() : Function
      {
         return this.m_onFinishEmailPermissionsCallback;
      }
      
      public function get permissionSource() : int
      {
         return this.m_permissionSource;
      }
   }
}

