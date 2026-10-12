package Classes.Idle
{
   import Classes.CIPStartNow;
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   
   public class AddFbFriendsAsNeighborsTask extends BaseIdleTask
   {
      
      public function AddFbFriendsAsNeighborsTask(params:Object = null)
      {
         super(params);
         m_displaysPopup = true;
      }
      
      override public function get requireMouseIdle() : Boolean
      {
         return false;
      }
      
      override public function get requirePopupQueueEmpty() : Boolean
      {
         return true;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return true;
      }
      
      override public function get shouldAdd() : Boolean
      {
         if(!super.isEligibleForPopups())
         {
            return false;
         }
         if(CIPStartNow.shouldAutoNeighbor())
         {
            return true;
         }
         return false;
      }
      
      override public function fire() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("NeighboringService","addFacebookFriendsAsNeighbors",this.fireCallback));
      }
      
      private function fireCallback(result:Object) : void
      {
         var showedDialog:Boolean = false;
         var uid:String = null;
         var friend:Friend = null;
         if(result != null && result is Array)
         {
            showedDialog = false;
            for each(uid in result)
            {
               friend = Global.friendManager.promoteFriendToNeighbor({"uid":uid});
               if(CIPStartNow.shouldAutoNeighbor())
               {
                  if(Boolean(friend) && !showedDialog)
                  {
                     UI.displayPopup(new GenericIconPopup(ZLocUtils.t("Dialogs","friendAdded",{"friend":friend.firstName}),GenericPopup.TYPE_OK,null,friend.picture,false,false),false);
                     showedDialog = true;
                  }
               }
            }
         }
      }
   }
}

