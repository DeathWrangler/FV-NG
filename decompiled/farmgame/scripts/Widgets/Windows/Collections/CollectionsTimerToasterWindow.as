package Widgets.Windows.Collections
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Windows.TimerToasterWindow;
   
   public class CollectionsTimerToasterWindow extends TimerToasterWindow
   {
      
      protected static const POPUP_NAME:String = "expiringToaster";
      
      protected static const COLLECTIONS_POPUP_TIME_TO_LIVE:Number = 15000;
      
      protected var DIALOG_ASSET:String = "assets/dialogs/FV_LimitedCollections_Toaster.swf";
      
      public function CollectionsTimerToasterWindow(endTimeSeconds:Number, collectionName:String)
      {
         super(this.DIALOG_ASSET,endTimeSeconds);
         var remainingSec:int = endTimeSeconds;
         var dayNum:int = remainingSec / 86400;
         remainingSec %= 86400;
         var hourNum:int = remainingSec / 3600;
         remainingSec %= 3600;
         var minNum:int = remainingSec / 60;
         var secNum:int = remainingSec % 60;
         var text:String = ZLocUtils.t("Dialogs","LightningCollectionsCountdownToasterTitle1",{
            "dayNum":dayNum,
            "hourNum":hourNum,
            "minNum":minNum,
            "secNum":secNum,
            "item":ZLocUtils.tk_pk(collectionName)
         });
         var testStrs:Array = ZLocUtils.splitString(text,3);
         m_titleField1 = 1 <= testStrs.length ? testStrs[0] : "";
         m_titleField2 = 2 <= testStrs.length ? testStrs[1] : "";
         m_titleField3 = 3 <= testStrs.length ? testStrs[2] : "";
         m_clickHereLink = ZLocUtils.t("Dialogs","LightningCollectionsCountdownToasterClick");
      }
      
      override protected function handleBoxClick() : void
      {
         UI.displayPopup(new CollectionsWindow());
      }
   }
}

