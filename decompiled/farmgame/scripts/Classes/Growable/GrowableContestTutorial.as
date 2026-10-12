package Classes.Growable
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Display.TutorialUI;
   import Managers.FarmGameSettingsManager;
   import Widgets.Windows.GrowableContestWindow;
   
   public class GrowableContestTutorial
   {
      
      public static const STATE_START:String = "start";
      
      public static const STATE_WAIT_FOR_BUILDING:String = "WaitForBuilding";
      
      public static const STATE_OPEN_WHAT_IS_THIS:String = "OpenWhatIsThis";
      
      public static const STATE_OPEN_UI_MARKET:String = "OpenUiMarket";
      
      public static const STATE_WAIT_FOR_PARTICIPANT:String = "WaitForParticipant";
      
      public static const STATE_OPEN_UI_MAIN:String = "OpenUiMain";
      
      public static const STATE_DONE:String = "done";
      
      private var m_contest:GrowableContest;
      
      private var m_currentState:String = "start";
      
      public function GrowableContestTutorial(contest:GrowableContest)
      {
         super();
         this.m_contest = contest;
      }
      
      private function getCurrentState() : String
      {
         var currentState:String = null;
         var building:FeatureBuilding = null;
         if(!Global.player.getSeenFlag(this.getSeenFlagForState(STATE_WAIT_FOR_BUILDING)))
         {
            building = this.m_contest.getBuilding();
            if(building != null)
            {
               Global.player.setSeenFlag(this.getSeenFlagForState(STATE_WAIT_FOR_BUILDING));
               this.m_contest.statCount("placement");
            }
         }
         if(!Global.player.getSeenFlag(this.getSeenFlagForState(STATE_WAIT_FOR_PARTICIPANT)))
         {
            if(this.m_contest.firstParticipantPlaced)
            {
               Global.player.setSeenFlag(this.getSeenFlagForState(STATE_WAIT_FOR_PARTICIPANT));
            }
         }
         if(!Global.player.getSeenFlag(this.getSeenFlagForState(STATE_WAIT_FOR_BUILDING)))
         {
            currentState = STATE_WAIT_FOR_BUILDING;
         }
         else if(!Global.player.getSeenFlag(this.getSeenFlagForState(STATE_OPEN_WHAT_IS_THIS)))
         {
            currentState = STATE_OPEN_WHAT_IS_THIS;
         }
         else if(!Global.player.getSeenFlag(this.getSeenFlagForState(STATE_OPEN_UI_MARKET)))
         {
            currentState = STATE_OPEN_UI_MARKET;
         }
         else if(!Global.player.getSeenFlag(this.getSeenFlagForState(STATE_WAIT_FOR_PARTICIPANT)))
         {
            currentState = STATE_WAIT_FOR_PARTICIPANT;
         }
         else if(!Global.player.getSeenFlag(this.getSeenFlagForState(STATE_OPEN_UI_MAIN)))
         {
            currentState = STATE_OPEN_UI_MAIN;
         }
         else
         {
            currentState = STATE_DONE;
         }
         return currentState;
      }
      
      public function updateState() : void
      {
         var building:FeatureBuilding = null;
         var previousState:String = this.m_currentState;
         var currentState:String = this.getCurrentState();
         if(previousState != currentState)
         {
            if(currentState != STATE_DONE)
            {
               switch(currentState)
               {
                  case STATE_WAIT_FOR_BUILDING:
                     building = this.m_contest.getBuilding();
                     if(building != null)
                     {
                        Global.player.setSeenFlag(this.getSeenFlagForState(STATE_WAIT_FOR_BUILDING));
                     }
                     break;
                  case STATE_OPEN_WHAT_IS_THIS:
                     this.showWhatIsThis(true);
                     break;
                  case STATE_OPEN_UI_MARKET:
                     GrowableContestWindow.showWindowForContest(this.m_contest,GrowableContestWindow.FRAME_MARKET,true);
                     Global.player.setSeenFlag(this.getSeenFlagForState(STATE_OPEN_UI_MARKET));
                     break;
                  case STATE_WAIT_FOR_PARTICIPANT:
                     break;
                  case STATE_OPEN_UI_MAIN:
                     GrowableContestWindow.showWindowForContest(this.m_contest,GrowableContestWindow.FRAME_ITEMS,true);
                     Global.player.setSeenFlag(this.getSeenFlagForState(STATE_OPEN_UI_MAIN));
                     break;
                  case STATE_DONE:
               }
            }
            this.m_currentState = currentState;
         }
      }
      
      private function getSeenFlagForState(state:String) : String
      {
         return this.m_contest.contestId + "_" + state;
      }
      
      public function showWhatIsThis(inTutorial:Boolean = false) : void
      {
         var buildingName:String = null;
         var buildingItemName:String = this.m_contest.getBuildingName();
         var buildingItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(buildingItemName);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            buildingName = buildingItem.getStringFromDataSource("buildingName");
         }
         else
         {
            buildingName = buildingItem.xml.@buildingName;
         }
         TutorialUI.displayTutorialWindowForItem(buildingName,"Dialogs:" + buildingName + "_Tutorial_Title",buildingItem.prefixUrl,false,this.onWhatIsThisClosed,inTutorial ? "Dialogs:" + buildingName + "_Tutorial_PlaceFirstItem_Button" : null,inTutorial);
         this.m_contest.statCount("what_is_this","impression");
      }
      
      private function onWhatIsThisClosed() : void
      {
         if(!Global.player.getSeenFlag(this.getSeenFlagForState(STATE_OPEN_WHAT_IS_THIS)))
         {
            Global.player.setSeenFlag(this.getSeenFlagForState(STATE_OPEN_WHAT_IS_THIS));
         }
         this.updateState();
         this.m_contest.statCount("what_is_this","okay");
      }
      
      public function isCompleted() : Boolean
      {
         return this.getCurrentState() == STATE_DONE;
      }
   }
}

