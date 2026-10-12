package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import flash.events.MouseEvent;
   
   public class MysteryGiftPopup extends MysteryPopup
   {
      
      public function MysteryGiftPopup(closeCallback:Function = null, item:FarmItem = null, lootableItemName:String = "MysteryGift", openGift:Boolean = false)
      {
         super(MysteryPopup.TYPE_CONFIRM,closeCallback,item,lootableItemName,openGift);
         m_acceptButtonText = ZLocUtils.t("Dialogs","Accept");
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_reject = new GenericButton(m_window.mysteryBox_mc.cancel_bt,this.onCancel);
         m_reject.text = ZLocUtils.t("Dialogs","Cancel");
      }
      
      override protected function onCancel(event:MouseEvent) : void
      {
         if(m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,m_closeCallback);
         }
         if(m_openGiftBox)
         {
            UI.displayGiftBoxWindow(false);
         }
         close();
      }
      
      override protected function onOkClick(event:MouseEvent) : void
      {
         super.onOkClick(event);
         close();
         FreeGiftSelectionWindow.popWindow();
      }
   }
}

