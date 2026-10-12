package Widgets.Windows.Crafting
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Engine.Utilities;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.FarmStatsManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.CraftingGetGoodsSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class CraftingGetGoodsWindow extends FarmWindow
   {
      
      protected var m_currentCapacity:ZwTextField = null;
      
      private var m_avatarFrame:ZwFrame = null;
      
      protected var m_emptyFrame:ZwFrame;
      
      protected var m_coinMeter:ZwWidget;
      
      protected var m_coinMeterValue:ZwTextField;
      
      public var timeUntilRolloverDays:int = 0;
      
      public var timeUntilRolloverHours:int = 0;
      
      public var timeUntilRolloverMinutes:int = 0;
      
      public var timeUntilRolloverSeconds:int = 0;
      
      public function CraftingGetGoodsWindow()
      {
         var asset:String = "assets/dialogs/FV_Craft_AvailGoods.swf";
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SORT_GET_GOODS_WINDOW) == 1)
         {
            asset = "assets/dialogs/FV_Craft_AvailGoods_v1.swf";
         }
         super(asset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Crafting","CraftingGetGoods_AvailableGoods")));
         addWidget(new ZwTextField(m_window.capacity_tf,ZLocUtils.t("Crafting","CraftedGoodStorageDialog_MaxCapacity",{"quantity":Global.storageSettings.maxStorageCap(CraftingConstants.CRAFTED_GOOD_STORAGE_NAME)})));
         this.m_currentCapacity = new ZwTextField(m_window.current_tf,ZLocUtils.t("Crafting","CraftedGoodStorageDialog_CurrentCapacity",{"quantity":Global.player.craftingState.totalCraftedGoods}));
         addWidget(this.m_currentCapacity);
         this.m_coinMeter = addWidget(new ZwWidget(m_window.coinMeter_mc)) as ZwWidget;
         this.m_coinMeterValue = addWidget(new ZwTextField(m_window.coinMeter_mc.coinValue_tf,Utilities.formatNumber(Global.player.gold))) as ZwTextField;
         var isInTutorial:Boolean = Boolean(CraftingUI.getCraftingMainWindow()) && CraftingManager.getInstance().inTutorialMode;
         this.m_avatarFrame = new ZwFrame(m_window.avatarMessage_mc);
         addWidget(this.m_avatarFrame,!isInTutorial);
         this.m_avatarFrame.addWidget(new ZwTextField(m_window.avatarMessage_mc.generic1_tf,ZLocUtils.t("Crafting","CraftingGetGoods_GoodPerDay")));
         this.m_avatarFrame.addWidget(new ZwTextField(m_window.avatarMessage_mc.generic2_tf,ZLocUtils.t("Crafting","CraftingGetGoods_UseGoods")));
         var items:Array = MarketViewManager.getInstance().getBestCraftedGoodInfoByUser();
         if(items.length > 0)
         {
            addWidget(new CraftingGetGoodsSlotFrame(m_window.goodsFrame_mc,items,this));
         }
         else
         {
            this.m_emptyFrame = addWidget(new ZwFrame(m_window.emptyFrame_mc)) as ZwFrame;
            this.m_emptyFrame.addWidget(new ZwTextField(m_window.emptyFrame_mc.generic_tf,ZLocUtils.t("Crafting","CraftingGetGoods_NoGoods")));
         }
         FarmStatsManager.count("cottage_ui_new","view_get_good_page");
         if(isInTutorial)
         {
            tintWindow();
            enableInput = false;
            CraftingUI.getCraftingMainWindow().displayTutorialMessage(CraftingMainWindow.TUTORIAL_AVAILABLE_GOODS);
         }
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_currentCapacity = null;
         this.m_avatarFrame = null;
         this.m_emptyFrame = null;
         this.m_coinMeter = null;
         this.m_coinMeterValue = null;
      }
      
      override public function centerPopup(pAbsolutePos:Point = null) : void
      {
         var bounds:Rectangle = this.getBounds(this);
         if(parent)
         {
            this.x = (Global.stage.stageWidth - bounds.width - bounds.x) / 2;
            this.y = (Global.stage.stageHeight - bounds.height - bounds.y) / 2;
         }
      }
      
      public function enterFrame() : void
      {
         var timeRemaining:Number = NaN;
         if(m_window)
         {
            timeRemaining = Global.player.craftingState.getTimeToNextRollOver();
            this.timeUntilRolloverSeconds = int(timeRemaining);
            if(this.timeUntilRolloverSeconds > 60)
            {
               this.timeUntilRolloverMinutes = int(timeRemaining) / 60;
               this.timeUntilRolloverSeconds = int(timeRemaining) % 60;
            }
            if(this.timeUntilRolloverMinutes > 60)
            {
               this.timeUntilRolloverHours = this.timeUntilRolloverMinutes / 60;
               this.timeUntilRolloverMinutes %= 60;
            }
            if(this.timeUntilRolloverHours > 24)
            {
               this.timeUntilRolloverDays = this.timeUntilRolloverHours / 24;
               this.timeUntilRolloverHours %= 24;
            }
            if(getWidget(m_window.goodsFrame_mc))
            {
               (getWidget(m_window.goodsFrame_mc) as CraftingGetGoodsSlotFrame).enterFrame();
            }
         }
      }
      
      public function refreshCapacity() : void
      {
         var totalCraftedGoods:int = Global.player.craftingState.totalCraftedGoods;
         var items:Array = MarketViewManager.getInstance().getBestCraftedGoodInfoByUser();
         if(this.m_currentCapacity)
         {
            this.m_currentCapacity.text = ZLocUtils.t("Crafting","CraftedGoodStorageDialog_CurrentCapacity",{"quantity":totalCraftedGoods});
         }
         if(Boolean(items) && items.length > 0)
         {
            if(m_window)
            {
               m_window.goodsFrame_mc.visible = true;
            }
            if(this.m_emptyFrame)
            {
               this.m_emptyFrame.visible = false;
            }
         }
         else
         {
            if(m_window)
            {
               m_window.goodsFrame_mc.visible = false;
            }
            if(this.m_emptyFrame)
            {
               this.m_emptyFrame.visible = true;
            }
         }
      }
   }
}

