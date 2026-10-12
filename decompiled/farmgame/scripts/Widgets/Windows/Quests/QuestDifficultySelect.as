package Widgets.Windows.Quests
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmRadioButton;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwToggle;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class QuestDifficultySelect extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_QuestChoice2.swf";
      
      private var m_questName:String = null;
      
      private var m_toggleManager:ZwToggleManager = null;
      
      private var m_selectedDifficulty:int = 0;
      
      public function QuestDifficultySelect(questName:String)
      {
         super(ASSET_URL);
         this.m_questName = questName;
         this.m_toggleManager = new ZwToggleManager();
      }
      
      override protected function postLoadComplete() : void
      {
         var radioButton:FarmRadioButton = null;
         var textFieldName:String = null;
         var radioIndex:int = 1;
         var radioButtonName:String = "radio" + radioIndex + "_btn";
         while(m_window.hasOwnProperty(radioButtonName))
         {
            radioButton = new FarmRadioButton(m_window[radioButtonName],this.onRadioSelected);
            radioButton.element.buttonMode = true;
            addWidget(radioButton);
            this.m_toggleManager.addToggle(new ZwToggle(radioButton),radioIndex == 2);
            textFieldName = "t" + radioIndex + "_tf";
            if(m_window.hasOwnProperty(textFieldName))
            {
               addWidget(new ZwTextField(m_window[textFieldName],ZLocUtils.t("Dialogs","questDifficulty_" + radioIndex)));
            }
            radioIndex++;
            radioButtonName = "radio" + radioIndex + "_btn";
         }
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Accept"),this.onAccept));
         addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs","difficultySelect")));
         addWidget(new ZwTextField(m_window.subheader1_tf,ZLocUtils.t("Dialogs","difficultyDescEasy")));
         addWidget(new ZwTextField(m_window.subheader2_tf,ZLocUtils.t("Dialogs","difficultyDescHard")));
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_toggleManager = null;
      }
      
      private function onRadioSelected(radio:FarmRadioButton) : void
      {
         this.m_selectedDifficulty = parseInt(radio.name.charAt(radio.name.lastIndexOf("_") - 1));
      }
      
      private function onAccept(event:Event) : void
      {
         this.close();
         Global.player.setSeenFlag(this.m_questName + "_diffSelect_" + this.m_selectedDifficulty);
         Global.player.setSeenFlag(this.m_questName + "_diff",true);
      }
   }
}

