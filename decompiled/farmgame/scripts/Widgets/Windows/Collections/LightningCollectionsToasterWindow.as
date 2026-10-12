package Widgets.Windows.Collections
{
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class LightningCollectionsToasterWindow extends CollectionsToasterWindow
   {
      
      public function LightningCollectionsToasterWindow(collectableCode:String, shareLink:String = "")
      {
         super(collectableCode,shareLink);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var headerText:ZwTextField = getWidget(m_window.foundPopUp_mc.popUpTitle_tf) as ZwTextField;
         headerText.text = ZLocUtils.t("Dialogs","LightningCollectionsStatusTitle",{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
         var statusText:ZwTextField = getWidget(m_window.foundPopUp_mc.popUpBody_tf) as ZwTextField;
         statusText.text = ZLocUtils.t("Dialogs","LightningCollectionsStatusBody",{
            "item":ZLocUtils.tk_pk(m_item.friendlyName),
            "set":ZLocUtils.tk_pk(m_collection.friendlyName)
         });
      }
      
      override protected function displayOtherPopups() : void
      {
         var iconURL:String = null;
         var firstTimeFoundPopup:GenericIconPopup = null;
         if(!Global.player.getSeenFlag(FIRST_TIME_FOUND_KEY))
         {
            Global.player.setSeenFlag(FIRST_TIME_FOUND_KEY);
            iconURL = Global.farmGameSettingsManager.getString("genericCollectionsIconUrl");
            iconURL = Global.getAssetURL(iconURL);
            firstTimeFoundPopup = new GenericIconPopup(ZLocUtils.t("Dialogs","FirstTimeFoundCollectable"),GenericPopup.TYPE_ACCEPTCANCEL,onCollectionComplete,iconURL);
            UI.displayPopup(firstTimeFoundPopup);
         }
      }
      
      override protected function onHitBoxClick(event:MouseEvent) : void
      {
         if(event)
         {
            event.stopPropagation();
         }
         close();
         UI.displayPopup(new CollectionsWindow());
      }
   }
}

