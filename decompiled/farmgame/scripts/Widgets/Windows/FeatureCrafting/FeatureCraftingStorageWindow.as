package Widgets.Windows.FeatureCrafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingInventory;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.ImageLoader;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingExpansionSlotContainerFrame;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingStorageSlotContainerFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingStorageWindow extends FarmWindow
   {
      
      private var m_showExpand:Boolean;
      
      private var m_inventory:FeatureCraftingInventory;
      
      private var m_closeCallback:Function;
      
      private var m_backgroundWidget:ZwWidget;
      
      private var m_countTextField:ZwTextField;
      
      private var m_infoTextField:ZwTextField;
      
      private var m_storageTabButton:FarmAnimatedTextButton;
      
      private var m_expansionTabButton:FarmAnimatedTextButton;
      
      private var m_storageSlots:FeatureCraftingStorageSlotContainerFrame;
      
      private var m_expansionSlots:FeatureCraftingExpansionSlotContainerFrame;
      
      private var m_location:String = "";
      
      private var m_slotBGIcon:DisplayObject;
      
      public function FeatureCraftingStorageWindow(inventory:FeatureCraftingInventory, showExpand:Boolean = false, closeCallback:Function = null)
      {
         this.m_inventory = inventory;
         this.m_showExpand = showExpand;
         this.m_closeCallback = closeCallback;
         if(showExpand)
         {
            this.countShowExpand();
         }
         if(this.m_inventory.system.location != "")
         {
            this.m_location = this.m_inventory.system.location;
         }
         super(this.m_inventory.system.getAssetUrl(FeatureCraftingSystem.ASSET_DIALOG_STORAGE));
      }
      
      public static function display(inventory:FeatureCraftingInventory, showExpand:Boolean = false, closeCallback:Function = null) : FeatureCraftingStorageWindow
      {
         var window:FeatureCraftingStorageWindow = null;
         if(inventory)
         {
            window = new FeatureCraftingStorageWindow(inventory,showExpand,closeCallback);
            UI.displayPopup(window,false,"FeatureCraftingStorageWindow",true);
         }
         return window;
      }
      
      override protected function postLoadComplete() : void
      {
         var buttonBGSlot:String = null;
         addWidget(new ZwTextField(m_window.title_tf,this.m_inventory.friendlyTitle)) as ZwTextField;
         if(m_window.inventoryTitle_tf)
         {
            addWidget(new ZwTextField(m_window.inventoryTitle_tf,"Inventory")) as ZwTextField;
         }
         this.m_storageTabButton = addWidget(new FarmAnimatedTextButton(m_window.inventory_bt,ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StorageWindow_InventoryButton"),this.onStorageButtonClick)) as FarmAnimatedTextButton;
         if(m_window.inventory_bt.hasOwnProperty("mc_Button"))
         {
            if(this.m_location != "")
            {
               buttonBGSlot = Global.worldSettingsManager.getSlotBGImagePath("Button100",this.m_location);
               if(buttonBGSlot)
               {
                  ImageLoader.getInstance(Global.getAssetURL(buttonBGSlot)).getContent(this.onSlotUrlLoaded);
                  if(this.m_slotBGIcon)
                  {
                     m_window.inventory_bt["mc_Button"].addChild(this.m_slotBGIcon);
                     m_window.inventory_bt["mc_Button"].visible = true;
                  }
               }
            }
         }
         this.m_expansionTabButton = addWidget(new FarmAnimatedTextButton(m_window.expand_bt,ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StorageWindow_ExpandButton"),this.onExpandButtonClick)) as FarmAnimatedTextButton;
         if(m_window.expand_bt.hasOwnProperty("mc_Button"))
         {
            if(this.m_location != "")
            {
               buttonBGSlot = Global.worldSettingsManager.getSlotBGImagePath("Button100",this.m_location);
               if(buttonBGSlot)
               {
                  this.m_slotBGIcon = null;
                  ImageLoader.getInstance(Global.getAssetURL(buttonBGSlot)).getContent(this.onSlotUrlLoaded);
                  if(this.m_slotBGIcon)
                  {
                     m_window.expand_bt["mc_Button"].addChild(this.m_slotBGIcon);
                     m_window.expand_bt["mc_Button"].visible = true;
                  }
               }
            }
         }
         this.m_backgroundWidget = addWidget(new ZwWidget(m_window.back_mc)) as ZwWidget;
         this.m_countTextField = addWidget(new ZwTextField(m_window.inventory_tf,"")) as ZwTextField;
         this.m_infoTextField = addWidget(new ZwTextField(m_window.generic_tf,"")) as ZwTextField;
         this.m_storageSlots = addWidget(new FeatureCraftingStorageSlotContainerFrame(m_window.slotFrame_mc,this.m_location)) as FeatureCraftingStorageSlotContainerFrame;
         this.m_expansionSlots = addWidget(new FeatureCraftingExpansionSlotContainerFrame(m_window.expand_mc,this.m_location)) as FeatureCraftingExpansionSlotContainerFrame;
         if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_window.title_tf);
            if(m_window.inventoryTitle_tf)
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_window.inventoryTitle_tf);
            }
            TemplateUIUtility.applyExpansionSubTextColor(m_window.inventory_tf);
            TemplateUIUtility.applyExpansionGlowFilter(m_window.generic_tf);
            TemplateUIUtility.applyExpansionGlowFilter(m_window.inventory_bt.generic_tf);
            TemplateUIUtility.applyExpansionGlowFilter(m_window.expand_bt.generic_tf);
         }
         this.refresh();
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      override protected function release() : void
      {
         this.m_inventory = null;
         this.m_backgroundWidget = null;
         this.m_countTextField = null;
         this.m_closeCallback = null;
         this.m_storageSlots = null;
         this.m_expansionSlots = null;
         super.release();
      }
      
      public function get inventory() : FeatureCraftingInventory
      {
         return this.m_inventory;
      }
      
      public function refresh() : void
      {
         var backgroundElement:MovieClip = null;
         var backgroundFrameExists:Boolean = false;
         var backgroundFrameLabels:Array = null;
         var frameLabel:FrameLabel = null;
         if(Boolean(m_window) && Boolean(this.m_inventory))
         {
            backgroundElement = this.m_backgroundWidget.element as MovieClip;
            backgroundFrameExists = false;
            backgroundFrameLabels = backgroundElement.currentLabels;
            for each(frameLabel in backgroundFrameLabels)
            {
               if(frameLabel.name == this.m_inventory.name)
               {
                  backgroundElement.gotoAndStop(frameLabel.name);
                  backgroundFrameExists = true;
               }
            }
            if(!backgroundFrameExists)
            {
               GlobalEngine.assert(false,"Background element is missing frame label that matches the inventory name.");
            }
            if(this.m_showExpand)
            {
               if(this.m_inventory.hasReachedMaxInventory())
               {
                  this.m_infoTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StorageWindow_ExpandFullMessage",{"storageName":this.m_inventory.friendlyTitle});
                  this.m_expansionSlots.visible = false;
               }
               else
               {
                  this.m_infoTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StorageWindow_ExpandMessage",{"storageName":this.m_inventory.friendlyTitle});
                  this.m_expansionSlots.items = this.m_inventory.parts();
                  this.m_expansionSlots.visible = true;
               }
               this.m_storageSlots.visible = false;
            }
            else
            {
               this.m_infoTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"StorageWindow_InfoMessage_" + this.m_inventory.name,{"systemName":this.m_inventory.system.friendlyTitle});
               this.m_storageSlots.items = this.m_inventory.allGoodsForInventory();
               this.m_storageSlots.visible = true;
               this.m_expansionSlots.visible = false;
            }
            this.refreshCount();
         }
      }
      
      public function refreshCount() : void
      {
         if(Boolean(m_window) && Boolean(this.m_inventory))
         {
            this.m_countTextField.text = this.m_inventory.currentCount + "/" + this.m_inventory.currentLimit;
         }
      }
      
      private function onStorageButtonClick(event:MouseEvent) : void
      {
         if(this.m_showExpand)
         {
            this.m_showExpand = false;
            this.refresh();
         }
      }
      
      private function onExpandButtonClick(event:MouseEvent) : void
      {
         if(!this.m_showExpand)
         {
            this.m_showExpand = true;
            this.refresh();
            this.countShowExpand();
         }
      }
      
      private function countShowExpand() : void
      {
         StatsManager.count(this.m_inventory.system.name,"expand_storage_UI",this.m_inventory.name);
      }
   }
}

