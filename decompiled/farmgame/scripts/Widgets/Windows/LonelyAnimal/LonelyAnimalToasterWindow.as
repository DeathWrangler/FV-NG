package Widgets.Windows.LonelyAnimal
{
   import Classes.LonelyAnimal;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Transactions.TMarkLonelyAnimalFriendSet;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.ToasterWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class LonelyAnimalToasterWindow extends ToasterWindow
   {
      
      protected static const POPUP_NAME:String = "lonely_animal_toaster";
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_BannerAd_LonelyAnimal.swf";
      
      private var m_lonelyAnimal:LonelyAnimal;
      
      public function LonelyAnimalToasterWindow(lonelyAnimal:LonelyAnimal)
      {
         this.m_lonelyAnimal = lonelyAnimal;
         if(this.m_lonelyAnimal.progressState == TMarkLonelyAnimalFriendSet.LONELY_ANIMAL_PROGRESS_NEW && this.m_lonelyAnimal.canShow)
         {
            super(ASSET_PATH);
         }
         this.name = POPUP_NAME;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(Boolean(m_window) && this.m_lonelyAnimal != null)
         {
            addWidget(new ZwBaseWidget(m_window.hoofs_mc));
            addWidget(new ZwBaseWidget(m_window.text_wrapper));
            addWidget(new FarmAnimatedTextButton(m_window.bt_share,ZLocUtils.t("Dialogs","EnglandDukeCrashingButtonText"),this.onCenterAnimal));
            addWidget(new ZwTextField(m_window.text_wrapper.generic0_tf.generic_0_tf,ZLocUtils.t("Dialogs","LonelyAnimal_ToasterText")));
         }
      }
      
      override protected function postShow() : void
      {
         FarmStatsManager.count("lonely_animal_crew_feature","onboarding_toaster","impression");
         if(m_window.hoofs_mc)
         {
            (m_window.hoofs_mc as MovieClip).play();
         }
         if(m_window.text_wrapper)
         {
            (m_window.text_wrapper as MovieClip).play();
         }
      }
      
      private function onCenterAnimal(event:Event) : void
      {
         FarmStatsManager.count("lonely_animal_crew_feature","onboarding_toaster","confirm_button");
         if(this.m_lonelyAnimal != null)
         {
            this.m_lonelyAnimal.centerOn();
         }
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("lonely_animal_crew_feature","onboarding_toaster","close_button");
         close();
      }
   }
}

