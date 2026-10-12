package Widgets.Windows.Crafting
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.storage.CraftedItem;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Transactions.TCompleteCottageTutorial;
   import Transactions.TUseCraftedGood;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.CraftingUseGoodsSlotFrame;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class CraftingUseGoodsWindow extends FarmWindow
   {
      
      private var m_callingPopup:FarmWindow = null;
      
      private var m_fuelBarGaugeFarmTextTooltip:FarmTextTooltip = null;
      
      protected var m_CurrentCapacity:ZwTextField = null;
      
      private var m_progressBar:FarmProgressBar = null;
      
      private var m_fuelFrame:ZwFrame = null;
      
      private var m_avatarFrame:ZwFrame = null;
      
      protected var m_emptyFrame:ZwFrame;
      
      private var m_fuelAmount:ZwTextField = null;
      
      private var m_maxFuel:int;
      
      public function CraftingUseGoodsWindow(callingPopup:FarmWindow)
      {
         this.m_callingPopup = callingPopup;
         super("assets/dialogs/FV_Craft_UseGoods.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Crafting","CraftingMain_UseGoods")));
         addWidget(new ZwTextField(m_window.capacity_tf,ZLocUtils.t("Crafting","CraftedGoodStorageDialog_MaxCapacity",{"quantity":Global.storageSettings.maxStorageCap(CraftingConstants.CRAFTED_GOOD_STORAGE_NAME)})));
         this.m_CurrentCapacity = new ZwTextField(m_window.current_tf,ZLocUtils.t("Crafting","CraftedGoodStorageDialog_CurrentCapacity",{"quantity":Global.player.craftingState.totalCraftedGoods}));
         addWidget(this.m_CurrentCapacity);
         this.m_fuelFrame = new ZwFrame(m_window.fuel_mc);
         addWidget(this.m_fuelFrame);
         this.m_fuelFrame.addWidget(new ZwTextField(m_window.fuel_mc.generic_tf,ZLocUtils.t("Crafting","CurrentFuel")));
         this.m_fuelAmount = new ZwTextField(m_window.fuel_mc.fuelAmount_tf);
         this.m_progressBar = new FarmProgressBar(m_window.fuel_mc.outerBar_mc);
         this.m_progressBar.minimum = 0;
         this.m_progressBar.maximum = this.m_maxFuel = Global.player.energyMax;
         this.update(Global.player.energy);
         this.m_fuelFrame.addWidget(this.m_fuelAmount);
         this.m_fuelFrame.addWidget(this.m_progressBar);
         this.m_progressBar.animated = true;
         this.m_fuelBarGaugeFarmTextTooltip = new FarmTextTooltip(ZLocUtils.t("FarmGame","Energy_ToolTip",{"quantity":Global.player.energy}));
         this.m_fuelFrame.attachTooltip(this.m_fuelBarGaugeFarmTextTooltip);
         var isInTutorial:Boolean = CraftingManager.getInstance().inTutorialMode;
         this.m_avatarFrame = new ZwFrame(m_window.avatarMessage_mc);
         addWidget(this.m_avatarFrame,!isInTutorial);
         this.m_avatarFrame.addWidget(new ZwTextField(m_window.avatarMessage_mc.generic_tf,ZLocUtils.t("Crafting","CraftingUseGoods_GoodPerDay")));
         this.m_avatarFrame.addWidget(new ZwTextField(m_window.avatarMessage_mc.generic2_tf,ZLocUtils.t("Crafting","CraftingUseGoods_UseGoods")));
         this.m_emptyFrame = addWidget(new ZwFrame(m_window.emptyFrame_mc),false) as ZwFrame;
         this.m_emptyFrame.addWidget(new ZwTextField(m_window.emptyFrame_mc.generic_tf,ZLocUtils.t("Crafting","CraftingUseGoods_NoGoods")));
         var items:Array = Global.player.craftingState.allCraftedGoods;
         addWidget(new CraftingUseGoodsSlotFrame(m_window.frameCells_mc,items,this.onCraftedGoodUsed));
         if(items.length > 0)
         {
            (getWidget(m_window.frameCells_mc) as CraftingUseGoodsSlotFrame).visible = true;
            this.m_emptyFrame.visible = false;
         }
         else
         {
            (getWidget(m_window.frameCells_mc) as CraftingUseGoodsSlotFrame).visible = false;
            this.m_emptyFrame.visible = true;
         }
         FarmStatsManager.count("cottage_ui_new","view_use_good_page");
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var closeButton:ZwBaseWidget = null;
         super.onLoadComplete(event);
         if(Boolean(CraftingUI.getCraftingMainWindow()) && CraftingManager.getInstance().inTutorialMode)
         {
            CraftingUI.getCraftingMainWindow().displayTutorialMessage(CraftingMainWindow.TUTORIAL_TRADE_FOR_FUEL);
            TutorialUI.addBouncingArrows(m_window,new Matrix(0,1,1,0,m_window.x + 40,m_window.y + 185),new Matrix(0,1,-1,0,m_window.x + 240,m_window.y + 185));
            closeButton = getWidget(m_window.close_bt);
            if(closeButton)
            {
               closeButton.enabled = false;
            }
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         TutorialUI.removeBouncingArrows(m_window);
         if(Boolean(CraftingUI.getCraftingMainWindow()) && CraftingManager.getInstance().inTutorialMode)
         {
            CraftingUI.getCraftingMainWindow().displayTutorialMessage(CraftingMainWindow.TUTORIAL_FINISH);
         }
         close();
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_callingPopup = null;
         this.m_fuelBarGaugeFarmTextTooltip = null;
         this.m_CurrentCapacity = null;
         this.m_progressBar = null;
         this.m_fuelFrame = null;
         this.m_avatarFrame = null;
         this.m_fuelAmount = null;
      }
      
      public function update(fuel:int) : void
      {
         var tanks:* = int(Math.floor(fuel / this.m_maxFuel));
         var progress:int = fuel % this.m_maxFuel;
         if(fuel % this.m_maxFuel == 0)
         {
            tanks--;
            progress = this.m_maxFuel;
         }
         this.m_fuelAmount.text = "+" + tanks.toString();
         if(tanks > 0)
         {
            this.m_fuelAmount.text = "+" + tanks.toString();
         }
         else
         {
            this.m_fuelAmount.text = " ";
         }
         this.m_progressBar.progress = progress;
      }
      
      private function onCraftedGoodUsed(craftedItem:CraftedItem) : void
      {
         var icon:String = null;
         var message:String = null;
         var vehiclePrompt:GenericIconPopup = null;
         var item:FarmItem = null;
         var recipeItem:RecipeItem = null;
         var fuel:Number = NaN;
         var items:Array = null;
         var rewardItem:FarmItem = null;
         var fuelPrompt:GenericIconPopup = null;
         if(Global.world.getEquipment() == null && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME)
         {
            if(CraftingManager.getInstance().inTutorialMode)
            {
               Global.player.addGift("tractor");
               TransactionManager.addTransaction(new TCompleteCottageTutorial());
               UI.displayMessage(ZLocUtils.t("Crafting","CraftingTutorial_FreeTractor"),GenericPopup.TYPE_OK,this.onFreeTractorClose,"",true);
            }
            else
            {
               icon = Global.getAssetURL("assets/equipment/equip_tractor_icon.png");
               message = ZLocUtils.t("Dialogs","MustOwnVehicle");
               vehiclePrompt = new GenericIconPopup(message,GenericPopup.TYPE_ACCEPTCANCEL,function(event:GenericPopupEvent):void
               {
                  var callingPopup:* = undefined;
                  if(event.button == GenericPopup.ACCEPT)
                  {
                     callingPopup = m_callingPopup;
                     close();
                     if(callingPopup)
                     {
                        callingPopup.close();
                     }
                     UI.displayMarketDialog("crafting","vehicle");
                  }
               },icon);
               UI.displayPopup(vehiclePrompt,false);
            }
         }
         else if(Boolean(craftedItem) && craftedItem.level > 0)
         {
            TransactionManager.addTransaction(new TUseCraftedGood(craftedItem));
            Global.player.craftingState.decrementCraftedGood(craftedItem,1);
            item = Global.farmGameSettingsManager.getFarmItemByCode(craftedItem.itemCode);
            if(item)
            {
               FarmStatsManager.count("crafting_cottage","use_good",item.name);
            }
            recipeItem = Global.craftConfigSettings.getRecipeByProductItemCode(craftedItem.itemCode);
            fuel = recipeItem ? Global.craftConfigSettings.getFuelRewardForGood(craftedItem.level,recipeItem) : 0;
            Global.player.energy += fuel;
            this.update(Global.player.energy);
            this.m_fuelBarGaugeFarmTextTooltip.setText(ZLocUtils.t("FarmGame","Energy_ToolTip",{"quantity":Global.player.energy}));
            this.m_CurrentCapacity.text = ZLocUtils.t("Crafting","CraftedGoodStorageDialog_CurrentCapacity",{"quantity":Global.player.craftingState.totalCraftedGoods});
            if(Boolean(recipeItem) && Boolean(recipeItem.onUseItemCode))
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(recipeItem.onUseItemCode);
               UI.showMessage(ZLocUtils.t("Crafting","CraftingUseGoods_GotItem",{
                  "quantity":recipeItem.onUseQuantity,
                  "item":ZLocUtils.tk_pk(rewardItem.friendlyName)
               }),UI.BUTTON_LAYOUT_OK);
               Global.player.addGift(rewardItem.name,"0",recipeItem.onUseQuantity);
            }
            if(Global.player.getSeenFlag("use_crafted_good") == false)
            {
               Global.player.setSeenFlag("use_crafted_good");
               icon = Global.getAssetURL("assets/equipment/equip_gas_can_icon.png");
               message = ZLocUtils.t("Crafting","TradeGoodsForFuel");
               fuelPrompt = new GenericIconPopup(message,GenericPopup.TYPE_OK,null,icon);
               UI.displayPopup(fuelPrompt,false);
            }
            items = Global.player.craftingState.allCraftedGoods;
            (getWidget(m_window.frameCells_mc) as CraftingUseGoodsSlotFrame).update(items);
            if(items.length > 0)
            {
               (getWidget(m_window.frameCells_mc) as CraftingUseGoodsSlotFrame).visible = true;
               this.m_emptyFrame.visible = false;
            }
            else
            {
               (getWidget(m_window.frameCells_mc) as CraftingUseGoodsSlotFrame).visible = false;
               this.m_emptyFrame.visible = true;
            }
            if(Boolean(CraftingUI.getCraftingMainWindow()) && CraftingManager.getInstance().inTutorialMode)
            {
               close();
               CraftingUI.getCraftingMainWindow().displayTutorialMessage(CraftingMainWindow.TUTORIAL_FINISH);
            }
         }
         FarmStatsManager.count("cottage_ui_new","view_use_good_page","user_clicks_use_goods_button ");
      }
      
      private function onFreeTractorClose(event:Event) : void
      {
         close();
         var craftingMainWindow:CraftingMainWindow = CraftingUI.getCraftingMainWindow();
         if(craftingMainWindow)
         {
            craftingMainWindow.enableWindow(true);
            craftingMainWindow.close();
            craftingMainWindow.clearTutorial();
            CraftingManager.getInstance().inTutorialMode = false;
         }
         UI.displayGiftBoxWindow();
      }
      
      override public function centerPopup(pAbsolutePos:Point = null) : void
      {
         var bounds:Rectangle = this.getBounds(this);
         if(parent)
         {
            this.x = 15 + (Global.stage.stageWidth - bounds.width - bounds.x) / 2;
            this.y = (Global.stage.stageHeight - bounds.height - bounds.y) / 2;
         }
      }
   }
}

