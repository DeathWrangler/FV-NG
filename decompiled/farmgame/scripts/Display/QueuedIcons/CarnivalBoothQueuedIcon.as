package Display.QueuedIcons
{
   import Classes.ZItem.FarmItem;
   import Display.DynamicIconQueue;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CarnivalBoothQueuedIcon extends DynamicContentQueuedIcon
   {
      
      public static const CANIVAL_BOOTH_ICON_NAME:String = "carnivalBooth";
      
      public static const CANIVAL_BOOTH_ICON_TYPE:String = "MiniGamesIcon";
      
      private static const ICON_SIZE:int = 138;
      
      private var m_lootItems:Array;
      
      private var m_assetLoaded:Boolean;
      
      private var m_lootTableLoaded:Boolean;
      
      public function CarnivalBoothQueuedIcon(xml:XML)
      {
         super(xml);
         this.m_assetLoaded = false;
         this.m_lootTableLoaded = false;
         var currentGameToken:FarmItem = Global.farmGameSettingsManager.getActivePigoGameItem();
         if(currentGameToken != null)
         {
            TransactionManager.addTransaction(new TGenericTransaction("PigoService","getGameSettings",this.onGetLootItems,[currentGameToken.name]),true);
         }
      }
      
      public static function showHUDIcon() : void
      {
         if(!Global.player.getSeenSessionFlag("carnival_booth_hud"))
         {
            FarmStatsManager.count("carnivalbooth","hud_icon","impressions");
            Global.player.setSeenSessionFlag("carnival_booth_hud");
            Global.hud.rightSideIconQueue.addIcon("carnivalBooth",DynamicIconQueue.ADD_BY_PRIORITY,null,null,false);
         }
      }
      
      private function onGetLootItems(result:Object) : void
      {
         if(Boolean(result) && result is Array)
         {
            this.m_lootTableLoaded = true;
            this.m_lootItems = result as Array;
            this.injectContent();
         }
      }
      
      override protected function onButtonIconLoaded(event:Event) : void
      {
         this.m_assetLoaded = true;
         super.onButtonIconLoaded(event);
      }
      
      override protected function injectContent() : void
      {
         var loadedMC:MovieClip = null;
         var randomIndex:int = 0;
         var randomItem:FarmItem = null;
         var farmIcon:FarmIcon = null;
         if(this.m_assetLoaded && this.m_lootTableLoaded)
         {
            loadedMC = m_Loader.content as MovieClip;
            if(this.m_lootItems.length > 0)
            {
               randomIndex = Math.floor(Math.random() * this.m_lootItems.length);
               randomItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_lootItems[randomIndex].itemName);
               if(randomItem != null)
               {
                  farmIcon = new FarmIcon(loadedMC.item_mc);
                  farmIcon.loadIcon(randomItem.icon);
                  farmIcon.setIconSize(ICON_SIZE,ICON_SIZE);
                  m_widgetManager.addWidget(farmIcon);
               }
            }
         }
      }
   }
}

