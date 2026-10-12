package Classes.MOTD
{
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.UI;
   import Widgets.Windows.Collections.CollectionsWindow;
   
   public class CollectionsOffBoardMOTDHandler extends MOTDHandler
   {
      
      protected static const MOTD_DIALOG_NAME_NORMAL:String = "Motdspringbasket2011";
      
      private static const ONBOARD_DIALOG_URL:String = "assets/dialogs/4d_elements/Collections/Collections_offboarding.png";
      
      public function CollectionsOffBoardMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         var title:String = ZLocUtils.t("Dialogs","MOTD_Collections_Title");
         var text:String = "";
         var buttonText:String = "";
         var flowPrefix:String = "";
         text = ZLocUtils.t("Dialogs","MOTD_Collections_Text");
         buttonText = ZLocUtils.t("Dialogs","MOTD_Collections_ButtonText");
         var params:Array = [ONBOARD_DIALOG_URL,text,title,buttonText];
         var displayPopup:DataDrivenOkayPopup = new DataDrivenOkayPopup(MOTD_DIALOG_NAME_NORMAL,params,this.acceptMOTD);
         UI.displayPopup(displayPopup,false);
         super.execute();
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         UI.displayPopup(new CollectionsWindow());
      }
   }
}

