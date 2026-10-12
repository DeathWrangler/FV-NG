package Managers
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.PrerequisiteUtility;
   import Display.*;
   import Display.HUD.HUDWidgets.HudBottomJournalButton;
   import Widgets.Windows.JournalWindow;
   import ZQuest.Init.QuestSettingsInit;
   import flash.utils.Dictionary;
   
   public class JournalManager
   {
      
      private static var m_instance:JournalManager = null;
      
      private static var m_journalNotificationFlag:String = null;
      
      private var m_prereqs:Array = null;
      
      private var m_journalWindowPath:String;
      
      private var m_journalIconPath:String;
      
      private var m_questBubbles:Array;
      
      private var m_journalWindow:JournalWindow;
      
      private var m_journalHUDButton:HudBottomJournalButton;
      
      private var m_completedQuestBubbles:Dictionary = new Dictionary();
      
      private var m_isJournalActive:Boolean = false;
      
      protected var m_featureName:String;
      
      public function JournalManager(featureName:String, journalNotificationFlag:String)
      {
         super();
         this.m_featureName = featureName;
         m_journalNotificationFlag = journalNotificationFlag;
         this.loadFeatureConfig();
      }
      
      public static function getInstance(featureName:String = null, journalNotificationFlag:String = null) : JournalManager
      {
         if(!m_instance && featureName != null && journalNotificationFlag != null)
         {
            m_instance = new JournalManager(featureName,journalNotificationFlag);
         }
         return m_instance;
      }
      
      public function isJournalActive() : Boolean
      {
         if(this.m_prereqs)
         {
            return PrerequisiteUtility.arePrerequisitesMet(this.m_prereqs);
         }
         return false;
      }
      
      public function initJournalHUD() : void
      {
         this.m_journalHUDButton = new HudBottomJournalButton(this.m_journalIconPath);
         if(this.m_completedQuestBubbles.length > 0)
         {
            this.m_journalHUDButton.showButton();
         }
      }
      
      public function isJournalNotificationAvailable() : Boolean
      {
         return !Global.player.getSeenFlag(m_journalNotificationFlag);
      }
      
      public function setJournalNotificationSeen() : void
      {
         Global.player.setSeenFlag(m_journalNotificationFlag);
         m_instance.m_journalHUDButton.displayJournalNotification = false;
      }
      
      public function showUI() : void
      {
         FarmStatsManager.count(this.m_featureName,"Main UI","view");
         UI.displayPopup(this.m_journalWindow = new JournalWindow(this.journalWindowPath));
      }
      
      public function hideUI() : void
      {
         this.m_journalWindow.close();
      }
      
      public function pushQuestBubble(quest:String) : void
      {
         var bubble:Object = null;
         for each(bubble in this.m_questBubbles)
         {
            if(bubble.name == quest)
            {
               this.addQuestToCompletedQuests(bubble);
            }
         }
      }
      
      private function addQuestToCompletedQuests(bubble:Object) : void
      {
         if(Boolean(this.m_journalHUDButton) && !this.m_journalHUDButton.isVisible)
         {
            this.m_journalHUDButton.showButton();
         }
         this.m_completedQuestBubbles[bubble.id] = bubble.name;
         this.showJournalNotification();
      }
      
      private function showJournalNotification() : void
      {
         if(this.m_journalHUDButton)
         {
            m_instance.m_journalHUDButton.displayJournalNotification = true;
         }
      }
      
      public function loadCompletedQuestBubbles() : void
      {
         var bubble:Object = null;
         for each(bubble in this.m_questBubbles)
         {
            if(FarmQuestManager.getInstance().isQuestExpired(bubble.name) || FarmQuestManager.getInstance().isQuestComplete(bubble.name))
            {
               this.addQuestToCompletedQuests(bubble);
               this.showJournalNotification();
            }
         }
      }
      
      private function parseBubbles(featureXML:XML) : Array
      {
         var questBubble:Object = null;
         var quest:FarmQuest = null;
         var questBubbles:Array = new Array();
         var bubble:Object = null;
         for each(questBubble in featureXML.questBubbles.bubble)
         {
            quest = QuestSettingsInit.getInstance().getItemByName(questBubble.@name.toString()) as FarmQuest;
            bubble = new Object();
            bubble.id = parseInt(questBubble.@id.toString());
            bubble.name = questBubble.@name.toString();
            questBubbles.push(bubble);
         }
         return questBubbles;
      }
      
      protected function loadFeatureConfig() : void
      {
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         if(featureXML != null)
         {
            this.m_isJournalActive = true;
            this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(featureXML.prereqs.children());
            this.m_journalWindowPath = featureXML.UI.children()[0].@path.toString();
            this.m_journalIconPath = featureXML.icon.children()[0].toString();
            this.m_questBubbles = this.parseBubbles(featureXML);
         }
      }
      
      public function get prereqs() : Array
      {
         return this.m_prereqs;
      }
      
      public function get journalWindowPath() : String
      {
         return this.m_journalWindowPath;
      }
      
      public function get journalIconPath() : String
      {
         return this.m_journalIconPath;
      }
      
      public function get completedQuestBubble() : Dictionary
      {
         return this.m_completedQuestBubbles;
      }
      
      public function release() : void
      {
         this.m_prereqs = null;
         this.m_journalIconPath = null;
         this.m_journalWindowPath = null;
         this.m_questBubbles = null;
         m_instance = null;
         this.m_journalHUDButton = null;
         this.m_featureName = null;
         this.m_journalWindow = null;
         this.m_completedQuestBubbles = null;
      }
      
      public function featureName() : String
      {
         return this.m_featureName;
      }
   }
}

