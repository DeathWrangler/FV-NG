package Classes
{
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.UI;
   import Widgets.Windows.MystreeNurseryWindow;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class MystreeNursery extends FeatureBuilding
   {
      
      public static const TEND_TIME_ATTR_PREFIX:String = "mystree_wait_time_";
      
      public static const TEND_SB_QUANTITY_PREFIX:String = "mystree_sb_quantity_";
      
      public static const NUM_PLOTS:int = 16;
      
      public static const PLOT_STATE_LOCKED:int = -1;
      
      public static const PLOT_STATE_EMPTY:int = 0;
      
      public static const LVL1_SAPLING:int = 1;
      
      public static const LVL2_SAPLING:int = 2;
      
      public static const LVL3_SAPLING:int = 3;
      
      public static const LVL4_SAPLING:int = 4;
      
      public static const LVL5_SAPLING:int = 5;
      
      public static const LVL_FINAL_MYSTREE:int = 6;
      
      private static const PLOT_INDEX:String = "0";
      
      private static const TEND_INDEX:String = "1";
      
      private var m_storageContents:Dictionary = new Dictionary();
      
      public function MystreeNursery(itemName:String)
      {
         super(itemName);
      }
      
      override protected function updateToolTipText() : void
      {
         super.updateToolTipText();
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MYSTREE) <= 1)
         {
            setToolTip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"JacksMystreeNursery_tooltip"));
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         var plotId:String = null;
         super.loadObject(data);
         var objContents:Array = data.contents;
         for(plotId in objContents)
         {
            this.m_storageContents[plotId] = objContents[plotId];
         }
      }
      
      public function resetFeatureData() : void
      {
         this.m_storageContents = new Dictionary();
         this.m_storageContents["0"] = new Object();
         this.m_storageContents["0"][PLOT_INDEX] = 5;
         this.m_storageContents["0"][TEND_INDEX] = 0;
         for(var i:int = 1; i < NUM_PLOTS; i++)
         {
            this.m_storageContents[i.toString()] = new Object();
            this.m_storageContents[i.toString()][TEND_INDEX] = 0;
            if(i < NUM_PLOTS / 2)
            {
               this.m_storageContents[i.toString()][PLOT_INDEX] = 0;
            }
            else
            {
               this.m_storageContents[i.toString()][PLOT_INDEX] = -1;
            }
         }
      }
      
      public function getSaplingLevelFor(plotId:String) : int
      {
         var level:int = -1;
         if(Boolean(this.m_storageContents) && Boolean(this.m_storageContents[plotId]) && this.m_storageContents[plotId]["0"] != null)
         {
            level = int(this.m_storageContents[plotId]["0"]);
            level = level >= LVL_FINAL_MYSTREE ? LVL_FINAL_MYSTREE : level;
         }
         return level;
      }
      
      public function setSaplingLevelFor(plotId:String, lvl:int) : void
      {
         if(Boolean(this.m_storageContents) && Boolean(this.m_storageContents[plotId]))
         {
            this.m_storageContents[plotId]["0"] = lvl;
         }
      }
      
      public function getSaplingTendStartFor(plotId:String) : int
      {
         var ts:int = 0;
         if(Boolean(this.m_storageContents) && Boolean(this.m_storageContents[plotId]) && this.m_storageContents[plotId]["1"] != null)
         {
            ts = int(this.m_storageContents[plotId]["1"]);
         }
         return ts;
      }
      
      public function setSaplingTendStartFor(plotId:String, ts:int) : void
      {
         if(Boolean(this.m_storageContents) && Boolean(this.m_storageContents[plotId]))
         {
            this.m_storageContents[plotId]["1"] = ts;
         }
      }
      
      public function canTend(plotId:String) : Boolean
      {
         var result:Boolean = false;
         var lvl:int = this.getSaplingLevelFor(plotId);
         var startTs:int = this.getSaplingTendStartFor(plotId);
         var tendTime:int = this.getTotalTendTimeFor(lvl);
         var currentTime:int = GlobalEngine.serverTime / 1000;
         if(lvl > PLOT_STATE_EMPTY && lvl < LVL_FINAL_MYSTREE && startTs + tendTime <= currentTime)
         {
            result = true;
         }
         return result;
      }
      
      public function canPlant(plotId:String) : Boolean
      {
         var result:Boolean = false;
         if(this.getSaplingLevelFor(plotId) == PLOT_STATE_EMPTY)
         {
            result = true;
         }
         return result;
      }
      
      override public function showMenu() : void
      {
         m_menuItems = [];
         if(this.state == STATE_BUSY || !Global.worldManager.isWorldSwapStable)
         {
            showObjectBusy();
         }
         else
         {
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MYSTREE) >= 2)
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","LookInside"),
                  "action":LOOK_INSIDE
               });
            }
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            });
            UI.displayMenu(m_menuItems,this.onMenuClick);
         }
      }
      
      public function getStorageData() : Dictionary
      {
         return this.m_storageContents;
      }
      
      public function getTotalTendTimeFor(level:int) : int
      {
         return Global.farmGameSettingsManager.getInt(MystreeNursery.TEND_TIME_ATTR_PREFIX + level.toString());
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case LOOK_INSIDE:
                  this.openMystreeUI();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function openMystreeUI() : void
      {
         UI.displayPopup(new MystreeNurseryWindow(this));
      }
   }
}

