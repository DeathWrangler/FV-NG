package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetFriendSetFriends;
   import Transactions.TSendFriendSetRequest;
   import com.adobe.serialization.json.JSON;
   
   public class MFSFriendSet extends MFSWindow
   {
      
      public static const MFS_TYPE:String = "MFSFriendSetRequest";
      
      private var m_featureName:String;
      
      private var m_friendSetCode:String;
      
      private var m_currentFriendSet:String;
      
      public function MFSFriendSet(friendSpec:Object, friendTabOrder:Array, requestItem:FarmItem, featureName:String, friendSetCode:String, currentFriendSet:String, source:String, completeCallback:Function)
      {
         m_friendSpec = friendSpec;
         this.m_featureName = featureName;
         m_requestItem = requestItem;
         this.m_friendSetCode = friendSetCode;
         this.m_currentFriendSet = currentFriendSet;
         super(m_friendSpec,friendTabOrder,requestItem,completeCallback,MFS_TYPE,source,featureName);
      }
      
      override protected function getMessageText() : String
      {
         var message:String = null;
         var localizationKey:String = "MFSWindow_" + this.m_featureName + "_Message";
         if(ZLocUtils.hasString("Dialogs",localizationKey))
         {
            message = ZLocUtils.t("Dialogs",localizationKey);
         }
         else
         {
            message = super.getMessageText();
         }
         return message;
      }
      
      override protected function getRequestData() : String
      {
         var requestData:Array = [];
         m_serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_FRIENDSET);
         requestData.push(this.m_featureName);
         requestData.push(this.m_friendSetCode);
         requestData.push(m_requestItem.name);
         requestData.push(this.m_currentFriendSet);
         requestData.push(m_serverTime);
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
      
      override protected function getRequestMessage(currentTabName:String) : String
      {
         return ZLocUtils.t_pk("Gifts",this.m_featureName + "_ask_request_text",{
            "item":ZLocUtils.tk_pk(m_requestItem.friendlyName),
            "APP_NAME":ZLocUtils.tk_pk_asTitle("FarmVille:FarmvilleText")
         });
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetFriendSetFriends(convertToUniqueValuesArray(m_friendSpec),this.m_featureName,this.m_friendSetCode,this.m_currentFriendSet,onFriendPopulation),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendFriendSetRequest(m_requestItem.name,this.m_featureName,this.m_friendSetCode,this.m_currentFriendSet,requestIds,m_source,m_serverTime,m_completeCallback),true);
      }
   }
}

