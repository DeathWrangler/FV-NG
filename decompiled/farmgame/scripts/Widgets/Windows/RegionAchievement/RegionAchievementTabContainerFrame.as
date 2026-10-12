package Widgets.Windows.RegionAchievement
{
   import Classes.RegionAchievement.Region;
   import Classes.util.ZLocUtils;
   import Events.RegionAchievementEvent;
   import Managers.RegionAchievementManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RegionAchievementTabContainerFrame extends ZwFrame
   {
      
      private static const SHIPPING_MC:String = "shipping_mc";
      
      private static const BODY_TF:String = "body_tf";
      
      private static const SHIPPING_TILE_TF:String = "title_tf";
      
      public static const DEFAULT_TAB:String = "";
      
      protected static const SLOT_PREFIX:String = "slot_";
      
      public static const NUM_TABS:int = 4;
      
      private var m_firstRefresh:Boolean = true;
      
      private var m_regionTaskToggleHandles:Object;
      
      private var m_regionTabButtons:Array;
      
      private var m_tabToggleManager:ZwToggleManager;
      
      private var m_featureName:String;
      
      private var m_window:RegionAchievementTabbedWindow;
      
      private var m_topArrowButton:ZwButton = null;
      
      private var m_bottomArrowButton:ZwButton = null;
      
      private var m_closeButton:FarmButton;
      
      private var m_taskCotent_mc:RegionAchievementTabContent;
      
      private var m_currentTab:String;
      
      private var m_closeCallback:Function;
      
      private var m_shppingMC:ZwFrame;
      
      private var m_shippingTileTf:ZwTextField;
      
      private var m_shippingBodyTf:ZwTextField;
      
      private var m_regionTabs:Vector.<FarmButton>;
      
      public function RegionAchievementTabContainerFrame(element:DisplayObject, featureName:String, window:RegionAchievementTabbedWindow, regionId:String = "", closeCallback:Function = null)
      {
         var bodyText:String = null;
         var titleText:String = null;
         this.m_regionTaskToggleHandles = new Object();
         this.m_regionTabButtons = new Array(NUM_TABS);
         super(element);
         this.m_featureName = featureName;
         this.m_window = window;
         this.m_currentTab = regionId;
         this.m_closeCallback = closeCallback;
         if(Boolean(m_element) && m_element.hasOwnProperty("close_bt"))
         {
            this.m_closeButton = addWidget(new FarmButton((m_element as MovieClip).close_bt,this.onClose)) as FarmButton;
         }
         if(Boolean(m_element) && m_element.hasOwnProperty("tabContent_mc"))
         {
            this.m_taskCotent_mc = addWidget(new RegionAchievementTabContent((m_element as MovieClip).tabContent_mc,this.m_featureName,this.m_currentTab)) as RegionAchievementTabContent;
         }
         if(m_element.hasOwnProperty(SHIPPING_MC))
         {
            this.m_shppingMC = addWidget(new ZwFrame(m_element[SHIPPING_MC]),true) as ZwFrame;
            bodyText = "";
            titleText = "";
            if(RegionAchievementManager.getInstance(this.m_featureName).isGotSpecialRewardFromFO())
            {
               bodyText = ZLocUtils.t("Dialogs",this.m_featureName + "_ShieldReward_shipping_won_body");
               titleText = ZLocUtils.t("Dialogs",this.m_featureName + "_ShieldReward_shipping_won_title");
            }
            else
            {
               bodyText = ZLocUtils.t("Dialogs",this.m_featureName + "_ShieldReward_shipping_body");
               titleText = ZLocUtils.t("Dialogs",this.m_featureName + "_ShieldReward_shipping_title");
            }
            if(this.m_shppingMC.element.hasOwnProperty(BODY_TF))
            {
               this.m_shippingBodyTf = addWidget(new ZwTextField(this.m_shppingMC.element[BODY_TF],bodyText),true) as ZwTextField;
            }
            if(this.m_shppingMC.element.hasOwnProperty(SHIPPING_TILE_TF))
            {
               this.m_shippingTileTf = addWidget(new ZwTextField(this.m_shppingMC.element[SHIPPING_TILE_TF],titleText),true) as ZwTextField;
            }
         }
      }
      
      public function refresh() : void
      {
         var regions:Array = null;
         var i:int = 0;
         var region:Region = null;
         var regionTab:FarmTabButton = null;
         if(this.m_firstRefresh)
         {
            this.m_firstRefresh = false;
            this.m_tabToggleManager = new ZwToggleManager();
            this.m_regionTabs = new Vector.<FarmButton>();
            regions = RegionAchievementManager.getInstance(this.m_featureName).regions;
            i = 0;
            while(i < regions.length && m_element.hasOwnProperty("tab_" + (i + 1) + "_mc"))
            {
               region = regions[i];
               regionTab = new FarmTabButton(m_element["tab_" + (i + 1) + "_mc"],this.tabName(region.id));
               regionTab.visible = true;
               if(region.unlocked)
               {
                  if(this.m_currentTab == "" && i == 0)
                  {
                     this.m_currentTab = String(region.id);
                  }
                  this.m_regionTaskToggleHandles[String(region.id)] = this.m_tabToggleManager.addToggle(new ZwVisibilityToggle(regionTab,this.m_taskCotent_mc,this.generateRegionTabButtonCallback(region.id)),this.m_currentTab == String(region.id));
               }
               else
               {
                  regionTab.setToggleState(ZwToggleState.DISABLED);
                  regionTab.attachTooltip(new FarmTextTooltip(region.getRegionUnlockTimerText()));
               }
               this.m_regionTabs.push(regionTab);
               i++;
            }
         }
         if(this.m_taskCotent_mc)
         {
            this.m_taskCotent_mc.refresh(this.m_currentTab);
            this.m_taskCotent_mc.visible = true;
         }
      }
      
      private function generateRegionTabButtonCallback(regionName:String) : Function
      {
         return function():void
         {
            if(m_currentTab != regionName)
            {
               m_currentTab = regionName;
               refresh();
            }
         };
      }
      
      public function showTab(regionName:String) : void
      {
         this.m_tabToggleManager.setToggle(this.getMapping(regionName));
      }
      
      private function getMapping(regionName:String) : uint
      {
         return this.m_regionTaskToggleHandles[regionName];
      }
      
      private function onClose(event:Event) : void
      {
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.REFRESH_UI));
         var toggleNPCEvent:RegionAchievementEvent = new RegionAchievementEvent(RegionAchievementEvent.TOGGLE_MAIN_WINDOW_NPC,{"visible":true});
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(toggleNPCEvent);
         if(this.m_window)
         {
            this.release();
            this.m_window.close();
            this.m_window = null;
         }
         RegionAchievementManager.getInstance(this.m_featureName).releaseTaskWindow();
      }
      
      private function tabName(regionId:String) : String
      {
         return ZLocUtils.t("Dialogs",this.m_featureName + "_tabbedWindow_tabname_" + regionId);
      }
      
      override public function release() : void
      {
         var tabButton:FarmTabButton = null;
         if(Boolean(this.m_regionTabs) && this.m_regionTabs.length > 0)
         {
            for each(tabButton in this.m_regionTabs)
            {
               if(tabButton)
               {
                  tabButton.detachTooltip();
               }
            }
         }
         this.m_regionTabs = null;
         this.m_taskCotent_mc = null;
      }
   }
}

