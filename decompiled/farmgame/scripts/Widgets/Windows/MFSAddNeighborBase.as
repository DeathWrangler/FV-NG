package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TSendRequest2NeighborInvite;
   import Widgets.Core.Base.ZwWidget;
   import com.adobe.serialization.json.JSON;
   
   public class MFSAddNeighborBase extends MFSWindow
   {
      
      public function MFSAddNeighborBase(friendSpec:Object, source:String, completeCallback:Function, assetSwf:String = "assets/dialogs/FV_MFS.swf", friendTabOrder:Array = null, statsFlowName:String = "neighbor_add_mfs")
      {
         super(friendSpec,friendTabOrder,null,completeCallback,"AddNeighborWindow",source,statsFlowName,assetSwf);
      }
      
      override protected function addCornerContents() : void
      {
         addWidget(new ZwWidget(m_window.mc_addneighborgraphic));
      }
      
      override protected function getRequestMessage(currentTabName:String) : String
      {
         return ZLocUtils.t_pk("Dialogs","AddNeighborRequestMessage");
      }
      
      override protected function getRequestTitle() : String
      {
         return ZLocUtils.t_pk("Gifts","SendRequest");
      }
      
      override protected function getProgressBarText(sentCount:int, friendCount:int) : String
      {
         return ZLocUtils.t("Dialogs",m_MFSTypeString + "_Progress",{
            "sentCount":sentCount,
            "friendCount":friendCount
         });
      }
      
      override protected function addWindowSubtitle() : void
      {
      }
      
      override protected function getRequestData() : String
      {
         var requestData:Array = [];
         m_serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_NEIGHBOR);
         requestData.push(m_serverTime);
         requestData.push(MFSConstants.STATS_ADD_NEIGHBOR);
         requestData.push(MFSConstants.VALUE_NOT_SET);
         requestData.push(MFSConstants.GAME_NAME_FARMVILLE);
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendRequest2NeighborInvite(requestIds,m_serverTime,MFSConstants.STATS_ADD_NEIGHBOR),true);
      }
   }
}

