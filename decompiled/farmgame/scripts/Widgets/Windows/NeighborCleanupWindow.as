package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import flash.events.Event;
   
   public class NeighborCleanupWindow extends FarmWindow
   {
      
      public function NeighborCleanupWindow()
      {
         super("assets/dialogs/FV_motd_permissions.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            m_window.mainWindow.visible = true;
            if(m_window.mainWindow.hasOwnProperty("accept_bt"))
            {
               addWidget(new FarmAnimatedButton(m_window.mainWindow.accept_bt,this.handleYesClicked));
            }
            if(m_window.mainWindow.hasOwnProperty("accept2_bt"))
            {
               addWidget(new FarmAnimatedButton(m_window.mainWindow.accept2_bt,this.onClose));
            }
         }
         FarmStatsManager.count("dialog","neighbor_cleanup","ui","","view");
      }
      
      private function handleYesClicked(e:Event) : void
      {
         close();
         TransactionManager.addTransaction(new TGenericTransaction("UserService","cullOldNeighbors",this.handleTransactionReturned));
         FarmStatsManager.count("dialog","neighbor_cleanup","ui","","clicked");
      }
      
      private function handleTransactionReturned(result:Object) : void
      {
         UI.displayMessage(ZLocUtils.t("FarmGame","NeighborCleanup"),GenericPopup.TYPE_OK,this.handlePopupReturn,"",true);
      }
      
      private function handlePopupReturn(e:Event) : void
      {
         var url:String = "index.php?ref=flashRedirectHome";
         Global.farmSocialNetwork.redirectTop(url);
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("dialog","neighbor_cleanup","ui","","close");
         super.onClose(event);
      }
   }
}

