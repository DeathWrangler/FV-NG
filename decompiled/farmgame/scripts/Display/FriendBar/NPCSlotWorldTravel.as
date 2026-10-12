package Display.FriendBar
{
   import Classes.Idle.GenericToasterIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.NPCConfigData;
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.ExpansionData;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.MOTD;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Init.PostInitActionHandlers.PostInitFunctionCall;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TExpansionWorldAccess;
   import Transactions.TGetMOTD;
   import Widgets.Windows.SimpleToasterWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class NPCSlotWorldTravel extends NPCSlot
   {
      
      private var m_world:String;
      
      private const TYPE_INVALID:int = -1;
      
      private const TYPE_EARLY_ACCESS:int = 0;
      
      private const TYPE_GENERAL_ACCESS:int = 1;
      
      private const TYPE_FREE_TRAVEL:int = 2;
      
      private const TOASTER_ASSET_PREFIX:String = "assets/dialogs/FV_BannerAd_";
      
      private const TOASTER_ASSET_POSTFIX:String = "_NeighborBar.swf";
      
      private const TOASTER_KEY_POSTFIX:String = "_npc_toaster";
      
      private var m_travelType:int = -1;
      
      private var m_motdData:Object = null;
      
      private var m_showMOTDOnLoad:Boolean = false;
      
      private var m_enabled:Boolean = true;
      
      public function NPCSlotWorldTravel(slotIndex:int, npcData:NPCConfigData)
      {
         var toasterKey:String = null;
         var expansionData:ExpansionData = null;
         var seenToaster:Function = null;
         var toaster:SimpleToasterWindow = null;
         this.m_world = npcData.world;
         if(this.m_world != null && this.m_world != "")
         {
            super(slotIndex);
            expansionData = Global.farmGameSettingsManager.getExpansionData(this.m_world);
            if(expansionData == null)
            {
               throw new Error("Invalid expansion world passed to NPCSlotWorldTravel, could not find expansion definition for world: " + this.m_world);
            }
            if(expansionData.getAccessOfType(ExpansionAccess.TYPE_EARLY).checkPrereqs())
            {
               this.m_travelType = this.TYPE_EARLY_ACCESS;
               TransactionManager.addTransaction(new TGetMOTD(npcData.motd,this.onGetMOTD));
            }
            else if(expansionData.getAccessOfType(ExpansionAccess.TYPE_GENERAL).checkPrereqs())
            {
               this.m_travelType = this.TYPE_GENERAL_ACCESS;
            }
            else if(Global.worldManager.hasUnlockedWorld(this.m_world))
            {
               this.m_travelType = this.TYPE_FREE_TRAVEL;
            }
         }
         toasterKey = this.m_world + this.TOASTER_KEY_POSTFIX;
         if(Boolean(this.shouldDisplay()) && Boolean(Global.experimentManager.getExperimentVariant("fv_" + toasterKey)) && !Global.player.getSeenFlag(toasterKey))
         {
            seenToaster = function(event:Event):void
            {
               event.target.removeEventListener(ToasterManager.DISPLAYED_EVENT,seenToaster);
               Global.player.setSeenFlag(toasterKey,false,true);
            };
            toaster = new SimpleToasterWindow(toasterKey,ZLocUtils.t_pk("Dialogs",toasterKey),this.TOASTER_ASSET_PREFIX + this.m_world + this.TOASTER_ASSET_POSTFIX,this.onClickToaster,5000);
            toaster.addEventListener(ToasterManager.DISPLAYED_EVENT,seenToaster);
            IdleTaskQueue.getInstance().addTask(new GenericToasterIdleTask(toaster,30000));
         }
      }
      
      override public function shouldDisplay() : Boolean
      {
         return this.m_travelType != this.TYPE_INVALID && Boolean(this.m_world) && (Global.worldManager.currentWorldType != this.m_world || this.isEarlyAccessExpansionAvailable(this.m_world) && WorldSeasonsManager.getInstance().getNumSeasonsForWorld(this.m_world) == WorldSeasonsManager.SEASON_TWO || this.m_travelType == this.TYPE_GENERAL_ACCESS && WorldSeasonsManager.getInstance().getCurrentSeason(this.m_world) == WorldSeasonsManager.SEASON_ONE);
      }
      
      public function onGetMOTD(amfResult:Object) : void
      {
         if(Boolean(amfResult) && amfResult.hasOwnProperty("motdSeenFlag"))
         {
            this.m_motdData = amfResult;
         }
         if(this.m_showMOTDOnLoad)
         {
            this.m_showMOTDOnLoad = false;
            MOTD.displayMOTD(this.m_motdData,false,this.enableClick,this.acceptCallback);
         }
      }
      
      public function enableClick(event:Event = null) : void
      {
         this.m_enabled = true;
      }
      
      public function onClickToaster() : void
      {
         this.onClickFriend(null);
      }
      
      override public function onClickFriend(event:MouseEvent) : void
      {
         if(this.m_enabled && !Global.worldManager.accessExpansionTransactionInProgress())
         {
            this.m_enabled = false;
            if(this.m_travelType != this.TYPE_GENERAL_ACCESS && Global.worldManager.hasUnlockedWorld(this.m_world) && !(this.isEarlyAccessExpansionAvailable(this.m_world) && WorldSeasonsManager.getInstance().getNumSeasonsForWorld(this.m_world) == WorldSeasonsManager.SEASON_TWO))
            {
               this.m_travelType = this.TYPE_FREE_TRAVEL;
            }
            FarmStatsManager.count("NPC_world_travel",this.m_world,"clicks");
            switch(this.m_travelType)
            {
               case this.TYPE_EARLY_ACCESS:
                  if(this.m_motdData)
                  {
                     MOTD.displayMOTD(this.m_motdData,false,this.enableClick,this.acceptCallback);
                  }
                  else
                  {
                     this.m_showMOTDOnLoad = true;
                  }
                  break;
               case this.TYPE_GENERAL_ACCESS:
               case this.TYPE_FREE_TRAVEL:
                  Global.postInitActionsManager.addInitAction(new PostInitFunctionCall(this.worldTravel));
            }
         }
      }
      
      public function acceptCallback(event:Event = null) : void
      {
         var popupEvent:GenericPopupEvent = null;
         if(event is GenericPopupEvent)
         {
            popupEvent = event as GenericPopupEvent;
            if(popupEvent.button == GenericPopup.CANCEL)
            {
               this.enableClick();
            }
         }
      }
      
      public function worldTravel() : void
      {
         if(this.m_travelType == this.TYPE_GENERAL_ACCESS)
         {
            TransactionManager.addTransaction(new TExpansionWorldAccess(this.m_world,ExpansionAccess.TYPE_GENERAL),true);
         }
         else if(Global.worldManager.hasUnlockedWorld(this.m_world) && !(this.isEarlyAccessExpansionAvailable(this.m_world) && WorldSeasonsManager.getInstance().getNumSeasonsForWorld(this.m_world) == WorldSeasonsManager.SEASON_TWO))
         {
            this.m_travelType = this.TYPE_FREE_TRAVEL;
         }
         if(this.m_travelType == this.TYPE_FREE_TRAVEL)
         {
            Global.worldManager.showTravelConfirmation(this.m_world);
            this.enableClick();
         }
      }
      
      private function isEarlyAccessExpansionAvailable(worldId:String) : Boolean
      {
         var result:Boolean = false;
         var access:ExpansionAccess = this.getEarlyExpansionAccessData(worldId);
         if(access)
         {
            if(access.checkPrereqs())
            {
               result = true;
            }
         }
         return result;
      }
      
      private function getEarlyExpansionAccessData(worldId:String) : ExpansionAccess
      {
         var access:ExpansionAccess = null;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
         if(expansionData)
         {
            access = expansionData.getAccessOfType(ExpansionAccess.TYPE_EARLY);
         }
         return access;
      }
   }
}

