package Widgets.Windows.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingNPC;
   import Classes.FeatureCrafting.FeatureCraftingOrderBoard;
   import Classes.FeatureCrafting.FeatureCraftingRecipe;
   import Classes.FeatureCrafting.FeatureCraftingStation;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Display.UI;
   import Managers.TemplateUIUtility;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingOrderSlotContainerFrame;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingSingleRecipeSlotFrame;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   
   public class FeatureCraftingNPCWindow extends FarmWindow
   {
      
      private var m_npc:FeatureCraftingNPC;
      
      private var m_closeCallback:Function;
      
      private var m_previewFrame:ResourcePreviewFrame;
      
      private var m_orderSlots:FeatureCraftingOrderSlotContainerFrame;
      
      private var m_npcFiction:ZwTextField;
      
      private var m_singleRecipeSlot:FeatureCraftingSingleRecipeSlotFrame;
      
      private var m_hackyAutoScalingFlag:Boolean;
      
      private var m_location:String = this.m_npc.system.location;
      
      public function FeatureCraftingNPCWindow(npc:FeatureCraftingNPC, closeCallback:Function = null, hackyAutoScaling:Boolean = true)
      {
         this.m_npc = npc;
         this.m_closeCallback = closeCallback;
         this.m_npc.system.currentNPCWindow = this;
         this.m_hackyAutoScalingFlag = hackyAutoScaling;
         super(this.m_npc.system.getAssetUrl(FeatureCraftingSystem.ASSET_DIALOG_ORDERS));
      }
      
      public static function display(npc:FeatureCraftingNPC, closeCallback:Function = null) : FeatureCraftingNPCWindow
      {
         var window:FeatureCraftingNPCWindow = null;
         var orderBoard:FeatureCraftingOrderBoard = null;
         if(npc)
         {
            orderBoard = npc.getOrderBoard();
            if(Boolean(orderBoard) && !orderBoard.checkAllOrdersComplete())
            {
               window = new FeatureCraftingNPCWindow(npc,closeCallback,false);
               UI.displayPopup(window,false,"FeatureCraftingNPCWindow",true);
            }
         }
         return window;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,this.m_npc.friendlyTitle)) as ZwTextField;
         if(m_window.hasOwnProperty("body_tf"))
         {
            this.m_npcFiction = new ZwTextField(m_window.body_tf,this.m_npc.fictionString) as ZwTextField;
            addWidget(this.m_npcFiction);
            if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.title_tf);
               TemplateUIUtility.applyExpansionSubTextColor(m_window.body_tf);
            }
         }
         this.m_previewFrame = addWidget(new ResourcePreviewFrame(m_window.icon_mc)) as ResourcePreviewFrame;
         this.m_previewFrame.load(this.m_npc.assetUrl,this.m_npc.getFullExportName(FeatureCraftingNPC.ASSET_STATE_IDLE),this.repositionSlotPreviewFrame,this.m_npc.autoScaling,this.m_hackyAutoScalingFlag);
         this.m_orderSlots = addWidget(new FeatureCraftingOrderSlotContainerFrame(m_window.orders_mc,false)) as FeatureCraftingOrderSlotContainerFrame;
         if(m_window.recipe_mc)
         {
            this.m_singleRecipeSlot = addWidget(new FeatureCraftingSingleRecipeSlotFrame(m_window.recipe_mc)) as FeatureCraftingSingleRecipeSlotFrame;
            if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.recipe_mc.title_tf);
            }
            this.m_singleRecipeSlot.toggleSingleRecipeFrame(false);
         }
         this.refresh();
      }
      
      private function repositionSlotPreviewFrame() : void
      {
         var mc:MovieClip = null;
         if(Boolean(this.m_previewFrame) && !this.m_npc.autoScaling)
         {
            mc = this.m_previewFrame.exportedMovieClip;
            if(mc)
            {
               mc.y = -mc.height;
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_npc.system.currentNPCWindow = null;
         this.m_npcFiction = null;
         this.m_npc = null;
         this.m_closeCallback = null;
         this.m_previewFrame = null;
         this.m_orderSlots = null;
         this.m_singleRecipeSlot = null;
         super.release();
      }
      
      public function get npc() : FeatureCraftingNPC
      {
         return this.m_npc;
      }
      
      public function get hasSingleRecipeWindow() : Boolean
      {
         return this.m_singleRecipeSlot != null;
      }
      
      public function get singleRecipeWindow() : FeatureCraftingSingleRecipeSlotFrame
      {
         return this.m_singleRecipeSlot;
      }
      
      public function get isSingleRecipeWindowOpen() : Boolean
      {
         var result:Boolean = false;
         if(this.m_singleRecipeSlot)
         {
            result = this.m_singleRecipeSlot.isSingleRecipeFrameOpen();
         }
         return result;
      }
      
      public function updateSingleRecipeWindow(data:FeatureCraftingRecipe, station:FeatureCraftingStation) : void
      {
         var recipeArray:Array = null;
         if(this.hasSingleRecipeWindow)
         {
            if(data)
            {
               recipeArray = new Array(data);
               if(this.m_singleRecipeSlot)
               {
                  this.m_singleRecipeSlot.station = station;
                  this.m_singleRecipeSlot.toggleSingleRecipeFrame(true);
                  this.m_singleRecipeSlot.items = recipeArray;
                  this.m_singleRecipeSlot.refresh();
               }
            }
         }
      }
      
      public function refresh() : void
      {
         if(m_window)
         {
            this.refreshOrders();
         }
      }
      
      public function refreshOrders(getNewOrders:Boolean = true) : void
      {
         var orderBoard:FeatureCraftingOrderBoard = null;
         var orders:Array = null;
         if(this.m_orderSlots)
         {
            orderBoard = this.m_npc.getOrderBoard();
            if(orderBoard)
            {
               if(orderBoard.checkAllOrdersComplete())
               {
                  close();
               }
               else if(getNewOrders)
               {
                  orders = orderBoard.orders.concat();
                  orders.sortOn("isComplete");
                  this.m_orderSlots.items = orders;
               }
               else
               {
                  this.m_orderSlots.refresh();
               }
            }
         }
      }
   }
}

