package Classes.MOTD
{
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.TrickOrTreatManager;
   import Widgets.Windows.TrickOrTreatWindow;
   
   public class TrickOrTreatMOTDHandler extends BaseDialogMOTDHandler
   {
      
      public function TrickOrTreatMOTDHandler(currentMOTD:Object)
      {
         FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,"MOTD","impression");
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,"MOTD","clicks","okay");
         super.acceptMOTD();
         if(!Global.worldManager.isVisiting())
         {
            UI.displayPopup(new TrickOrTreatWindow());
         }
      }
   }
}

