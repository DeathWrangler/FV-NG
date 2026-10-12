package Widgets.Frames.UGC
{
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemDefinition;
   import Classes.UGC.UGCItemHudConfig;
   import Classes.UGC.UGCItemState;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Transactions.TCreateUGCDecoration;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.UGC.UGCItemHudPartSlot;
   import Widgets.Slots.UGC.UGCItemPartSlot;
   import Widgets.Windows.UGCDecoWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class UGCDecorationHUDFrame extends ZwFrame
   {
      
      private var m_ugcItem:IUGCItem;
      
      private var m_ugcItemDef:UGCItemDefinition;
      
      private var m_hudConfig:UGCItemHudConfig;
      
      private var m_editor:UGCItemEditorFrame;
      
      private var m_partSlots:Array;
      
      private var m_hudSlots:Vector.<UGCItemHudPartSlot>;
      
      private var m_recycleButton:FarmAnimatedTextButton = null;
      
      private var m_recycleText:ZwTextField = null;
      
      private var m_buyBtn:ZwWidget;
      
      private var m_ugcWindow:UGCDecoWindow;
      
      public function UGCDecorationHUDFrame(element:DisplayObject, ugcItem:IUGCItem, editor:UGCItemEditorFrame, ugcWindow:UGCDecoWindow, recycleStartCallback:Function)
      {
         var item:FarmItem = null;
         var partSlot:UGCItemPartSlot = null;
         var hudSlot:UGCItemHudPartSlot = null;
         super(element);
         this.m_ugcWindow = ugcWindow;
         this.m_ugcItem = ugcItem;
         this.m_ugcItemDef = Global.farmGameSettingsManager.getUGCItemDefinition(ugcItem.ugcItemName);
         this.m_hudConfig = this.m_ugcItemDef.hudConfig;
         this.m_editor = editor;
         this.m_editor.addEventListener(UGCConstants.EVENT_STATE_CHANGE,this.refresh);
         if(!this.m_hudConfig)
         {
            throw new Error("Invalid UGCItemHudConfig, no hud found.");
         }
         this.m_partSlots = new Array();
         this.m_hudSlots = new Vector.<UGCItemHudPartSlot>();
         for(var i:int = 0; i < this.m_hudConfig.hudItems.length; i++)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_hudConfig.hudItems[i]);
            if(ObjectUtil.pathExists(m_element,"giftPanel" + i))
            {
               partSlot = new UGCItemPartSlot(m_element["giftPanel" + i],item,ugcWindow.gameSettingsFeatureName);
               partSlot.addEventListener(UGCConstants.EVENT_MATERIAL_PURCHASED,this.refresh);
               partSlot.addEventListener(UGCConstants.EVENT_ASK_FOR_MATERIALS,this.onAskForMaterials);
               addWidget(partSlot);
               this.m_partSlots.push(partSlot);
            }
            if(ObjectUtil.pathExists(this.m_ugcWindow.window,"part" + i + "_mc"))
            {
               hudSlot = new UGCItemHudPartSlot(this.m_ugcWindow.window["part" + i + "_mc"],item);
               addWidget(hudSlot);
               this.m_hudSlots.push(hudSlot);
            }
         }
         this.createRecycleButton(recycleStartCallback);
         if(ObjectUtil.pathExists(m_element,"buy_bt"))
         {
            this.m_buyBtn = new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs","Build"),this.handleBuyClicked);
            addWidget(this.m_buyBtn);
         }
         this.refresh(null);
      }
      
      public function createRecycleButton(recycleStartCallback:Function) : void
      {
         if(this.m_recycleButton == null && this.m_ugcItemDef.showRecycleButton)
         {
            if(ObjectUtil.pathExists(m_element,"parts_bt"))
            {
               this.m_recycleButton = new FarmAnimatedTextButton(m_element.parts_bt,ZLocUtils.t("Dialogs","UGCDecoWindow_recycle_getMaterialsBtn"),recycleStartCallback);
               addWidget(this.m_recycleButton);
            }
            if(ObjectUtil.pathExists(m_element,"header_tf"))
            {
               this.m_recycleText = new ZwTextField(m_element["header_tf"],ZLocUtils.t("Dialogs","UGCDecoWindow_recycle_moreInfo"));
               addWidget(this.m_recycleText);
            }
         }
      }
      
      public function toggleVisibility(toggle:Boolean) : void
      {
         var hudItem:UGCItemHudPartSlot = null;
         for each(hudItem in this.m_hudSlots)
         {
            hudItem.visible = toggle;
         }
      }
      
      private function onAskForMaterials(e:Event) : void
      {
         this.m_editor.disablePaintMode();
      }
      
      override public function release() : void
      {
         var item:UGCItemPartSlot = null;
         for each(item in this.m_partSlots)
         {
            item.removeEventListener(UGCConstants.EVENT_MATERIAL_PURCHASED,this.refresh);
            item.removeEventListener(UGCConstants.EVENT_ASK_FOR_MATERIALS,this.onAskForMaterials);
         }
         this.m_editor.removeEventListener(UGCConstants.EVENT_STATE_CHANGE,this.refresh);
         super.release();
      }
      
      private function handleBuyClicked(e:Event) : void
      {
         var state:UGCItemState = this.m_editor.ugcItemState;
         if(state.isValid())
         {
            Utilities.toggleInputAndChildren(this.m_ugcWindow,false);
            getWidget("buy_bt").enabled = false;
            TransactionManager.addTransaction(new TCreateUGCDecoration(state,this.m_editor.getCustomizeItem(),this.onCreateTxComplete),true);
            if(ObjectUtil.pathExists(m_element,"creating_mc"))
            {
               m_element.creating_mc.visible = true;
               m_element.creating_mc.play();
            }
         }
      }
      
      private function onCreateTxComplete(ugcItemState:UGCItemState, existingItem:IUGCMapResource) : void
      {
         var extraData:Object = null;
         if(ugcItemState != null)
         {
            if(!existingItem)
            {
               extraData = {
                  "ugcUuid":ugcItemState.uuid,
                  "repopGift":false
               };
               Global.world.enterForcePlaceMode(this.m_ugcItem.farmItem.name,false,0,false,true,extraData,false);
            }
            else
            {
               existingItem.ugcDelegate.ugcItemState = ugcItemState;
            }
         }
         if(this.m_ugcWindow)
         {
            this.m_ugcWindow.close();
         }
      }
      
      public function refresh(e:Event) : void
      {
         var item:UGCItemPartSlot = null;
         var hudItem:UGCItemHudPartSlot = null;
         var canBuy:Boolean = true;
         var cost:Object = this.m_editor.getTotalPriceInParts();
         for each(item in this.m_partSlots)
         {
            item.setCost(cost);
            canBuy &&= item.canBuy();
         }
         for each(hudItem in this.m_hudSlots)
         {
            hudItem.setCost(cost);
         }
         this.m_buyBtn.enabled = canBuy;
         this.m_editor.disablePaintMode();
      }
   }
}

