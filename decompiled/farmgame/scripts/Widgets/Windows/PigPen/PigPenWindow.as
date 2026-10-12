package Widgets.Windows.PigPen
{
   import Classes.FeatureBuilding;
   import Display.TutorialUI;
   import Widgets.Windows.Breeding.BreedingWindow;
   import flash.events.MouseEvent;
   
   public class PigPenWindow extends BreedingWindow
   {
      
      private static const TUTORIAL_SEEN_FLAG:String = "PigPenTutorial";
      
      private static const TUTORIAL_SEEN_FLAG_V2:String = "PigPenTutorialV2";
      
      public function PigPenWindow(building:FeatureBuilding)
      {
         super(building,"assets/dialogs/FV_PigPen2_4.swf","pigpenv2");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(!Global.player.getSeenFlag(TUTORIAL_SEEN_FLAG_V2))
         {
            Global.player.setSeenFlag(TUTORIAL_SEEN_FLAG_V2);
            TutorialUI.displayPigPenTutorialWindow(false,null);
         }
      }
      
      override protected function howDoesThisWorkCallback(event:MouseEvent) : void
      {
         TutorialUI.displayPigPenTutorialWindow();
      }
   }
}

