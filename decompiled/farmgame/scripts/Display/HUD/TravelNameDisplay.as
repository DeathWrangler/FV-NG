package Display.HUD
{
   import Classes.Constants.Experiments;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Managers.FarmStatsManager;
   import Managers.WorldStatManager;
   import Widgets.Windows.TravelWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;
   
   public class TravelNameDisplay extends FarmNameDisplay
   {
      
      private static const ADDITIONAL_Y_OFFSET:int = 2;
      
      private static const FLYOUT_BUTTON_PREFIX:String = "slot";
      
      private static const FLYOUT_BUTTON_SUFFIX:String = "_mc";
      
      private static const FLYOUT_FRAME_HIDDEN:int = 1;
      
      private static const FLYOUT_FRAME_INTERVAL:int = 5;
      
      private static const MAX_NUM_FLYOUT_SLOTS:int = 8;
      
      private var m_window:MovieClip;
      
      private var m_flyoutCells:Vector.<TravelDropDownCell> = new Vector.<TravelDropDownCell>();
      
      private var m_isFlyoutOpen:Boolean = false;
      
      private var m_targetFlyoutFrame:int = 1;
      
      private var m_singleTravelDestination:String;
      
      public function TravelNameDisplay(assetUrl:String, singleTravelDestination:String = null)
      {
         super();
         LoadingManager.load(Global.getAssetURL(assetUrl),this.onAssetLoaded,LoadingManager.PRIORITY_HIGH);
         this.y += ADDITIONAL_Y_OFFSET;
         this.m_singleTravelDestination = singleTravelDestination;
      }
      
      public static function showImprovedTravelDialog() : Boolean
      {
         var showImprTravelUI:Boolean = false;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_ASIA_TRAVEL_DIALOG);
         switch(variant)
         {
            case 2:
            case 3:
               showImprTravelUI = true;
               break;
            case 1:
            case 0:
            default:
               showImprTravelUI = false;
         }
         return showImprTravelUI;
      }
      
      override public function release() : void
      {
         super.release();
         if(this.m_window)
         {
            this.m_window.removeEventListener(Event.ENTER_FRAME,this.onFrameAdvanceFlyout);
            if(this.m_window.travel_bt)
            {
               this.m_window.travel_bt.removeEventListener(MouseEvent.CLICK,this.onOpenFlyoutClicked);
               this.m_window.travel_bt.removeEventListener(MouseEvent.CLICK,this.onTravelToSingleDestination);
               this.m_window.travel_bt.removeEventListener(MouseEvent.CLICK,this.onClickShowNewTravelWindow);
            }
            if(this.m_window.nameBar_mc)
            {
               this.m_window.nameBar_mc.removeEventListener(MouseEvent.CLICK,this.onOpenFlyoutClicked);
               this.m_window.nameBar_mc.removeEventListener(MouseEvent.CLICK,this.onTravelToSingleDestination);
               this.m_window.nameBar_mc.removeEventListener(MouseEvent.CLICK,this.onClickShowNewTravelWindow);
            }
         }
      }
      
      private function onAssetLoaded(event:Event) : void
      {
         var shownewTravelDialog:Boolean = false;
         this.m_window = event.target.content as MovieClip;
         if(this.m_window)
         {
            this.m_window.buttonMode = true;
            this.m_window.useHandCursor = true;
            shownewTravelDialog = showImprovedTravelDialog();
            if(Boolean(this.m_window.nameBar_mc) && Boolean(this.m_window.nameBar_mc.generic_tf))
            {
               m_farmNameTextField = this.m_window.nameBar_mc.generic_tf;
               m_farmNameTextField.text = m_farmName;
               m_farmNameTextField.autoSize = TextFieldAutoSize.CENTER;
               m_farmNameTextField.defaultTextFormat = HUDFonts.TitleText;
               m_farmNameTextField.setTextFormat(HUDFonts.TitleText);
               m_farmNameTextField.embedFonts = true;
               if(this.m_singleTravelDestination)
               {
                  this.m_window.nameBar_mc.addEventListener(MouseEvent.CLICK,this.onTravelToSingleDestination);
               }
               else if(shownewTravelDialog)
               {
                  this.m_window.nameBar_mc.addEventListener(MouseEvent.CLICK,this.onClickShowNewTravelWindow);
               }
               else
               {
                  this.m_window.nameBar_mc.addEventListener(MouseEvent.CLICK,this.onOpenFlyoutClicked);
               }
               m_farmNameTextField.mouseEnabled = false;
            }
            if(this.m_window.travel_bt)
            {
               if(this.m_singleTravelDestination)
               {
                  this.m_window.travel_bt.addEventListener(MouseEvent.CLICK,this.onTravelToSingleDestination);
               }
               else if(shownewTravelDialog)
               {
                  this.m_window.travel_bt.addEventListener(MouseEvent.CLICK,this.onClickShowNewTravelWindow);
               }
               else
               {
                  this.m_window.travel_bt.addEventListener(MouseEvent.CLICK,this.onOpenFlyoutClicked);
               }
            }
            this.closeFlyout();
            this.addChild(this.m_window);
         }
      }
      
      private function onClickShowNewTravelWindow(event:Event = null) : void
      {
         FarmStatsManager.count(UI.UI_BUTTON_CLICKS_COUNTER,"travel","hud");
         this.showNewTravelWindow();
      }
      
      public function showNewTravelWindow() : void
      {
         if(!showImprovedTravelDialog())
         {
            return;
         }
         this.m_targetFlyoutFrame = FLYOUT_FRAME_HIDDEN;
         var travelWindow:TravelWindow = new TravelWindow();
         travelWindow.setUpTravelOptions();
         UI.displayPopup(travelWindow,false,"travelWindow",true);
      }
      
      private function onTravelToSingleDestination(event:MouseEvent) : void
      {
         WorldStatManager.trackWorldIconClick(Global.worldManager.currentWorldType,this.m_singleTravelDestination);
         Global.worldManager.showTravelFreezeConfirmation(this.m_singleTravelDestination);
      }
      
      private function onOpenFlyoutClicked(event:Event) : void
      {
         if(this.m_isFlyoutOpen)
         {
            this.closeFlyout();
         }
         else
         {
            this.openFlyout();
         }
      }
      
      public function openFlyout() : void
      {
         this.m_targetFlyoutFrame = Global.worldManager.getAvailableTravelWorlds().length * FLYOUT_FRAME_INTERVAL + 1;
         this.m_window.addEventListener(Event.ENTER_FRAME,this.onFrameAdvanceFlyout);
         this.m_isFlyoutOpen = true;
      }
      
      public function closeFlyout() : void
      {
         this.m_targetFlyoutFrame = FLYOUT_FRAME_HIDDEN;
         this.m_window.addEventListener(Event.ENTER_FRAME,this.onFrameAdvanceFlyout);
         this.m_isFlyoutOpen = false;
      }
      
      private function onFrameAdvanceFlyout(event:Event) : void
      {
         var currentFrame:int = 0;
         if(this.m_window)
         {
            currentFrame = this.m_window.currentFrame;
            if(currentFrame < this.m_targetFlyoutFrame && currentFrame < this.m_window.totalFrames)
            {
               this.m_window.gotoAndStop(++currentFrame);
               if(currentFrame == FLYOUT_FRAME_HIDDEN + 1)
               {
                  this.updateFlyoutCells();
               }
            }
            else if(currentFrame > this.m_targetFlyoutFrame && currentFrame > 1)
            {
               this.m_window.gotoAndStop(--currentFrame);
            }
            else
            {
               this.m_window.removeEventListener(Event.ENTER_FRAME,this.onFrameAdvanceFlyout);
            }
         }
      }
      
      protected function updateFlyoutCells() : void
      {
         var travelCell:TravelDropDownCell = null;
         var availableWorlds:Array = null;
         var len:int = 0;
         var lastPriority:int = 0;
         var i:int = 0;
         var worldConfig:Object = null;
         var hudSkinConfig:HUDSkinConfig = null;
         var listPriority:int = 0;
         var tempWorld:String = null;
         var buttonElement:MovieClip = null;
         for each(travelCell in this.m_flyoutCells)
         {
            travelCell.release();
         }
         this.m_flyoutCells = new Vector.<TravelDropDownCell>();
         availableWorlds = Global.worldManager.getAvailableTravelWorlds();
         len = int(availableWorlds.length);
         lastPriority = 0;
         for(i = 0; i < len; i++)
         {
            worldConfig = Global.worldSettingsManager.getConfigByWorld(availableWorlds[i]);
            if(Boolean(worldConfig) && Boolean(worldConfig.hudSkinConfig))
            {
               hudSkinConfig = worldConfig.hudSkinConfig as HUDSkinConfig;
               if(hudSkinConfig)
               {
                  listPriority = hudSkinConfig.travelDropDownListPriority;
                  if(listPriority < lastPriority)
                  {
                     tempWorld = availableWorlds[i - 1];
                     availableWorlds[i - 1] = availableWorlds[i];
                     availableWorlds[i] = tempWorld;
                     i = 0;
                     lastPriority = 0;
                  }
                  else
                  {
                     lastPriority = listPriority;
                  }
               }
            }
         }
         var len2:int = int(availableWorlds.length);
         for(var elementIdx:int = 0; elementIdx < len2; elementIdx++)
         {
            buttonElement = this.getButtonElement(elementIdx);
            if(buttonElement)
            {
               this.m_flyoutCells.push(new TravelDropDownCell(availableWorlds[elementIdx],buttonElement,this));
            }
         }
      }
      
      private function getButtonElement(buttonIndex:int) : MovieClip
      {
         var buttonName:String = null;
         var result:MovieClip = null;
         if(Boolean(this.m_window) && Boolean(this.m_window.flyout_mc))
         {
            buttonName = FLYOUT_BUTTON_PREFIX + buttonIndex.toString() + FLYOUT_BUTTON_SUFFIX;
            result = this.m_window.flyout_mc[buttonName];
         }
         return result;
      }
   }
}

