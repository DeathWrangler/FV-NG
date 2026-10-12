package Classes.LockedExplanations
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.MOTD;
   import Display.UI;
   import Events.GenericPopupEvent;
   
   public class MOTDLockedExplanationHandler extends LockedExplanationHandler
   {
      
      private var m_customActionParams:Object;
      
      public function MOTDLockedExplanationHandler()
      {
         super();
      }
      
      override public function execute(customActionParams:Object = null) : void
      {
         this.m_customActionParams = customActionParams;
         UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs",customActionParams.message_quantity,{"quantity":customActionParams.lastQuantity}),GenericPopup.TYPE_ACCEPTCANCEL,this.displayMOTD),false);
      }
      
      private function displayMOTD(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.closeMarketDialog();
            MOTD.displayMOTD(this.m_customActionParams,false,null,null,false);
         }
      }
   }
}

