package Widgets.Windows.Clubs
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.AutoCloseToasterWindow;
   
   public class FarmClubToaster extends AutoCloseToasterWindow
   {
      
      private static const HORIZONTAL_OFFSET:int = 25;
      
      private static const ASSET_PATH:String = "assets/dialogs/fv_clubs_toaster.swf";
      
      public function FarmClubToaster()
      {
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("FarmClub","toasterText")));
      }
      
      override protected function positionToasterWindow() : void
      {
         super.positionToasterWindow();
         this.x += HORIZONTAL_OFFSET;
      }
   }
}

