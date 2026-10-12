package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import com.adobe.serialization.json.JSON;
   
   public class MFSClubInvite extends MFSWindow
   {
      
      public static const MFS_TYPE:String = "MFSFriendSetRequest";
      
      public function MFSClubInvite(friendSpec:Object, friendTabOrder:Array, source:String, completeCallback:Function)
      {
         m_friendSpec = friendSpec;
         super(m_friendSpec,friendTabOrder,null,completeCallback,MFS_TYPE,source,"FarmClubs");
      }
      
      override protected function getMessageText() : String
      {
         var message:String = null;
         var localizationKey:String = "MFSWindow_FarmClub_Message";
         if(ZLocUtils.hasString("FarmClub",localizationKey))
         {
            message = ZLocUtils.t("FarmClub",localizationKey);
         }
         return message;
      }
      
      override protected function getRequestData() : String
      {
         var requestData:Array = [];
         m_serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_FRIENDSET);
         requestData.push(m_serverTime);
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
      
      override protected function getRequestMessage(currentTabName:String) : String
      {
         return ZLocUtils.t_pk("FarmClub","FarmClub_ask_request_text",{"APP_NAME":ZLocUtils.tk_pk_asTitle("FarmVille:FarmvilleText")});
      }
      
      override protected function addCornerContents() : void
      {
      }
      
      override protected function setWindowDescription() : void
      {
         var numFriends:int = 0;
         if(Boolean(m_window) && m_window.hasOwnProperty("txt_body"))
         {
            numFriends = int(getFriendsInTab(m_tabNames[m_currentTab]).length);
            m_descriptionTextField.text = ZLocUtils.t("Dialogs",m_MFSTypeString + "_Message",{"friendCount":numFriends});
         }
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         var paramArray:Array = [convertToUniqueValuesArray(friendSpec)];
         TransactionManager.addTransaction(new TGenericTransaction("FriendListService","getFriendsForPaidGifting",onFriendPopulation,paramArray),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         var paramArray:Array = [requestIds];
         TransactionManager.addTransaction(new TGenericTransaction("FarmClubService","sendInviteRequest",m_completeCallback,paramArray),true);
      }
   }
}

