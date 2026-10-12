package Widgets.Windows.Toasters
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.AutoCloseToasterWindow;
   import Widgets.Windows.ThemedQuestWindow;
   import flash.events.Event;
   
   public class ThemedQuestToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const ASSET:String = "assets/dialogs/FV_themedQuest_puzzle_Toaster.swf";
      
      public static const DEFAULT:int = 0;
      
      public static const TASK_COMPLETE:int = 1;
      
      private static const DEFAULT_FEATURE_NAME:String = "PuzzleThemedQuestBuilding";
      
      private var m_quest:FarmQuest;
      
      private var m_state:int;
      
      private var m_shouldClose:Boolean = false;
      
      private var m_featureName:String;
      
      public function ThemedQuestToasterWindow(quest:FarmQuest = null, state:int = 0, featureName:String = "PuzzleThemedQuestBuilding")
      {
         var autoCloseTime:Number = 15000;
         super(ASSET,autoCloseTime);
         this.m_quest = quest;
         this.m_state = state;
         this.m_featureName = featureName;
         if(Global.player.getSeenSessionFlag(ThemedQuestWindow.PUZZLE_FEATURE))
         {
            this.m_shouldClose = true;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window)
         {
            if(m_window.hasOwnProperty("finishIt_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window.finishIt_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_viewProgress"),this.onClickViewThemedQuestWindow));
            }
            if(m_window.hasOwnProperty("message_tf"))
            {
               if(this.m_state == TASK_COMPLETE)
               {
                  addWidget(new FarmTextField(m_window.message_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_toasterMessageTaskComplete")));
               }
               else
               {
                  addWidget(new FarmTextField(m_window.message_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_toasterMessage")));
               }
            }
            if(m_window.hasOwnProperty("title_tf"))
            {
               addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_toasterTitle")));
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               addWidget(new FarmIcon(m_window.icon_mc));
            }
         }
         StatsManager.count("fv_puzz_house","toaster_puzzhouse","view");
      }
      
      override public function show() : void
      {
         if(this.m_shouldClose || Boolean(this.m_quest) && Boolean(FarmQuestManager.getInstance().isQuestComplete(this.m_quest.name)))
         {
            close();
         }
         else
         {
            super.show();
         }
      }
      
      protected function onClickViewThemedQuestWindow(event:Event) : void
      {
         var themedQuestWindow:ThemedQuestWindow = null;
         if(this.m_featureName)
         {
            themedQuestWindow = new ThemedQuestWindow(this.m_featureName);
            UI.displayPopup(themedQuestWindow);
         }
      }
      
      override protected function postClose() : void
      {
         super.postClose();
         StatsManager.count("fv_puzz_house","toaster_puzzhouse","close");
      }
   }
}

