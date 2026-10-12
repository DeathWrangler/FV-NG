package Widgets.Windows.Crafting
{
   import Classes.crafting.BushelsFoundSummary;
   import Classes.crafting.CraftingStatsManager;
   import Classes.feed.OpenStallShareFeed;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.Crafting.BushelInformationSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   
   public class BushelInfoWindow extends FarmWindow
   {
      
      private var m_bushelsInformation:Array;
      
      private var m_currentIndexOfBushelSummary:int = 0;
      
      public function BushelInfoWindow(bushelsInformation:Array)
      {
         var assetPath:String = "";
         if(Global.player.inExperimentFeedCheckBoxV2())
         {
            assetPath = "assets/dialogs/FV_MarketStall_BushelSummary_checkbox.swf";
         }
         else
         {
            assetPath = "assets/dialogs/FV_MarketStall_BushelSummary.swf";
         }
         super(assetPath);
         this.m_bushelsInformation = bushelsInformation;
      }
      
      override protected function postLoadComplete() : void
      {
         CraftingStatsManager.recordFoundBushelSummaryPopupPageView();
         var slot:BushelInformationSlotFrame = new BushelInformationSlotFrame(m_window,this.m_bushelsInformation,this.onShareClicked,this.onCancelClicked);
         addWidget(slot);
         addWidget(new FarmAnimatedTextButton(m_window.howDoes_mc,ZLocUtils.t("Crafting","MarketRewardDialog_MoreInfo"),this.showBushelTutorialWindow));
      }
      
      protected function showBushelTutorialWindow(evt:Event) : void
      {
         enableInput = false;
         TutorialUI.displayNewMarketStallTutorialWindow(false,this.onTutorialClose);
      }
      
      protected function onTutorialClose() : void
      {
         enableInput = true;
      }
      
      protected function onCancelClicked(e:MouseEvent) : void
      {
         this.close();
      }
      
      protected function onShareClicked(bushelSummary:BushelsFoundSummary) : void
      {
         var feed:OpenStallShareFeed = null;
         if(bushelSummary)
         {
            feed = new OpenStallShareFeed(bushelSummary.bushelItem,this.getTimeStallIsOpenFor(bushelSummary),bushelSummary.rewardUrl);
            feed.publish();
            bushelSummary.onFeedDisplayed();
         }
         this.close();
      }
      
      protected function getTimeStallIsOpenFor(bushelSummary:BushelsFoundSummary) : int
      {
         var baseTime:int = 24;
         var additionalHours:int = 0;
         if(Global.player.masteryCounters[bushelSummary.bushelItem.code])
         {
            additionalHours = Global.player.masteryCounters[bushelSummary.bushelItem.code] * 8;
         }
         return int(baseTime + additionalHours);
      }
      
      override public function close() : void
      {
         var dispObj:DisplayObject = this;
         this.release();
         dispatchEvent(new Event(Event.CLOSE));
         onHide();
      }
      
      override public function hide() : void
      {
         this.visible = false;
         onHide();
      }
      
      override protected function onShow() : void
      {
         if(m_shown == false)
         {
            if(m_modal)
            {
               InputManager.disableInput();
               Utilities.toggleInputAndChildren(Global.ui,false);
            }
            this.centerPopup();
            m_cursorId = UI.setCursor(null);
            Utilities.toggleInputAndChildren(this,true);
            m_shown = true;
            Global.stage.addEventListener(FullScreenEvent.FULL_SCREEN,onFullScreen);
            Global.stage.addEventListener(Event.RESIZE,onResize);
         }
         else
         {
            m_showOnLoad = true;
         }
         SoundManager.playSound("dialogSpawn");
      }
      
      override protected function release() : void
      {
         super.release();
      }
   }
}

