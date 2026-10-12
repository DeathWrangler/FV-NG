package Widgets.Windows
{
   import Cache.Classes.ZCacheUtil;
   import Display.ActionMenu;
   import Display.ActionMultiButton;
   import Display.UI;
   import Events.DynamicObjectEvent;
   import Managers.DecoratorModeManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmVillageManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.FarmVillageOrderBoardSlot;
   import Widgets.Windows.Crafting.VillageIngredientStorageWindow;
   import Widgets.Windows.Crafting.VillageResourceBuildingWindow;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class VillageHudWindow extends FarmWindow
   {
      
      private const ASSET_PATH:String = "assets/hud/hudSkin_Village.swf";
      
      private var m_oldStageHeight:int = 0;
      
      protected const YMENUOFFSET:int = -95;
      
      protected var m_gifts:ActionMultiButton;
      
      private var m_orderBoardFrame:GenericSlotContainerFrame;
      
      public function VillageHudWindow()
      {
         super(this.ASSET_PATH,false);
         shouldFreeze = false;
      }
      
      override protected function postLoadComplete() : void
      {
         var mainElement:MovieClip = null;
         var mainFrame:ZwFrame = null;
         var buttonsElement:MovieClip = null;
         var buttonsFrame:ZwFrame = null;
         var actionMenu:ActionMenu = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("main_mc"))
         {
            mainElement = m_window.main_mc;
            mainFrame = addWidget(new ZwFrame(m_window.main_mc)) as ZwFrame;
            if(mainElement.hasOwnProperty("HUDbuttons_mc"))
            {
               buttonsElement = mainElement.HUDbuttons_mc;
               buttonsFrame = mainFrame.addWidget(new ZwFrame(buttonsElement)) as ZwFrame;
               actionMenu = Global.ui.getActionMenu();
               if(buttonsElement.hasOwnProperty("ingredientStorage_bt"))
               {
                  buttonsFrame.addWidget(new FarmAnimatedButton(buttonsElement.ingredientStorage_bt,this.onIngredientStorageClick));
               }
               if(buttonsElement.hasOwnProperty("decoMode_bt"))
               {
                  Global.stage.addEventListener(DecoratorModeManager.CLOSE_EVENT,this.decoModeClosed);
                  buttonsFrame.addWidget(new FarmAnimatedButton(buttonsElement.decoMode_bt,ZCacheUtil.applyPartial(this.decoModeClicked,this,[actionMenu])));
               }
               if(buttonsElement.hasOwnProperty("market_bt"))
               {
                  buttonsFrame.addWidget(new FarmAnimatedButton(buttonsElement.market_bt,ZCacheUtil.applyPartial(this.marketClicked,this,[actionMenu])));
               }
               if(buttonsElement.hasOwnProperty("workshop_bt"))
               {
                  buttonsFrame.addWidget(new FarmAnimatedButton(buttonsElement.workshop_bt,this.onClickWorkShopButton));
               }
               if(buttonsElement.hasOwnProperty("giftBox_bt"))
               {
                  this.m_gifts = actionMenu.getVillageGiftMenuButton();
                  this.m_gifts.x = buttonsFrame.x + 28;
                  this.m_gifts.y = buttonsFrame.y - 98;
                  m_window.addChild(this.m_gifts);
               }
               if(buttonsElement.hasOwnProperty("worldStorage_bt"))
               {
                  buttonsFrame.addWidget(new FarmAnimatedButton(buttonsElement.worldStorage_bt,actionMenu.onInventory));
               }
               if(buttonsElement.hasOwnProperty("selection_bt"))
               {
                  buttonsFrame.addWidget(new FarmAnimatedButton(buttonsElement.selection_bt,actionMenu.onWalk));
               }
               if(buttonsElement.hasOwnProperty("zoomIn_bt"))
               {
                  buttonsFrame.addWidget(new FarmAnimatedButton(buttonsElement.zoomIn_bt,UI.onZoomInClick));
               }
               if(buttonsElement.hasOwnProperty("zoomOut_bt"))
               {
                  buttonsFrame.addWidget(new FarmAnimatedButton(buttonsElement.zoomOut_bt,UI.onZoomOutClick));
               }
               if(buttonsElement.hasOwnProperty("fullScreen_bt"))
               {
                  buttonsFrame.addWidget(new FarmAnimatedButton(buttonsElement.fullScreen_bt,Global.ui.onFullscreenClick));
               }
            }
            if(mainElement.hasOwnProperty("orders_mc"))
            {
               this.m_orderBoardFrame = new GenericSlotContainerFrame(mainElement.orders_mc,FarmVillageOrderBoardSlot,null,this);
               addWidget(this.m_orderBoardFrame);
            }
         }
         this.m_oldStageHeight = GlobalEngine.stage.stageHeight;
         Global.stage.addEventListener(Event.RESIZE,this.resizeCallback);
         Global.stage.addEventListener(FarmVillageManager.ORDER_BOARD_REFRESH_EVENT,this.onOrderBoardRefresh);
         Global.stage.addEventListener(FarmVillageManager.ORDER_FILLED,this.onOrderBoardRefresh);
         Global.stage.addEventListener(FarmVillageManager.ORDER_SKIPPED,this.onOrderBoardRefresh);
         Global.stage.addEventListener(FarmVillageManager.ORDER_BOARD_SET_DATA_EVENT,this.onOrderBoardSetData);
         FarmVillageManager.instance.initOrderBoardData();
      }
      
      override protected function release() : void
      {
         Global.stage.removeEventListener(Event.RESIZE,this.resizeCallback);
         Global.stage.removeEventListener(DecoratorModeManager.CLOSE_EVENT,this.decoModeClosed);
         Global.stage.removeEventListener(FarmVillageManager.ORDER_BOARD_REFRESH_EVENT,this.onOrderBoardRefresh);
         Global.stage.removeEventListener(FarmVillageManager.ORDER_FILLED,this.onOrderBoardRefresh);
         Global.stage.removeEventListener(FarmVillageManager.ORDER_SKIPPED,this.onOrderBoardRefresh);
         Global.stage.removeEventListener(FarmVillageManager.ORDER_BOARD_SET_DATA_EVENT,this.onOrderBoardSetData);
         super.release();
      }
      
      private function decoModeClosed(event:Event) : void
      {
         this.visible = true;
      }
      
      private function onOrderBoardRefresh(event:Event) : void
      {
         this.m_orderBoardFrame.refresh();
      }
      
      private function onOrderBoardSetData(event:DynamicObjectEvent) : void
      {
         this.m_orderBoardFrame.setData(event.data as Array);
      }
      
      private function decoModeClicked(actionMenu:ActionMenu, event:Event) : void
      {
         actionMenu.onDesignMode();
         this.visible = false;
      }
      
      private function marketClicked(actionMenu:ActionMenu, event:MouseEvent) : void
      {
         MarketWindow.previousType = FarmGameSettingsManager.TYPE_VILLAGE;
         actionMenu.onMarket(event);
      }
      
      private function resizeCallback(event:Event) : void
      {
         var stageHeight:int = GlobalEngine.stage.stageHeight;
         m_window.y += (stageHeight - this.m_oldStageHeight) / 2;
         this.m_oldStageHeight = stageHeight;
         Global.hud.setNeighborSearchBarVisibility(false);
      }
      
      private function onClickWorkShopButton(event:MouseEvent) : void
      {
         var resourceBuildingWindow:VillageResourceBuildingWindow = new VillageResourceBuildingWindow();
         UI.displayPopup(resourceBuildingWindow);
      }
      
      private function onIngredientStorageClick(event:MouseEvent) : void
      {
         UI.displayPopup(new VillageIngredientStorageWindow());
      }
   }
}

