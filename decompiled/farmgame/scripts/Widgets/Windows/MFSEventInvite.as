package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.IncentivizedEventsManager;
   import Transactions.TGenericTransaction;
   
   public class MFSEventInvite extends MFSWindow
   {
      
      private static const DEFAULT_STARTDAY:int = 0;
      
      private static const DEFAULT_ENDDAY:int = 30;
      
      private var m_inviteCompletedCallback:Function = null;
      
      private var m_startDay:int;
      
      private var m_endDay:int;
      
      public function MFSEventInvite(sendCallback:Function, source:String, ref:String = "fb_event_invite_mfs", startDay:int = 0, endDay:int = 30)
      {
         this.m_startDay = startDay;
         this.m_endDay = endDay;
         var friendSpec:Object = {"tabNameSuggested":[MFSConstants.TYPE_SUGGESTED]};
         var friendTabOrder:Array = ["tabNameSuggested"];
         this.m_inviteCompletedCallback = sendCallback;
         super(friendSpec,friendTabOrder,null,null,MFSConstants.MFS_TYPE_EVENT_INVITE,source,MFSConstants.MFS_TYPE_EVENT_INVITE);
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("IncentivizedEventsService","getFriendsForEventInvite",onFriendPopulation,[new Array(convertToUniqueValuesArray(friendSpec)),this.m_startDay,this.m_endDay]));
      }
      
      override protected function sendRequest(requestData:String, requestMessage:String, requestTitle:String, uids:Array, source:String, fbResponseHandler:Function) : void
      {
         m_attemptedSendUIDs = uids;
         m_numItemsSent[m_currentTab] += uids.length;
         this.m_inviteCompletedCallback(uids);
         this.invalidate(uids);
         showNextBatchOfFriends(false);
         refresh(false);
      }
      
      private function invalidate(uids:Array) : void
      {
         var friendType:String = null;
         var friendTypeLength:int = 0;
         var i:int = 0;
         var uidLength:int = int(uids.length);
         for(var invalidateUID:int = 0; invalidateUID < uidLength; invalidateUID++)
         {
            for(friendType in m_friends)
            {
               friendTypeLength = int(m_friends[friendType].length);
               for(i = 0; i < friendTypeLength; i++)
               {
                  if(uids[invalidateUID] == m_friends[friendType][i].uid)
                  {
                     m_friends[friendType][i].valid = false;
                  }
               }
            }
         }
      }
      
      override protected function getMessageText() : String
      {
         var dialogPrefix:String = IncentivizedEventsManager.instance.dialogPrefix;
         return ZLocUtils.t("Dialogs","MOTD_" + dialogPrefix + "_invite_title");
      }
      
      override protected function setWindowDescription() : void
      {
      }
      
      override protected function addCornerContents() : void
      {
      }
   }
}

