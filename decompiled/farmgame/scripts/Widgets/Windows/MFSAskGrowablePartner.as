package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetAskItemFriends;
   
   public class MFSAskGrowablePartner extends MFSAskItems
   {
      
      private var m_callback:Function;
      
      private var m_friendIds:Array;
      
      public function MFSAskGrowablePartner(friendSpec:Object, friendTabOrder:Array, requestItem:FarmItem, featureName:String, source:String, completeCallback:Function)
      {
         this.m_callback = completeCallback;
         m_MFSType = "MFSAskPartner";
         super(friendSpec,friendTabOrder,requestItem,featureName,source,null);
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetAskItemFriends(MFSConstants.FB_REQ2_REQUESTTYPE_ASKGROAWBLE,"GrowableContest",m_requestItem.name,convertToUniqueValuesArray(m_friendSpec),onFriendPopulation),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         this.m_callback(this.m_friendIds);
      }
      
      override protected function onSend() : void
      {
         this.m_friendIds = m_friendsSlotFrame.getSelectedFriends();
         super.onSend();
      }
      
      override protected function getMessageText() : String
      {
         return ZLocUtils.t("Dialogs",m_featureName + "_MFS_Subtitle");
      }
      
      override protected function getRequestMessage(currentTabName:String) : String
      {
         return ZLocUtils.t("Dialogs",m_featureName + "_Request_Message");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         m_titleTextField.text = ZLocUtils.t("Dialogs",m_featureName + "_MFS_Title");
      }
      
      override protected function getRequestTitle() : String
      {
         return ZLocUtils.t("Dialogs",m_featureName + "_MFS_Title");
      }
   }
}

