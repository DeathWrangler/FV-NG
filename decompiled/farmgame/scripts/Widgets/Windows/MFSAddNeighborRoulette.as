package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetNeighborInviteFriends;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   
   public class MFSAddNeighborRoulette extends MFSAddNeighborBase
   {
      
      private static const STATS_CATEGORY:String = "neighbor_add_mfs";
      
      public function MFSAddNeighborRoulette(source:String, completeCallback:Function)
      {
         super({"NO_TABS":[MFSConstants.NO_TABS]},source,completeCallback);
      }
      
      override protected function addBackgroundScene() : void
      {
         var scene:ZwFrame = new ZwFrame(m_window.mc_scene);
         scene.addWidget(new ZwWidget(scene.element.mc_bg2));
         addWidget(scene);
      }
      
      override protected function setWindowDescription() : void
      {
         if(Boolean(m_window) && m_window.hasOwnProperty("txt_body"))
         {
            m_descriptionTextField.text = ZLocUtils.t("Dialogs",m_MFSTypeString + "_Message");
         }
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetNeighborInviteFriends(onFriendPopulation),true);
      }
   }
}

