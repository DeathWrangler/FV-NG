package Widgets
{
   import Classes.Quest.FarmQuest;
   import Init.Worlds.VillageWorldInit;
   import Widgets.Windows.FarmWindowWithTutorial;
   
   public class FarmVillageFTUEWindow extends FarmWindowWithTutorial
   {
      
      private static const FTUE_FEATURE:String = "FarmVillageFTUEWindow";
      
      private static const FTUE_ASSET:String = "assets/dialogs/Village/FV_village_FTUE.swf";
      
      public function FarmVillageFTUEWindow()
      {
         super(FTUE_FEATURE,FTUE_ASSET,4);
      }
      
      override protected function hideTutorial() : void
      {
         super.hideTutorial();
         var activeQuest:FarmQuest = VillageWorldInit.findActiveFTUEQuest();
         if(activeQuest)
         {
            activeQuest.showProgress();
         }
         this.close();
      }
   }
}

