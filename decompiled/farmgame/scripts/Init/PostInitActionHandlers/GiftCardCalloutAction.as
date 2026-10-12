package Init.PostInitActionHandlers
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   
   public class GiftCardCalloutAction extends AbstractPostInitAction
   {
      
      public function GiftCardCalloutAction(callback:Function)
      {
         super(callback);
      }
      
      override public function execute() : void
      {
         var giftCardItem:FarmItem = null;
         var gift:String = Global.player.getItemFlag("giftCard");
         if(gift != "")
         {
            giftCardItem = Global.farmGameSettingsManager.getFarmItemByCode(gift);
            if(giftCardItem)
            {
               UI.displayPopup(new GenericIconPopup(ZLocUtils.t("Dialogs","GiftCardPromo",{"item":ZLocUtils.tk_pk(giftCardItem.friendlyName)}),GenericPopup.TYPE_OK,m_callback,giftCardItem.icon));
            }
            Global.player.setItemFlag("giftCard","",true);
         }
         m_isFinished = true;
      }
   }
}

