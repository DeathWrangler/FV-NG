package Widgets.Frames.Breeding
{
   import Classes.breeding.AnimalBreedingSession;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.breeding.AnimalBreedingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Breeding.BreedingWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class BreedingLoseFrame extends ZwFrame
   {
      
      protected var m_parentWindow:BreedingWindow = null;
      
      protected var m_breedingSession:AnimalBreedingSession = null;
      
      protected var m_featureName:String = "";
      
      public function BreedingLoseFrame(element:DisplayObject, parentWindow:BreedingWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_featureName = this.m_parentWindow.getFeatureName();
         addWidget(new ZwTextField(m_element.header_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Sorry_Title")));
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Sorry_Body")));
         addWidget(new FarmAnimatedTextButton(m_element.generic1_btn,ZLocUtils.t("Dialogs",this.m_featureName + "_Sorry_button_ask_for_potions"),this.onAskClick));
         addWidget(new FarmAnimatedTextButton(m_element.generic2_btn,ZLocUtils.t("Dialogs",this.m_featureName + "_Sorry_button_try_again"),this.onTryAgainClick));
         addWidget(new ZwButton(m_element.close_bt,this.onClose));
      }
      
      override public function release() : void
      {
         super.release();
         this.m_parentWindow = null;
      }
      
      public function displayWindow(breedingSession:AnimalBreedingSession) : void
      {
         this.m_breedingSession = breedingSession;
      }
      
      protected function onAskClick(event:MouseEvent) : void
      {
         AnimalBreedingManager.getInstance().askForLovePotions(this.m_parentWindow.getFeatureName(),"Lose");
         this.visible = false;
         FarmStatsManager.count(this.m_featureName,"breeding","breed_failed","ask_for_more");
      }
      
      protected function onTryAgainClick(event:MouseEvent) : void
      {
         this.visible = false;
         this.m_parentWindow.displayMatingWindow(this.m_breedingSession);
         FarmStatsManager.count(this.m_featureName,"breeding","breed_failed","try_again");
      }
      
      protected function onClose(event:MouseEvent) : void
      {
         this.visible = false;
         FarmStatsManager.count(this.m_featureName,"breeding","breed_failed","close");
      }
   }
}

