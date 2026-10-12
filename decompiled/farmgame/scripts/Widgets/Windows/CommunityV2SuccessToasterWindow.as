package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class CommunityV2SuccessToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_CommunityV2_toaster.swf";
      
      public function CommunityV2SuccessToasterWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var toasterText:String = ZLocUtils.t("Dialogs","CommunityNeighborsV2_Toaster_Text");
         var toasterTitle:String = ZLocUtils.t("Dialogs","CommunityNeighborsV2_Toaster_Title");
         var toasterBodyText:ZwTextField = new ZwTextField(m_window.description_tf,toasterText,true);
         addWidget(toasterBodyText);
         var toasterTitleText:ZwTextField = new ZwTextField(m_window.title_tf,toasterTitle,true);
         addWidget(toasterTitleText);
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("MOTD","click","Community_v2_toaster_x");
         super.onClose(event);
      }
   }
}

