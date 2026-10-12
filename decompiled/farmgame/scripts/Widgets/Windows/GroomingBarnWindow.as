package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Managers.FarmStatsManager;
   import Managers.GroomingBarnManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Breeding.StorageContentsSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Frames.GroomingBarnMarketFrame;
   import Widgets.Slots.Breeding.AnimalBreedingContentsSlot;
   import flash.events.Event;
   
   public class GroomingBarnWindow extends StorageContentsWindow
   {
      
      private static const BARN_FTUE_FLAG:String = "GroomingBarnFTUE";
      
      private var m_marketTab_bt:FarmAnimatedTextButton;
      
      private var m_myYearlingsTab_bt:FarmAnimatedTextButton;
      
      private var m_marketFrame_mc:GroomingBarnMarketFrame;
      
      private var m_myYearlingsToggle:ZwVisibilityToggle;
      
      private var m_marketToggle:ZwVisibilityToggle;
      
      public function GroomingBarnWindow(building:FeatureBuilding = null)
      {
         super(building);
      }
      
      override protected function initFeatureWidgets() : void
      {
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,GroomingBarnManager.getInstance().WINDOW_NAME + "_title")),true);
         }
         if(m_window.hasOwnProperty("animals_mc"))
         {
            m_content_mc = this.getFarmSlotContainerFrame();
            addWidget(m_content_mc,false);
         }
         if(m_window.hasOwnProperty("whatisthis_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HowDoesThisWork"),this.howDoesThisWorkClick),true);
         }
         if(m_window.hasOwnProperty("leftTab_mc"))
         {
            this.m_marketTab_bt = addWidget(new FarmAnimatedTextButton(m_window.leftTab_mc,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,GroomingBarnManager.getInstance().WINDOW_NAME + "_marketTab"))) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty("rightTab_mc"))
         {
            this.m_myYearlingsTab_bt = addWidget(new FarmAnimatedTextButton(m_window.rightTab_mc,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,GroomingBarnManager.getInstance().WINDOW_NAME + "_myYearlingsTab"))) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty("slots_mc"))
         {
            this.m_marketFrame_mc = addWidget(new GroomingBarnMarketFrame(m_window.slots_mc,this),false) as GroomingBarnMarketFrame;
         }
         if(Boolean(this.m_marketTab_bt) && Boolean(this.m_marketFrame_mc))
         {
            this.m_marketToggle = new ZwVisibilityToggle(this.m_marketTab_bt,this.m_marketFrame_mc);
         }
         if(Boolean(this.m_myYearlingsTab_bt) && Boolean(m_content_mc))
         {
            this.m_myYearlingsToggle = new ZwVisibilityToggle(this.m_myYearlingsTab_bt,m_content_mc);
         }
         m_toggleManager = new ZwToggleManager();
         if(this.m_myYearlingsToggle)
         {
            m_toggleManager.addToggle(this.m_myYearlingsToggle);
         }
         if(this.m_marketToggle)
         {
            m_toggleManager.addToggle(this.m_marketToggle,true);
         }
         if(!Global.player.getSeenFlag(BARN_FTUE_FLAG))
         {
            building.displayStorageDialog();
            this.howDoesThisWorkClick(null);
            FarmStatsManager.count("yearling","FTUE","start");
         }
      }
      
      override protected function getFarmSlotContainerFrame() : FarmSlotContainerFrame
      {
         return new StorageContentsSlotFrame(m_window.animals_mc,m_contents,this,AnimalBreedingContentsSlot);
      }
      
      private function howDoesThisWorkClick(e:Event = null) : void
      {
         var prefixUrl:String = m_building.getItem().prefixUrl;
         TutorialUI.displayBuildingTutorialWindow(m_building,prefixUrl,false,this.howDoesThisWorkCloseCallback);
      }
      
      private function howDoesThisWorkCloseCallback() : void
      {
         if(!Global.player.getSeenFlag(BARN_FTUE_FLAG))
         {
            Global.player.setSeenFlag(BARN_FTUE_FLAG);
            FarmStatsManager.count("yearling","FTUE","end");
         }
      }
      
      public function pause() : void
      {
         if(m_window)
         {
            tintWindow();
            enableInput = false;
         }
      }
      
      public function unpause() : void
      {
         if(m_window)
         {
            untintWindow();
            enableInput = true;
            close();
         }
      }
      
      override protected function release() : void
      {
         this.m_marketTab_bt = null;
         this.m_myYearlingsTab_bt = null;
         this.m_marketFrame_mc = null;
         this.m_myYearlingsToggle = null;
         this.m_marketToggle = null;
         super.release();
      }
   }
}

