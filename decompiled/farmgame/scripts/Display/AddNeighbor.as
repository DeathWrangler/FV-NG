package Display
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import flash.events.Event;
   
   public class AddNeighbor extends DataDrivenOkayPopup
   {
      
      protected const ICON_ASSET_URL:String = "assets/dialogs/4d_elements/FTUE/addNeighbors.png";
      
      protected const DIALOG_NAME:String = "FTUE_AddNeighbors";
      
      public function AddNeighbor()
      {
         var params:Array = [ZLocUtils.t("Dialogs","AddNeighbor_Title"),this.ICON_ASSET_URL,ZLocUtils.t("Dialogs","AddNeighbor_Text"),ZLocUtils.t("Dialogs","AddNeighbor_Button")];
         super(this.DIALOG_NAME,params);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         FarmStatsManager.count("Tutorial","add_neighbors","impressions");
      }
      
      override protected function onAccept(event:Event) : void
      {
         event.stopPropagation();
         close();
         FarmStatsManager.count("Tutorial","add_neighbors","click_ok");
         MFSRequestManager.getInstance().displayR2AddNeighborWindow();
      }
   }
}

