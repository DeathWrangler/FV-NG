package Classes.MOTD
{
   import Classes.FeatureMessagingDefinition;
   import Classes.ZItem.ExpansionData;
   import Display.MOTD;
   import Display.UI;
   import Engine.Classes.IsoViewport;
   import Engine.Helpers.Vector2;
   import Engine.Managers.InputManager;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Managers.ActionDrivenManager;
   import Managers.FeatureMessagingManager;
   import Managers.ItemFinderManager;
   import Transactions.TExpansionWorldAccess;
   import Transactions.TGetMOTD;
   import Transactions.TSawSpecificMOTD;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class ExpansionEarlyAccessChristmasPatchMotdHandler extends ExpansionEarlyAccessMotdHandler
   {
      
      private static const CHRISTMAS_PATCH_EARLY_ACCESS_TYPE:String = "christmasPatch";
      
      private static const OPEN_UI_DELAY:int = 5000;
      
      private static const GENERAL_ACCESS_TYPE:String = "generalAccess";
      
      private var m_featureName:String = "northpole_toy_works";
      
      private var m_itemName:String = "bldg_northpoletoyworks";
      
      private var m_tileName:String = "xwi_rubbletreasure_christmas";
      
      private var m_timer:Timer;
      
      private var m_motdData:Object = null;
      
      private var m_featureDefinition:FeatureMessagingDefinition;
      
      public function ExpansionEarlyAccessChristmasPatchMotdHandler(currentMOTD:Object, addPopupToQueue:Boolean = true)
      {
         super(currentMOTD,addPopupToQueue);
      }
      
      override protected function get earlyAccessType() : String
      {
         return CHRISTMAS_PATCH_EARLY_ACCESS_TYPE;
      }
      
      override protected function acceptMOTD() : void
      {
         var expansionData:ExpansionData = null;
         var worldType:String = m_currentMOTD["worldType"];
         if(worldType)
         {
            expansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
            if(expansionData == null)
            {
               throw new Error("Invalid expansion MOTD, could not find expansion definition for world: " + worldType);
            }
            closeMOTD();
            TransactionManager.addTransaction(new TSawSpecificMOTD(m_currentMOTD,false));
            if(Global.worldManager.isWorldSwapStable)
            {
               if(Global.worldManager.currentWorldType != worldType && Global.worldManager.hasUnlockedWorld(worldType))
               {
                  Global.worldManager.swapFarm(worldType,true);
                  Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.UnlockTileAndPanToBuilding);
               }
               else if(!Global.worldManager.hasUnlockedWorld(m_expansionData.worldId))
               {
                  TransactionManager.addTransaction(new TExpansionWorldAccess(m_expansionData.worldId,GENERAL_ACCESS_TYPE,true,this.m_expansionOnboardingWindow.getOptionId()),true);
                  Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.UnlockTileAndPanToBuilding);
               }
               else if(Global.worldManager.currentWorldType == worldType)
               {
                  this.UnlockTileAndPanToBuilding(null);
               }
            }
         }
      }
      
      public function UnlockTileAndPanToBuilding(e:Event) : void
      {
         var christmasPatchLockedTile:Array = Global.world.getObjectsByName(this.m_tileName);
         var christmasPatchBuildingItem:Array = Global.world.getObjectsByName(this.m_itemName);
         if(Boolean(christmasPatchLockedTile) && christmasPatchLockedTile.length > 0)
         {
            ItemFinderManager.getInstance().highlightWorldItems(this.m_tileName);
            Global.world.dispatchEvent(new Event(FarmGameWorldEvent.UNLOCK_TILE));
         }
         else if(Boolean(christmasPatchBuildingItem) && christmasPatchBuildingItem.length > 0)
         {
            ItemFinderManager.getInstance().highlightWorldItems(this.m_itemName);
         }
         this.panToItemAndShowMOTD();
      }
      
      public function panToItemAndShowMOTD() : void
      {
         if(this.m_itemName)
         {
            this.m_timer = new Timer(OPEN_UI_DELAY,1);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.initialize);
            this.m_timer.start();
            InputManager.disableInput();
         }
         else
         {
            this.initialize();
         }
      }
      
      public function initialize(event:Event = null) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.initialize);
            InputManager.enableInput();
            UI.stopPopups(false);
         }
         if(!Global.player.isMotdSeenFlagSet("MOTD_NORTHPOLE_TOY_WORKS_2015"))
         {
            this.m_featureDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.m_featureName);
            TransactionManager.addTransaction(new TGetMOTD(this.m_featureDefinition.motd,this.onGetMOTD),true);
         }
         else
         {
            ActionDrivenManager.onAcceptMOTD(this.m_featureName,this.m_itemName);
         }
         this.scrollToTile();
      }
      
      private function onGetMOTD(amfResult:Object) : void
      {
         if(Boolean(amfResult) && amfResult.hasOwnProperty("motdSeenFlag"))
         {
            this.m_motdData = amfResult;
            MOTD.displayMOTD(this.m_motdData,false);
         }
      }
      
      private function scrollToTile() : void
      {
         var viewport:IsoViewport = GlobalEngine.viewport as IsoViewport;
         var pos:Vector2 = new Vector2();
         pos.x = -3980;
         pos.y = -1552;
         viewport.setScrollPosition(pos);
      }
   }
}

