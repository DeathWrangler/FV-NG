package Widgets.Windows.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Managers.FinishAllBuildingsUtil;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FinishAllBuildings.FinishAllBuildingsSlotFrame;
   import Widgets.Slots.FinishAllBuildings.FinishAllBuildingsSlot;
   import flash.events.Event;
   
   public class FinishAllBuildingsMOTDWindow extends CustomWindowMOTDBase
   {
      
      protected static const DIALOG_ASSET:String = "assets/dialogs/FV_FinishBuildings.swf";
      
      public static const DIALOG_STATS_WINDOW:String = "dialog_view";
      
      public static const FINISH_ALL_BUILDING_COUNTER:String = "finish_all_buildings";
      
      public static const POPUP_NAME:String = "finish_all_buildings";
      
      protected var m_saleSlotFrame:FinishAllBuildingsSlotFrame;
      
      protected var m_saleItemList:Array;
      
      public function FinishAllBuildingsMOTDWindow()
      {
         super(DIALOG_ASSET);
      }
      
      override protected function postLoadComplete() : void
      {
         var bgWidget:ZwFrame = null;
         var dlgKey:String = null;
         super.postLoadComplete();
         var worldType:String = Global.worldManager.currentWorldType;
         if(m_window)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","Congrats")));
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","FinishAllBuildingsSubtitle")));
            this.m_saleItemList = FinishAllBuildingsUtil.getSaleItems();
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FINISH_ALL_BLDGS_EXPANSIONS) == 1)
            {
               this.m_saleItemList = this.m_saleItemList.concat(FinishAllBuildingsUtil.getExpandibleItems());
            }
            this.m_saleSlotFrame = addWidget(new FinishAllBuildingsSlotFrame(m_window.slotFrame_mc,this.m_saleItemList)) as FinishAllBuildingsSlotFrame;
            this.m_saleSlotFrame.addEventListener(FinishAllBuildingsSlot.BUY_CLICKED_EVENT,this.onBuyItemClick);
            if(this.m_saleItemList.length == 0)
            {
               if(m_window.hasOwnProperty("textBG_mc") && Boolean(m_window.textBG_mc))
               {
                  bgWidget = addWidget(new ZwFrame(m_window.textBG_mc)) as ZwFrame;
                  if(!this.isThereMoreValidFarms())
                  {
                     dlgKey = "FinishAllBuildingsNoFarms";
                  }
                  else
                  {
                     dlgKey = FinishAllBuildingsUtil.isWorldExcluded(Global.worldManager.currentWorldType) ? "FinishAllBuildingsExcluded" : "FinishAllBuildingsNoSpecials";
                  }
                  bgWidget.addWidget(new ZwTextField(m_window.textBG_mc.body_tf,ZLocUtils.t("Dialogs",dlgKey)));
               }
            }
         }
      }
      
      private function isThereMoreValidFarms() : Boolean
      {
         var world:String = null;
         var result:Boolean = false;
         var unlockedWorlds:Array = Global.worldManager.getAvailableTravelWorlds();
         for each(world in unlockedWorlds)
         {
            if(!FinishAllBuildingsUtil.isWorldExcluded(world))
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      override protected function release() : void
      {
         super.release();
         if(Boolean(this.m_saleSlotFrame) && this.m_saleSlotFrame.hasEventListener(FinishAllBuildingsSlot.BUY_CLICKED_EVENT))
         {
            this.m_saleSlotFrame.removeEventListener(FinishAllBuildingsSlot.BUY_CLICKED_EVENT,this.onBuyItemClick);
         }
         this.m_saleSlotFrame = null;
         this.m_saleItemList = null;
      }
      
      private function onBuyItemClick(event:Event) : void
      {
         if(this.m_saleItemList.length == 0)
         {
            onClose(null);
         }
      }
   }
}

