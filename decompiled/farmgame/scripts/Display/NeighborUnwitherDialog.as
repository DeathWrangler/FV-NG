package Display
{
   import Classes.VisitorManager;
   import Classes.ZItem.FarmItem;
   import Classes.consumables.CUnwither;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TPurchaseUnwither;
   import com.troyer.widget.view.BaseWidgetView;
   
   public class NeighborUnwitherDialog extends UnwitherDialog
   {
      
      public function NeighborUnwitherDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public static function conditionallyShowUnwitherDialog() : Boolean
      {
         var unwitherDialogShown:Boolean = false;
         var unwitherDialog:NeighborUnwitherDialog = FarmDynamicDialog.createDialog("purchaseUnwitherDialog",NeighborUnwitherDialog) as NeighborUnwitherDialog;
         if(unwitherDialog != null)
         {
            unwitherDialog.initDialog();
            unwitherDialog.show();
            unwitherDialogShown = true;
         }
         return unwitherDialogShown;
      }
      
      override public function initDialog() : void
      {
         Global.player.hasSeenUnwitherPopupWorlds[Global.worldManager.currentWorldType] = true;
         m_textDialogPrefix = "neighbor_";
         setup();
      }
      
      override public function useUnwitherConsumable() : void
      {
         var unwitherConsumable:CUnwither = null;
         unwitherConsumable = new CUnwither("consume_unwither");
         unwitherConsumable.consume(true,false,VisitorManager.getInstance().visitedUserId.toString(),false);
         this.offerToPublishYourAction();
         destroy();
      }
      
      override public function buyUnwither() : void
      {
         var unwitherConsumable:CUnwither = null;
         var unwitherCost:int = UnwitherDialog.getUnwitherCost();
         TransactionManager.addTransaction(new TPurchaseUnwither(unwitherCost));
         Global.player.addGift(UNWITHER_ITEM_NAME);
         unwitherConsumable = new CUnwither("consume_unwither");
         unwitherConsumable.consume(true,false,VisitorManager.getInstance().visitedUserId.toString(),false);
         this.offerToPublishYourAction();
      }
      
      private function offerToPublishYourAction() : void
      {
         var msg:String = ZLocUtils.t("Dialogs","Unwither_prompt_share",{"user":ZLocUtils.tn(VisitorManager.getInstance().visitedUserName)});
         var genPop:GenericPopup = new GenericPopup(msg,GenericPopup.TYPE_YESNO,this.onPublishNeighbourlyUnwitherAct,GenericPopup.GENERIC_ASSET);
         genPop.setTrackerKey("unwither-share_neighbor_unwither");
         UI.displayPopup(genPop,false,"",true);
      }
      
      private function onPublishNeighbourlyUnwitherAct(event:GenericPopupEvent) : void
      {
         var unwitherConsumable:FarmItem = null;
         var iconUrl:String = null;
         var images:Array = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            unwitherConsumable = Global.farmGameSettingsManager.getFarmItemByName(UNWITHER_ITEM_NAME);
            iconUrl = unwitherConsumable.icon;
            images = [{
               "src":iconUrl,
               "href":"{SN_APP_URL}"
            }];
            GlobalEngine.socialNetwork.publishFeedStory("ShareNeighborUnwither",{"images":images},[VisitorManager.getInstance().visitedUserId],false);
         }
      }
   }
}

