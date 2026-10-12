package Init.Worlds
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Display.HUD.HUDWidgets.VillageFTUEHudIcon;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.FarmGameWorldEvent;
   import Managers.FarmVillageManager;
   import Managers.ToasterManager;
   import Widgets.FarmVillageFTUEWindow;
   import Widgets.Windows.Market.MarketWindow;
   import Widgets.Windows.VillageHudWindow;
   import ZQuest.Classes.Quest;
   import ZQuest.Events.QuestEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class VillageWorldInit extends HomeWorldInit
   {
      
      private static const FTUE_QUEST_CHAIN:String = "xfvftue";
      
      private static const FTUE_WINDOW_SEEN_FLAG:String = "VillageFTUESeen";
      
      private var m_villageHudWindow:VillageHudWindow;
      
      private var m_FTUEIcon:Sprite;
      
      private var m_FTUEIconContainer:VillageFTUEHudIcon;
      
      private var m_activeFTUEQuest:FarmQuest;
      
      public function VillageWorldInit()
      {
         super();
      }
      
      public static function findActiveFTUEQuest() : FarmQuest
      {
         var activeQuest:FarmQuest = null;
         var farmQuest:FarmQuest = null;
         var quest:Quest = null;
         var quests:Vector.<Quest> = FarmQuestManager.getInstance().getActiveQuests();
         for each(quest in quests)
         {
            farmQuest = quest as FarmQuest;
            if(Boolean(farmQuest) && Boolean(farmQuest.chain == FTUE_QUEST_CHAIN) && FarmQuestManager.getInstance().isQuestActive(farmQuest.name))
            {
               activeQuest = farmQuest;
               break;
            }
         }
         return activeQuest;
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         Global.hud.rightSideIconQueue.visible = false;
         Global.hud.setIconQueuesVisibility(false);
         Global.hud.setNeighborSearchBarVisibility(false);
         Global.ui.setBottomUIVisible(false);
         Global.hud.setFuelIconVisibility(false);
         Global.hud.toggleMessageSignEnable(false);
         StatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,"village_currency",Global.player.currentWorldCurrencyTotal.toString());
         this.m_villageHudWindow = new VillageHudWindow();
         Global.stage.addChild(this.m_villageHudWindow);
         this.m_villageHudWindow.show();
         Global.stage.setChildIndex(this.m_villageHudWindow,1);
         MarketWindow.setBottomDisplayIndex(2);
         ToasterManager.getInstance().togglePause(true);
         FarmQuestManager.getInstance().addEventListener(QuestEvent.COMPLETED,this.refreshFTUEQuest);
         FarmQuestManager.getInstance().addEventListener(QuestEvent.PROGRESS,this.refreshFTUEQuest);
         if(Global.player.postInitFinished)
         {
            this.refreshFTUEQuest();
         }
         else
         {
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredFTUERefresh,false,0,true);
         }
         if(!Global.player.getSeenFlag(FTUE_WINDOW_SEEN_FLAG))
         {
            UI.displayPopup(new FarmVillageFTUEWindow(),false);
            Global.player.setSeenFlag(FTUE_WINDOW_SEEN_FLAG);
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         super.onLeaveWorld(destIsVisiting);
         Global.hud.rightSideIconQueue.visible = true;
         Global.hud.setIconQueuesVisibility(true);
         Global.hud.setFuelIconVisibility(true);
         Global.hud.setNeighborSearchBarVisibility(true);
         Global.hud.toggleMessageSignEnable(true);
         Global.ui.setBottomUIVisible(true);
         if(this.m_villageHudWindow != null)
         {
            this.m_villageHudWindow.close();
         }
         MarketWindow.setBottomDisplayIndex(1);
         ToasterManager.getInstance().togglePause(false);
         FarmQuestManager.getInstance().removeEventListener(QuestEvent.COMPLETED,this.refreshFTUEQuest);
         FarmQuestManager.getInstance().removeEventListener(QuestEvent.PROGRESS,this.refreshFTUEQuest);
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredFTUERefresh);
         if(this.m_FTUEIconContainer)
         {
            this.m_FTUEIconContainer.release();
         }
         if(this.m_FTUEIcon)
         {
            Global.hud.removeChild(this.m_FTUEIcon);
            this.m_FTUEIcon = null;
         }
      }
      
      private function deferredFTUERefresh(event:Event) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredFTUERefresh);
            this.refreshFTUEQuest();
         }
      }
      
      private function refreshFTUEQuest(event:Event = null) : void
      {
         this.m_activeFTUEQuest = findActiveFTUEQuest();
         if(this.m_activeFTUEQuest)
         {
            if(this.m_FTUEIcon == null)
            {
               this.m_FTUEIcon = new Sprite();
               Global.hud.addChild(this.m_FTUEIcon);
               this.m_FTUEIcon.x = 31;
               this.m_FTUEIcon.y = 120;
               this.m_FTUEIconContainer = new VillageFTUEHudIcon(this.m_FTUEIcon,this.onClickFTUEIcon);
            }
            this.m_FTUEIcon.visible = true;
            this.m_FTUEIconContainer.showProgressAnimation();
         }
         else if(this.m_FTUEIcon)
         {
            this.m_FTUEIcon.visible = false;
         }
      }
      
      private function onClickFTUEIcon() : void
      {
         if(Boolean(this.m_activeFTUEQuest) && FarmQuestManager.getInstance().isQuestActive(this.m_activeFTUEQuest.name))
         {
            this.m_activeFTUEQuest.showProgress();
         }
      }
   }
}

