package Classes.consumables
{
   import AvatarMode.AMAirplane;
   import Classes.Airplane;
   import Classes.Consumable;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.InstagrowHelper;
   import Managers.MapResourceHelper;
   import Transactions.TUseConsumable;
   
   public class CInstantGrowFlight extends Consumable
   {
      
      private var m_plane:Airplane;
      
      private var m_instagrowHelper:InstagrowHelper;
      
      private var m_isGift:Boolean;
      
      public function CInstantGrowFlight(itemName:String)
      {
         super(itemName);
      }
      
      override public function isOptimistic() : Boolean
      {
         return true;
      }
      
      override public function onFailedPerform() : void
      {
         super.onFailedPerform();
         var errorMessage:String = null;
         if(this.m_plane == null)
         {
            errorMessage = ZLocUtils.t("Dialogs","InstantGrowConsumable_NoAirplaneBody");
            UI.displayMessage(errorMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onNoAirplaneFound);
         }
         else if(!this.m_instagrowHelper.hasResourcesToActOn())
         {
            errorMessage = ZLocUtils.t("Dialogs","InstantGrowConsumable_NoCropsBody");
            UI.displayMessage(errorMessage,GenericPopup.ACCEPT);
         }
      }
      
      override public function onUse() : void
      {
         Global.selectedAvatar.getStateMachine().addState(new AMAirplane(Global.selectedAvatar,this.m_instagrowHelper,this.m_plane,false),true);
      }
      
      override public function canUse() : Boolean
      {
         return Boolean(this.m_plane) && Boolean(this.m_instagrowHelper) && this.m_instagrowHelper.hasResourcesToActOn();
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         var message:String = null;
         this.setPlaneAndCropData();
         if(this.canUse() == true)
         {
            this.m_isGift = isGift;
            message = ZLocUtils.t("Dialogs","InstantGrowConsumable_ConfirmBody");
            UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmUse);
         }
         else
         {
            this.onFailedPerform();
         }
      }
      
      private function setPlaneAndCropData() : void
      {
         var planes:Array = Global.world.getObjectsByClass(Airplane);
         if(planes.length > 0)
         {
            this.m_plane = planes[0];
         }
         else
         {
            this.m_plane = null;
         }
         this.m_instagrowHelper = new InstagrowHelper(MapResourceHelper.TYPE_PLOTS | MapResourceHelper.TYPE_TREES);
      }
      
      private function onNoAirplaneFound(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            UI.displayMarketDialog("instantGrowFlightConsumable","vehicle");
         }
      }
      
      private function onConfirmUse(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            TransactionManager.addTransaction(new TUseConsumable(this,this.m_isGift));
         }
      }
   }
}

