package Display
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class LockedBoxUncoveredDialog extends GenericIconPopup
   {
      
      public function LockedBoxUncoveredDialog()
      {
         super(ZLocUtils.t("Dialogs","LockedBoxUncovered"),GenericPopup.TYPE_ACCEPTCANCEL,null,Global.getAssetURL("assets/decorations/deco_lockedbox_icon.png"),false,false,"");
         FarmStatsManager.count("email_locked_box","granted","locked_box");
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_accept = new GenericButton(m_window.popupBox_mc.share_bt,this.onAccept);
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         UI.displayGiftBoxWindow();
         close();
      }
   }
}

