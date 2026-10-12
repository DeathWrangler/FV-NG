package GameMode
{
   import Classes.Constants.ZLocConstants;
   import Classes.Plot;
   import Classes.WorldObjectTypes;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.IconCursor;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Managers.SuperPlotManager;
   import flash.events.MouseEvent;
   
   public class GMSuperPlot extends GMDefault
   {
      
      private static var m_lastClickTime:int;
      
      private static const CLICK_THROTTLE_DURATION:int = 400;
      
      private var m_consumable:String;
      
      protected var m_acceptablePlots:Array;
      
      protected var m_targetObject:Plot;
      
      protected var m_cursor:IconCursor;
      
      protected var m_cursorLoaded:Boolean;
      
      public function GMSuperPlot(consumable:String, isGift:Boolean = true)
      {
         super(isGift,false);
         this.m_consumable = consumable;
         this.initCursor();
      }
      
      override public function enableMode() : void
      {
         var plot:Plot = null;
         super.enableMode();
         if(SuperPlotManager.isFeatureEnabled)
         {
            if(!SuperPlotManager.hasReachedWorldLimit())
            {
               this.m_acceptablePlots = SuperPlotManager.getNonSuperPlots();
               if(this.m_acceptablePlots.length > 0)
               {
                  for each(plot in this.m_acceptablePlots)
                  {
                     if(plot == this.m_targetObject)
                     {
                        selectObject(this.m_targetObject);
                     }
                     else
                     {
                        plot.showHighlight(true,Constants.COLOR_HIGHLIGHT_BLUE);
                     }
                  }
                  this.m_targetObject = null;
                  this.refresh();
               }
               else
               {
                  SuperPlotManager.showErrorToaster(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SuperPlotsErrorToaster_NoPlotsMessage"));
                  this.exit();
               }
            }
            else
            {
               SuperPlotManager.showErrorToaster(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SuperPlotsErrorToaster_PlotLimitMessage",{"limit":SuperPlotManager.getWorldLimit()}));
               this.exit();
            }
         }
         else
         {
            SuperPlotManager.showErrorToaster(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SuperPlotsErrorToaster_DisabledMessage"));
            this.exit();
         }
      }
      
      override public function disableMode() : void
      {
         var plot:Plot = null;
         super.disableMode();
         if(this.m_acceptablePlots)
         {
            for each(plot in this.m_acceptablePlots)
            {
               plot.showHighlight(false);
            }
         }
      }
      
      override protected function shouldScaleCursor() : Boolean
      {
         return false;
      }
      
      override protected function updateCursor() : void
      {
      }
      
      override protected function deselectObject() : void
      {
         var plot:Plot = m_highlightedObject as Plot;
         super.deselectObject();
         if(Boolean(plot) && this.isObjectSelectable(plot))
         {
            plot.showHighlight(true,Constants.COLOR_HIGHLIGHT_BLUE);
         }
      }
      
      override protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         var result:Boolean = false;
         var plot:Plot = object as Plot;
         if(plot)
         {
            result = !SuperPlotManager.isSuperPlot(plot);
         }
         return result;
      }
      
      override protected function getSelectableTypes() : int
      {
         return WorldObjectTypes.PLOT;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var plotIndex:int = 0;
         if(Boolean(!m_dragging) && Boolean(m_highlightedObject) && GlobalEngine.currentTime > m_lastClickTime + CLICK_THROTTLE_DURATION)
         {
            m_lastClickTime = GlobalEngine.currentTime;
            this.m_targetObject = m_highlightedObject as Plot;
            if(this.isObjectSelectable(this.m_targetObject))
            {
               SuperPlotManager.applyToPlot(this.m_targetObject);
               plotIndex = this.m_acceptablePlots.indexOf(this.m_targetObject);
               if(plotIndex != -1)
               {
                  this.m_acceptablePlots.splice(plotIndex,1);
               }
               this.refresh();
            }
            else if(this.m_targetObject.getId() == 0)
            {
               this.m_targetObject.showObjectBusy();
            }
         }
      }
      
      private function initCursor() : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_consumable);
         if(item)
         {
            this.m_cursor = new IconCursor(item.getImageByName("icon"),this.onCursorLoaded,"");
         }
      }
      
      private function onCursorLoaded() : void
      {
         if(Global.world.getActiveGameModes().indexOf(this) != -1)
         {
            this.m_cursorLoaded = true;
            this.refresh();
         }
      }
      
      protected function exit() : void
      {
         Global.world.removeGameMode(this);
         Global.world.setDefaultGameMode();
      }
      
      protected function refresh() : void
      {
         var itemCount:int = 0;
         if(this.m_cursorLoaded)
         {
            if(m_isGift)
            {
               if(this.m_acceptablePlots.length > 0)
               {
                  itemCount = Global.player.getGiftCountForItem(this.m_consumable);
                  if(itemCount > 0)
                  {
                     if(m_cursorId)
                     {
                        UI.removeCursor(m_cursorId);
                     }
                     this.m_cursor.text = "x" + itemCount;
                     m_cursorImage = this.m_cursor.cursorImage;
                     m_cursorId = UI.setCursor(m_cursorImage,false,this.shouldScaleCursor());
                  }
                  else
                  {
                     SuperPlotManager.conditionallyShowBuyInMarketToaster();
                     this.exit();
                  }
               }
               else
               {
                  SuperPlotManager.showErrorToaster(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SuperPlotsErrorToaster_NoPlotsMessage"));
                  this.exit();
               }
            }
            else
            {
               if(m_cursorId)
               {
                  UI.removeCursor(m_cursorId);
               }
               m_cursorImage = this.m_cursor.cursorImage;
               m_cursorId = UI.setCursor(m_cursorImage,false,this.shouldScaleCursor());
            }
         }
      }
   }
}

