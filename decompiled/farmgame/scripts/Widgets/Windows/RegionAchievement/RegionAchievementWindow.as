package Widgets.Windows.RegionAchievement
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.RegionAchievementEvent;
   import Managers.RegionAchievementManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.TravelDialogTutorialWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class RegionAchievementWindow extends FarmWindow
   {
      
      private static const CHAMPION_BOX:String = "champion_0";
      
      private static const TROPHY_TITLE:String = "trophyTitle_tf";
      
      private static const TROPHY_CLICKTOVIEW:String = "view_tf";
      
      private static const TROPHY_COUNTER:String = "counter_tf";
      
      private static const TROPHY_COUNTER_1:String = "counter1_tf";
      
      private static const TITLE_TXT:String = "title_tf";
      
      private static const BODY_TXT:String = "body_tf";
      
      private static const WHAT_IS_THIS:String = "whatisthis_mc";
      
      private static const REGION_CONTAINER:String = "regionContainer_mc";
      
      private static const NPC_MC_OUTER:String = "npc_mc_out";
      
      private static const NPC_MC:String = "npc_mc";
      
      private static const NPC_BUBBLE_MC:String = "npc_bubble_mc";
      
      private static const TA_TIP:String = "timed_tip";
      
      private static const MOUSE_OUT_STATE:int = 1;
      
      private static const MOUSE_OVER_STATE:int = 2;
      
      private static const MOUSE_OUT_STATE_WON:int = 3;
      
      private static const MOUSE_OVER_STATE_WON:int = 4;
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      protected var m_whatIsThisBtn:FarmAnimatedButton;
      
      private var m_featureName:String;
      
      private var m_championTrophyTitle:FarmTextField;
      
      private var m_championTrophyClickToView:FarmTextField;
      
      private var m_championTrophy_mc:MovieClip;
      
      private var m_regionFrame:RegionAchievementMainContainerFrame;
      
      private var m_championTrophyCounterText:FarmTextField;
      
      private var m_npcMc:ZwWidget;
      
      public function RegionAchievementWindow(assetUrl:String, featureName:String)
      {
         this.m_featureName = featureName;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty(NPC_MC_OUTER))
         {
            this.m_npcMc = addWidget(new ZwWidget(m_window[NPC_MC_OUTER])) as ZwWidget;
            if(this.m_npcMc.element.hasOwnProperty(NPC_MC))
            {
               this.m_npcMc.element[NPC_MC].gotoAndStop(1);
               if(RegionAchievementManager.getInstance(this.m_featureName).isChampionFromFO())
               {
                  this.m_npcMc.element[NPC_MC].gotoAndStop(2);
               }
            }
            this.m_npcMc.visible = true;
         }
         super.postLoadComplete();
         if(m_window.hasOwnProperty(TITLE_TXT))
         {
            addWidget(new FarmTextField(m_window[TITLE_TXT],ZLocUtils.t("Dialogs",this.m_featureName + "_main_title")));
         }
         if(m_window.hasOwnProperty(BODY_TXT))
         {
            addWidget(new FarmTextField(m_window[BODY_TXT],ZLocUtils.t("Dialogs",this.m_featureName + "_main_subtitle"),true));
         }
         if(m_window.hasOwnProperty(WHAT_IS_THIS))
         {
            this.m_whatIsThisBtn = addWidget(new FarmAnimatedButton(m_window[WHAT_IS_THIS],this.onHowDoesThisWorkClick),true) as FarmAnimatedButton;
         }
         if(m_window.hasOwnProperty(TA_TIP))
         {
            (m_window[TA_TIP] as MovieClip).visible = RegionAchievementManager.getInstance(this.m_featureName).isAnyTAActive();
         }
         this.initChampionIcon();
         this.initMainWindow();
         this.initTutorialWindow();
      }
      
      private function initTutorialWindow() : void
      {
         var tutorialSeenFlag:String = null;
         if(this.m_featureName)
         {
            tutorialSeenFlag = this.m_featureName + "_Tutorial";
            if(!Global.player.getSeenFlag(tutorialSeenFlag))
            {
               Global.player.setSeenFlag(tutorialSeenFlag);
               this.onHowDoesThisWorkClick(null);
            }
            else
            {
               this.hideTutorial();
            }
         }
      }
      
      private function initChampionIcon() : void
      {
         var championTrophySubtitle:FarmTextField = null;
         if(m_window.hasOwnProperty(CHAMPION_BOX))
         {
            this.m_championTrophy_mc = m_window[CHAMPION_BOX] as MovieClip;
            this.m_championTrophy_mc.buttonMode = true;
            this.m_championTrophy_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onTrophyMouseRollOver);
            this.m_championTrophy_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onTrophyMouseRollOut);
            this.m_championTrophy_mc.addEventListener(MouseEvent.CLICK,this.onTrophyMouseClick);
            this.m_championTrophy_mc.visible = true;
            if(this.m_championTrophy_mc.hasOwnProperty(TROPHY_TITLE))
            {
               this.m_championTrophyTitle = new FarmTextField(this.m_championTrophy_mc[TROPHY_TITLE],ZLocUtils.t("Dialogs",this.m_featureName + "_champion_chest_title"));
               this.m_championTrophyTitle.visible = false;
            }
            if(this.m_championTrophy_mc.hasOwnProperty(TROPHY_CLICKTOVIEW))
            {
               this.m_championTrophyClickToView = new FarmTextField(this.m_championTrophy_mc[TROPHY_CLICKTOVIEW],ZLocUtils.t("Dialogs",this.m_featureName + "_champion_chest_rollover"));
               this.m_championTrophyClickToView.visible = false;
            }
            if(this.m_championTrophy_mc.hasOwnProperty(TROPHY_COUNTER))
            {
               championTrophySubtitle = new FarmTextField(this.m_championTrophy_mc[TROPHY_COUNTER],ZLocUtils.t("Dialogs",this.m_featureName + "_champion_chest_counter_text",{"milestone":RegionAchievementManager.getInstance(this.m_featureName).championMilestone}));
               championTrophySubtitle.visible = true;
            }
            if(this.m_championTrophy_mc.hasOwnProperty(TROPHY_COUNTER_1))
            {
               this.m_championTrophyCounterText = new FarmTextField(this.m_championTrophy_mc[TROPHY_COUNTER_1],RegionAchievementManager.getInstance(this.m_featureName).completedChampionMilestoneText);
               this.m_championTrophyCounterText.visible = true;
            }
            this.m_championTrophy_mc.gotoAndStop(1);
            if(RegionAchievementManager.getInstance(this.m_featureName).isChampionFromFO())
            {
               this.m_championTrophy_mc.gotoAndStop(2);
            }
         }
      }
      
      private function onHowDoesThisWorkClick(e:Event) : void
      {
         this.toggleMainWindowNPC(false);
         this.showTutorial();
      }
      
      protected function hideTutorial() : void
      {
         this.toggleMainWindowNPC(true);
      }
      
      protected function showTutorial() : void
      {
         UI.displayPopup(new TravelDialogTutorialWindow(RegionAchievementManager.ACHIEVEMENT_TUTORIAL_URL,NUM_TUTORIAL_SCENES,this.hideTutorial,true,RegionAchievementManager.ACHIEVEMENT_FAQ_URL),false);
         this.toggleMainWindowNPC(false);
      }
      
      public function toggleMainWindowNPC(value:Boolean = true) : void
      {
         if(Boolean(this.m_npcMc) && Boolean(this.m_npcMc.element))
         {
            if(this.m_npcMc.element.hasOwnProperty(NPC_BUBBLE_MC))
            {
               this.m_npcMc.element[NPC_BUBBLE_MC].visible = value;
            }
            if(this.m_npcMc.element.hasOwnProperty("npc_mc"))
            {
               this.m_npcMc.element["npc_mc"].visible = value;
            }
            this.m_npcMc.visible = value;
         }
      }
      
      private function initMainWindow() : void
      {
         if(m_window.hasOwnProperty(REGION_CONTAINER))
         {
            this.m_regionFrame = addWidget(new RegionAchievementMainContainerFrame(m_window[REGION_CONTAINER],this,this.m_featureName)) as RegionAchievementMainContainerFrame;
         }
      }
      
      public function get regionAchievementFrame() : RegionAchievementMainContainerFrame
      {
         return this.m_regionFrame;
      }
      
      private function onTrophyMouseRollOver(eve:MouseEvent) : void
      {
         if(RegionAchievementManager.getInstance(this.m_featureName).isChampionFromFO())
         {
            this.m_championTrophy_mc.gotoAndStop(MOUSE_OVER_STATE_WON);
         }
         else
         {
            this.m_championTrophy_mc.gotoAndStop(MOUSE_OVER_STATE);
         }
         if(this.m_championTrophyTitle)
         {
            this.m_championTrophyTitle.visible = true;
         }
         if(this.m_championTrophyClickToView)
         {
            this.m_championTrophyClickToView.visible = true;
         }
      }
      
      private function onTrophyMouseRollOut(eve:MouseEvent) : void
      {
         if(RegionAchievementManager.getInstance(this.m_featureName).isChampionFromFO())
         {
            this.m_championTrophy_mc.gotoAndStop(MOUSE_OUT_STATE_WON);
         }
         else
         {
            this.m_championTrophy_mc.gotoAndStop(MOUSE_OUT_STATE);
         }
         this.m_championTrophy_mc.gotoAndStop(MOUSE_OUT_STATE);
         if(this.m_championTrophyTitle)
         {
            this.m_championTrophyTitle.visible = false;
         }
         if(this.m_championTrophyClickToView)
         {
            this.m_championTrophyClickToView.visible = false;
         }
      }
      
      private function onTrophyMouseClick(event:MouseEvent) : void
      {
         this.toggleMainWindowNPC(false);
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.CHAMPION_ICON_CLK));
      }
      
      private function refreshChampionIcon() : void
      {
         if(Boolean(this.m_championTrophyCounterText) && Boolean(this.m_championTrophy_mc))
         {
            this.m_championTrophyCounterText.text = RegionAchievementManager.getInstance(this.m_featureName).completedChampionMilestoneText;
            this.m_championTrophy_mc.gotoAndStop(1);
            if(RegionAchievementManager.getInstance(this.m_featureName).isChampionFromFO())
            {
               this.m_championTrophy_mc.gotoAndStop(2);
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         this.refreshChampionIcon();
         if(this.regionAchievementFrame)
         {
            this.regionAchievementFrame.refresh();
         }
      }
      
      override protected function release() : void
      {
         this.m_championTrophy_mc = null;
         this.m_whatIsThisBtn = null;
         this.m_championTrophyTitle = null;
         this.m_championTrophyClickToView = null;
         this.m_championTrophy_mc = null;
         this.m_regionFrame = null;
         this.m_championTrophyCounterText = null;
         this.m_npcMc = null;
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.UPDATE_HUD));
         super.onClose(event);
      }
   }
}

