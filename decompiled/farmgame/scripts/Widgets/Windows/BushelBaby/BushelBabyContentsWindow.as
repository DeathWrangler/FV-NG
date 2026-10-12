package Widgets.Windows.BushelBaby
{
   import Classes.BushelBaby.BushelBabyOrderItem;
   import Classes.BushelBaby.BushelBabySystem;
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.BushelBabiesCraftingFrame;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.BushelBaby.BushelBabyNPCSlotContainerFrame;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindowWithTutorial;
   import flash.events.Event;
   
   public class BushelBabyContentsWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 5;
      
      private var m_system:BushelBabySystem;
      
      private var m_npcSlots:BushelBabyNPCSlotContainerFrame;
      
      private var m_craftingUI:BushelBabiesCraftingFrame;
      
      private var m_levelTxt:ZwTextField;
      
      private var m_levelProgress:FarmProgressBar;
      
      private var m_buildingLevel:ZwWidget;
      
      public function BushelBabyContentsWindow(system:BushelBabySystem)
      {
         system.currentContentsWindow = this;
         this.m_system = system;
         super(this.m_system.name,this.m_system.getAssetUrl(BushelBabySystem.ASSET_DIALOG_MAIN),NUM_TUTORIAL_SCENES);
      }
      
      public static function display(system:BushelBabySystem) : BushelBabyContentsWindow
      {
         var window:BushelBabyContentsWindow = null;
         if(system)
         {
            window = new BushelBabyContentsWindow(system);
            UI.displayPopup(window,true,"BushelBabyContentsWindow",true);
         }
         return window;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HowDoesThisWork"),this.onHowDoesThisWorkClick));
         addWidget(new FarmTextField(m_window.title_tf),false) as FarmTextField;
         addWidget(new ZwBaseWidget(m_window.loading_mc),false);
         addWidget(this.m_craftingUI = new BushelBabiesCraftingFrame(m_window.crafting_mc),false);
         if(m_window.animal_mc)
         {
            this.m_npcSlots = addWidget(new BushelBabyNPCSlotContainerFrame(m_window.animal_mc)) as BushelBabyNPCSlotContainerFrame;
            this.m_npcSlots.items = this.m_system.npcArray;
         }
         addWidget(this.m_levelTxt = new ZwTextField(m_window.buildingLevel_mc.level_tf));
         addWidget(this.m_levelProgress = new FarmProgressBar(m_window.buildingLevel_mc.meter_mc));
         addWidget(this.m_buildingLevel = new ZwWidget(m_window.buildingLevel_mc));
         this.m_buildingLevel.attachTooltip(new FarmTextTooltip(""));
         this.updateProgress();
      }
      
      private function updateProgress() : void
      {
         var completed:int = 0;
         completed = this.m_system.completedNPCCount();
         var npcsInLevel:int = this.m_system.npcs.length / this.m_system.buildingLevelCount;
         var level:int = int(completed / npcsInLevel);
         var x_value:int = completed % npcsInLevel;
         var y_value:int = npcsInLevel;
         if(level == this.m_system.buildingLevelCount)
         {
            x_value = npcsInLevel;
         }
         this.m_levelTxt.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"xau_daydreamisland_DialogStageNumber",{"level_num":level});
         FarmTextTooltip(this.m_buildingLevel.tooltip).setText(ZLocUtils.t("Dialogs","XofYcompleted",{
            "x":x_value,
            "y":y_value
         }));
         this.m_levelProgress.maximum = this.m_system.npcs.length;
         this.m_levelProgress.progress = completed;
      }
      
      public function showCraftingUI(item:BushelBabyOrderItem) : BushelBabiesCraftingFrame
      {
         return this.m_craftingUI.show(item);
      }
      
      override protected function release() : void
      {
         if(this.m_system.currentContentsWindow == this)
         {
            this.m_system.currentContentsWindow = null;
         }
         super.release();
         this.m_npcSlots = null;
         this.m_craftingUI = null;
         this.m_levelTxt = null;
         this.m_levelProgress = null;
      }
      
      public function get system() : BushelBabySystem
      {
         return this.m_system;
      }
      
      public function refresh() : void
      {
         if(m_window)
         {
            this.refreshNPCs();
         }
         this.updateProgress();
      }
      
      public function refreshNPCs() : void
      {
         if(this.m_npcSlots)
         {
            this.m_npcSlots.refresh();
         }
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
   }
}

