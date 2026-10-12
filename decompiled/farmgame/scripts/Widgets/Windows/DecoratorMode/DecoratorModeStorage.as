package Widgets.Windows.DecoratorMode
{
   import Classes.FarmGameObject;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.FarmGameWorldEvent;
   import GameMode.GMClear;
   import GameMode.GMObjectMove;
   import GameMode.GameMode;
   import Managers.DecoratorModeManager;
   import Managers.FreezeManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Storage.DecoratorModeStorageSlotFrame;
   import Widgets.Frames.Storage.DecoratorModeTemporaryStorageFrame;
   import Widgets.Frames.Storage.StorageSlotFrame;
   import Widgets.Windows.Storage.StorageWindow;
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class DecoratorModeStorage extends StorageWindow
   {
      
      private const ASSET_PATH:String = "assets/dialogs/FV_DecoStorage.swf";
      
      private const DECORATOR_MODE_WHATSTHIS:String = "Decorator_Mode_WhatsThis_First";
      
      private const ALMOST_FULL_THRESHOLD:int = 5;
      
      private const SCREEN_BUFFER:int = 5;
      
      private var STORAGE_ERROR_OFFSET_Y:int = 0;
      
      private var STORAGE_ERROR_OFFSET_X:int = 0;
      
      private var m_decoToolsFrame:ZwFrame;
      
      private var m_tempStorageFrame:ZwFrame;
      
      private var m_oopsFrame:ZwFrame;
      
      private var m_oopsText:ZwTextField;
      
      private var m_tempStorageSlotFrame:DecoratorModeTemporaryStorageFrame;
      
      private var m_tempCurrentUsageTf:ZwTextField;
      
      private var m_tempCurrentCapacityTf:ZwTextField;
      
      private var m_almostFull:ZwTextField;
      
      private var m_tempAlmostFull:ZwTextField;
      
      private var m_currentFarmTf:ZwTextField;
      
      private var m_interactiveWidgets:Array;
      
      public function DecoratorModeStorage(storage:StorageBuilding = null)
      {
         super(storage,this.ASSET_PATH,false);
         shouldFreeze = false;
         this.m_interactiveWidgets = new Array();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         Global.world.addEventListener(FarmGameWorldEvent.USER_CHANGED,this.onInventoryChange);
         if(m_window["target_mc"] != null)
         {
            addWidget(new ZwWidget(m_window["target_mc"]));
            this.STORAGE_ERROR_OFFSET_X = m_window["target_mc"].x + m_window["target_mc"].width / 2;
            this.STORAGE_ERROR_OFFSET_Y = m_window["target_mc"].y;
            m_window["target_mc"].addEventListener(MouseEvent.CLICK,this.onStoreClick);
         }
         if(m_window["storage_tf"] != null)
         {
            addWidget(this.m_almostFull = new ZwTextField(m_window["storage_tf"],ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_almostfull")));
            this.m_almostFull.visible = false;
         }
         if(m_window["oops_mc"] != null)
         {
            addWidget(this.m_oopsFrame = new ZwFrame(m_window["oops_mc"]));
            if(this.m_oopsFrame)
            {
               this.m_oopsFrame.addWidget(this.m_oopsText = new ZwTextField(this.m_oopsFrame.element["generic_tf"],""));
               this.m_oopsFrame.visible = false;
            }
         }
         if(m_window["currentfarm_tf"] != null)
         {
            addWidget(this.m_currentFarmTf = new ZwTextField(m_window["currentfarm_tf"],""));
            this.setCurrentWorldText();
         }
         if(m_expand_bt)
         {
            m_expand_bt.visible = m_inventoryCapacity > 0;
         }
         m_current_tf.text = ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_current",{"amount":m_inventoryUsage});
         m_capacity_tf.text = ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_capacity",{"amount":m_inventoryCapacity});
         m_expand_bt.text = ZLocUtils.t("Dialogs","DecoratorMode_Storage_expand");
         this.addTemporaryStorage();
         this.addDecoTools();
         this.setAlmostFullVisible();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         var seenBefore:Boolean = Global.player.getSeenFlag(this.DECORATOR_MODE_WHATSTHIS);
         if(!seenBefore)
         {
            this.showWhatIsThis();
         }
      }
      
      private function addTemporaryStorage() : void
      {
         var interactiveWidget:ZwBaseWidget = null;
         var tempStorageMc:MovieClip = null;
         var tempStorageMcName:String = "tempStorage_mc";
         if(m_window[tempStorageMcName] != null)
         {
            addWidget(this.m_tempStorageFrame = new ZwFrame(m_window[tempStorageMcName]));
            if(this.m_tempStorageFrame != null)
            {
               tempStorageMc = this.m_tempStorageFrame.element as MovieClip;
               tempStorageMc.mouseEnabled = false;
               if(tempStorageMc["title_tf"] != null)
               {
                  this.m_tempStorageFrame.addWidget(new ZwTextField(tempStorageMc["title_tf"],ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_title")));
               }
               if(tempStorageMc["whatisthis_mc"] != null)
               {
                  this.m_tempStorageFrame.addWidget(interactiveWidget = new FarmAnimatedButton(tempStorageMc["whatisthis_mc"],this.showWhatIsThis));
                  this.m_interactiveWidgets.push(interactiveWidget);
               }
               if(tempStorageMc["storage_tf"] != null)
               {
                  this.m_tempStorageFrame.addWidget(this.m_tempAlmostFull = new ZwTextField(tempStorageMc["storage_tf"],ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_almostfull")));
                  this.m_tempAlmostFull.visible = false;
               }
               if(tempStorageMc["expand_bt"] != null)
               {
                  this.m_tempStorageFrame.addWidget(interactiveWidget = new FarmAnimatedTextButton(tempStorageMc["expand_bt"],ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_expand"),this.onExpandButtonClick));
                  interactiveWidget.visible = m_inventoryCapacity > 0;
                  this.m_interactiveWidgets.push(interactiveWidget);
               }
               if(tempStorageMc["current_tf"] != null)
               {
                  this.m_tempStorageFrame.addWidget(this.m_tempCurrentUsageTf = new ZwTextField(tempStorageMc["current_tf"],ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_current",{"amount":m_inventoryUsage})));
               }
               if(tempStorageMc["capacity_tf"] != null)
               {
                  this.m_tempStorageFrame.addWidget(this.m_tempCurrentCapacityTf = new ZwTextField(tempStorageMc["capacity_tf"],ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_capacity",{"amount":m_inventoryCapacity})));
               }
               if(tempStorageMc["slotFrame_mc"] != null)
               {
                  this.m_tempStorageFrame.addWidget(this.m_tempStorageSlotFrame = new DecoratorModeTemporaryStorageFrame(tempStorageMc["slotFrame_mc"],usedTypes,this));
               }
               if(tempStorageMc["target_mc"] != null)
               {
                  tempStorageMc["target_mc"].addEventListener(MouseEvent.CLICK,this.m_tempStorageSlotFrame.onStoreClick);
                  this.m_tempStorageFrame.addWidget(new ZwWidget(tempStorageMc["target_mc"]));
               }
               if(tempStorageMc["close_bt"] != null)
               {
                  this.m_tempStorageFrame.addWidget(interactiveWidget = new FarmButton(tempStorageMc["close_bt"],onClose));
                  this.m_interactiveWidgets.push(interactiveWidget);
               }
            }
         }
      }
      
      private function addDecoTools() : void
      {
         var interactiveWidget:ZwBaseWidget = null;
         var decoToolsMc:MovieClip = null;
         var decoToolsMcName:String = "decoTools_mc";
         if(m_window[decoToolsMcName] != null)
         {
            addWidget(this.m_decoToolsFrame = new ZwFrame(m_window[decoToolsMcName]));
            if(this.m_decoToolsFrame)
            {
               decoToolsMc = this.m_decoToolsFrame.element as MovieClip;
               if(decoToolsMc["move_bt"] != null)
               {
                  this.m_decoToolsFrame.addWidget(interactiveWidget = new FarmAnimatedButton(decoToolsMc["move_bt"],this.onMoveToolClick));
                  this.m_interactiveWidgets.push(interactiveWidget);
               }
               if(decoToolsMc["rotate_bt"] != null)
               {
                  this.m_decoToolsFrame.addWidget(interactiveWidget = new FarmAnimatedButton(decoToolsMc["rotate_bt"],this.onRotateToolClick));
                  this.m_interactiveWidgets.push(interactiveWidget);
               }
               if(decoToolsMc["store_bt"] != null)
               {
                  this.m_decoToolsFrame.addWidget(interactiveWidget = new FarmAnimatedButton(decoToolsMc["store_bt"],this.onStoreToolClick));
                  this.m_interactiveWidgets.push(interactiveWidget);
               }
               if(decoToolsMc["recycle_bt"] != null)
               {
                  this.m_decoToolsFrame.addWidget(interactiveWidget = new FarmAnimatedButton(decoToolsMc["recycle_bt"],this.onRecycleToolClick));
                  this.m_interactiveWidgets.push(interactiveWidget);
               }
            }
         }
      }
      
      private function onMoveToolClick(event:Event) : void
      {
         this.setCurrentGameMode(DecoratorModeManager.MOVE_MODE);
         StatsManager.count(DecoratorModeManager.STATS_KINGDOM,"ui_clicks","toolbar","move_tool");
      }
      
      private function onRotateToolClick(event:Event) : void
      {
         this.setCurrentGameMode(DecoratorModeManager.ROTATE_MODE);
         StatsManager.count(DecoratorModeManager.STATS_KINGDOM,"ui_clicks","toolbar","rotate_tool");
      }
      
      private function onRecycleToolClick(event:Event) : void
      {
         StatsManager.count(DecoratorModeManager.STATS_KINGDOM,"ui_clicks","toolbar","recycle_tool");
         this.close();
         Global.world.addGameMode(new GMClear());
      }
      
      private function onStoreToolClick(event:Event) : void
      {
         this.setCurrentGameMode(DecoratorModeManager.STORE_MODE);
         StatsManager.count(DecoratorModeManager.STATS_KINGDOM,"ui_clicks","toolbar","store_tool");
      }
      
      private function setCurrentGameMode(mode:String) : void
      {
         DecoratorModeManager.instance.setGameMode(mode);
      }
      
      override protected function onExpandButtonClick(event:MouseEvent) : void
      {
         UI.suppressPopupQueue = false;
         super.onExpandButtonClick(event);
      }
      
      override protected function onShippingLicensesButtonClick(event:MouseEvent) : void
      {
         UI.suppressPopupQueue = false;
         super.onShippingLicensesButtonClick(event);
      }
      
      public function showErrorDialog(localX:Number, localY:Number) : void
      {
         var text:String = null;
         if(m_inventoryCapacity == 0)
         {
            text = ZLocUtils.t("Dialogs","DecoratorMode_Error_None");
         }
         else
         {
            text = m_inventoryCapacity > 0 && m_inventoryUsage == m_inventoryCapacity ? ZLocUtils.t("Dialogs","DecoratorMode_Error_Full") : ZLocUtils.t("Dialogs","DecoratorMode_Error_CantStore");
         }
         this.m_oopsFrame.x = localX - this.m_oopsFrame.width / 2;
         this.m_oopsFrame.y = localY - this.m_oopsFrame.height;
         this.m_oopsText.text = text;
         this.m_oopsFrame.element.alpha = 1;
         this.m_oopsFrame.visible = true;
         TweenLite.to(this.m_oopsFrame.element,3,{
            "alpha":0,
            "onComplete":this.hideErrorPopup
         });
      }
      
      private function hideErrorPopup() : void
      {
         if(this.m_oopsFrame.element != null)
         {
            this.m_oopsFrame.visible = false;
         }
      }
      
      override protected function addSlotFrame() : void
      {
         m_slotFrame = addWidget(new DecoratorModeStorageSlotFrame(m_window.slotFrame_mc,[],this)) as StorageSlotFrame;
      }
      
      public function onInventoryChange(event:FarmGameWorldEvent) : void
      {
         if(DecoratorModeManager.instance.storing)
         {
            m_world = Global.worldManager.currentWorldType;
         }
         this.reload();
         this.setStorageCapacityText();
         this.m_tempStorageSlotFrame.setItemCounts(usedTypes);
         this.m_tempStorageSlotFrame.refreshTemporaryStoredItems();
      }
      
      override public function reload() : void
      {
         super.reload();
         this.setStorageCapacityText();
         this.setAlmostFullVisible();
         this.setCurrentWorldText();
      }
      
      private function setCurrentWorldText() : void
      {
         if(this.m_currentFarmTf != null)
         {
            this.m_currentFarmTf.text = Global.worldManager.getWorldFriendlyName(m_world);
         }
      }
      
      private function setStorageCapacityText() : void
      {
         if(m_capacity_tf)
         {
            m_capacity_tf.text = ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_capacity",{"amount":m_inventoryCapacity});
         }
         if(m_current_tf)
         {
            m_current_tf.text = ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_current",{"amount":m_inventoryUsage});
         }
         if(this.m_tempCurrentUsageTf)
         {
            this.m_tempCurrentUsageTf.text = ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_current",{"amount":m_inventoryUsage});
         }
         if(this.m_tempCurrentCapacityTf)
         {
            this.m_tempCurrentCapacityTf.text = ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_capacity",{"amount":m_inventoryCapacity});
         }
      }
      
      override public function setButtonEnable(enable:Boolean) : void
      {
         var widget:ZwBaseWidget = null;
         super.setButtonEnable(enable);
         for each(widget in this.m_interactiveWidgets)
         {
            widget.enabled = enable;
         }
      }
      
      private function setAlmostFullVisible() : void
      {
         var almostFull:Boolean = m_inventoryCapacity > 0 && m_inventoryUsage >= m_inventoryCapacity - this.ALMOST_FULL_THRESHOLD;
         var text:String = m_inventoryUsage == m_inventoryCapacity ? ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_full") : ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_almostfull");
         if(this.m_almostFull)
         {
            this.m_almostFull.visible = almostFull;
            this.m_almostFull.text = text;
         }
         if(this.m_tempAlmostFull)
         {
            this.m_tempAlmostFull.visible = almostFull;
            this.m_tempAlmostFull.text = text;
         }
      }
      
      private function onStoreClick(event:MouseEvent) : void
      {
         var gmMove:GMObjectMove = null;
         var item:FarmGameObject = null;
         var resource:MapResource = null;
         var successfullyAdded:Boolean = false;
         var gm:GameMode = Global.world.getTopGameMode();
         if(gm != null && gm is GMObjectMove)
         {
            gmMove = gm as GMObjectMove;
            if(!gmMove.isFromStorage())
            {
               item = gmMove.selectedObject;
               resource = item as MapResource;
               if(resource != null)
               {
                  successfullyAdded = DecoratorModeManager.instance.storeItem(resource);
                  if(successfullyAdded)
                  {
                     gmMove.setStoredSuccess(true);
                     this.setCurrentGameMode(DecoratorModeManager.MOVE_MODE);
                     StatsManager.count(DecoratorModeManager.STATS_KINGDOM,"ui_clicks","storage","stored_item");
                  }
                  else
                  {
                     this.showErrorDialog(this.STORAGE_ERROR_OFFSET_X,this.STORAGE_ERROR_OFFSET_Y);
                  }
               }
            }
            else
            {
               this.setCurrentGameMode(DecoratorModeManager.MOVE_MODE);
            }
         }
      }
      
      private function showWhatIsThis(event:Event = null) : void
      {
         var seenBefore:Boolean = Global.player.getSeenFlag(this.DECORATOR_MODE_WHATSTHIS);
         if(!seenBefore)
         {
            Global.player.setSeenFlag(this.DECORATOR_MODE_WHATSTHIS);
         }
         UI.suppressPopupQueue = false;
         this.setButtonEnable(false);
         TutorialUI.displayBundleTutorialWindow("Dialogs","DecoratorMode_","assets/dialogs/FV_Support/FV_DecoStorage/DecoStorage",false,this.tutorialCloseCallback);
      }
      
      private function tutorialCloseCallback() : void
      {
         FreezeManager.thaw(true);
         UI.suppressPopupQueue = true;
         this.setButtonEnable(true);
      }
      
      override protected function onShow() : void
      {
         UI.suppressPopupQueue = true;
         if(FreezeManager.isRenderFrozen())
         {
            FreezeManager.thaw(true);
         }
         super.onShow();
      }
      
      override public function centerPopup(pAbsolutePos:Point = null) : void
      {
         super.centerPopup(pAbsolutePos);
         if(m_window["size_mc"] != null && m_window["target_mc"] != null)
         {
            this.y = GlobalEngine.stage.stageHeight - (m_window["target_mc"].y + m_window["target_mc"].height);
         }
         this.m_tempStorageFrame.x = -x;
         this.m_decoToolsFrame.x = GlobalEngine.stage.stageWidth - (this.m_decoToolsFrame.width + this.SCREEN_BUFFER) - x;
      }
      
      override public function close() : void
      {
         DecoratorModeManager.instance.stopDecoMode();
         super.close();
      }
      
      override protected function release() : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_CHANGED,this.onInventoryChange);
         super.release();
      }
   }
}

