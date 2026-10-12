package Init.PostInitActionHandlers
{
   import Classes.Constants.Experiments;
   import Classes.Idle.FarmItemDependentPostInitIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.FriendBar.DynamicNPCSlot;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.LESurfacingManager;
   import Managers.PerformanceExperimentManager;
   
   public class LENeighborSurfacingPostInitAction extends AbstractPostInitAction
   {
      
      private static var m_dynamicSlot:DynamicNPCSlot = null;
      
      private static var m_selectedItem:FarmItem = null;
      
      private static const LE_NEIGHBOR_SURFACING_CLICK:String = "le_neighbor_surfacing_click";
      
      private static const HOLDOFF_DEFAULT_DAYS:int = 1;
      
      private static const LE_NEGIHBOR_SURFACING_HOLDOFF_DAYS_RUNTIME:String = "LE_NEGIHBOR_HOLDOFF_DAYS";
      
      private static var m_lootItems:Array = null;
      
      public function LENeighborSurfacingPostInitAction(callback:Function = null)
      {
         super(callback);
         m_lootItems = LESurfacingManager.instance.LEWindowItems;
         if(!m_lootItems)
         {
            if(!Global.farmGameSettingsManager.itemsXMLParsingComplete && PerformanceExperimentManager.isInInterruptFreeItemParsingExperiment)
            {
               IdleTaskQueue.getInstance().addTask(new FarmItemDependentPostInitIdleTask(function():void
               {
                  LESurfacingManager.instance.setLEWindowItems();
                  m_lootItems = LESurfacingManager.instance.LEWindowItems;
               }));
            }
            else
            {
               LESurfacingManager.instance.setLEWindowItems();
               m_lootItems = LESurfacingManager.instance.LEWindowItems;
            }
         }
      }
      
      private static function initLENeighborSlot() : void
      {
         var randomIndex:int = 0;
         var slotConfig:Object = null;
         if(m_lootItems == null)
         {
            m_lootItems = LESurfacingManager.instance.LEWindowItems;
         }
         var items:Array = m_lootItems;
         if(Boolean(items) && items.length > 0)
         {
            randomIndex = Math.floor(Math.random() * items.length);
            m_selectedItem = items[randomIndex];
            slotConfig = {
               "assetPath":"assets/dialogs/FV_Support/FV_NeighborBar/FV_LE_NeighborBar.swf",
               "action":"LENeighborSurfacing",
               "stat":"le_surfacing_social",
               "tooltip":"Dialogs:LESurfacingNPCTooltip",
               "onClickSlot":LENeighborSurfacingPostInitAction.onClickSlot,
               "dynamicIcon":m_selectedItem.icon,
               "title":"Dialogs:LESurfacingNPCTitle"
            };
            m_dynamicSlot = new DynamicNPCSlot(Global.ui.m_friendBar.slots.length,slotConfig);
            Global.ui.m_friendBar.addSlotAtBeginning(m_dynamicSlot);
            FarmStatsManager.count("le_surfacing_social","view",m_selectedItem.name,m_selectedItem.realCashCost.toString());
         }
      }
      
      public static function onClickSlot() : void
      {
         if(Boolean(m_dynamicSlot) && Boolean(m_selectedItem))
         {
            FarmStatsManager.count("le_surfacing_social","click",m_selectedItem.name,m_selectedItem.realCashCost.toString());
            Global.player.incrementActionCount(LE_NEIGHBOR_SURFACING_CLICK,true);
            UI.displayMiniMarketDialog([m_selectedItem.name]);
            Global.ui.m_friendBar.removeSlotAtIndex(m_dynamicSlot.m_index);
            initLENeighborSlot();
         }
      }
      
      override public function execute() : void
      {
         var holdOffDays:int = 0;
         var shouldShow:Boolean = false;
         var actionCount:int = 0;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_LAST_CHANCE) < Experiments.VARIANT_LE_LAST_CHANCE_EXPIRING)
         {
            holdOffDays = Global.flashHotParams[LE_NEGIHBOR_SURFACING_HOLDOFF_DAYS_RUNTIME] != null ? int(Global.flashHotParams[LE_NEGIHBOR_SURFACING_HOLDOFF_DAYS_RUNTIME]) : HOLDOFF_DEFAULT_DAYS;
            shouldShow = Global.player.canShowFeatureWithFeatureFrequency(LE_NEIGHBOR_SURFACING_CLICK,holdOffDays);
            actionCount = Global.player.getActionCount(LE_NEIGHBOR_SURFACING_CLICK);
            if(actionCount > 0 || actionCount == 0 && shouldShow)
            {
               Global.player.setFeatureLastShown(LE_NEIGHBOR_SURFACING_CLICK,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
               Global.player.resetActionCount(LE_NEIGHBOR_SURFACING_CLICK,true);
               initLENeighborSlot();
            }
         }
         m_isFinished = true;
      }
   }
}

