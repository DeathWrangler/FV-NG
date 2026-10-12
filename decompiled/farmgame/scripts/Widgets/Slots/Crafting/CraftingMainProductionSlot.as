package Widgets.Slots.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Events.ImpulseBuyEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Crafting.CraftingMainWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class CraftingMainProductionSlot extends ZwSlotFrame
   {
      
      private static const FRAMERATE_CONSTANT:int = 1000 / 30;
      
      private var m_recipeItem:RecipeItem = null;
      
      private var m_meterFrame:ZwFrame = null;
      
      private var m_emptyFrame:ZwFrame = null;
      
      private var m_emptyTooltip:FarmTextTooltip = null;
      
      private var m_lockedFrame:ZwFrame = null;
      
      private var m_lockedTooltip:FarmTextTooltip = null;
      
      private var m_finishedGoodTooltip:FarmTextTooltip = null;
      
      private var m_modalFrame:ZwFrame = null;
      
      private var m_craftingMainWindow:CraftingMainWindow = null;
      
      private var m_buyDialog:GenericIconPopup = null;
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      private var m_sheenCurrentFrame:Number = 0;
      
      private var m_sheenTotalFrames:int;
      
      public function CraftingMainProductionSlot(element:DisplayObject, craftingMainWindow:CraftingMainWindow)
      {
         this.m_craftingMainWindow = craftingMainWindow;
         super(element);
         this.m_emptyFrame = new ZwFrame(m_element.productionSlotEmpty_mc);
         this.m_emptyFrame.addWidget(new ZwTextField(m_element.productionSlotEmpty_mc.generic_tf,ZLocUtils.t("Crafting","CraftingMain_Empty")));
         addWidget(this.m_emptyFrame);
         this.m_emptyTooltip = new FarmTextTooltip(ZLocUtils.t("Crafting","CraftingMain_EmptyMessage",{"item":ZLocUtils.tk("Items",this.m_craftingMainWindow.cottage.craftType + "Slot_friendlyName")}));
         this.m_emptyFrame.attachTooltip(this.m_emptyTooltip);
         this.m_lockedFrame = new ZwFrame(m_element.productionSlotLocked_mc);
         this.m_lockedFrame.addWidget(new ZwTextField(m_element.productionSlotLocked_mc.generic_tf,ZLocUtils.t("Crafting","CraftingMain_Locked")));
         addWidget(this.m_lockedFrame);
         this.m_lockedTooltip = new FarmTextTooltip(ZLocUtils.t("Crafting","NoSlotsAvailable_message2",{"item":ZLocUtils.tk("Items",this.m_craftingMainWindow.cottage.craftType + "Slot_friendlyName","",3)}));
         this.m_lockedFrame.attachTooltip(this.m_lockedTooltip);
         this.m_modalFrame = addWidget(new ZwFrame(m_element.productionSlotModal_mc)) as ZwFrame;
         this.m_modalFrame.addWidget(new ZwTextField(m_element.productionSlotModal_mc.generic_tf));
         this.m_modalFrame.addWidget(new ZwTextField(m_element.productionSlotModal_mc.generic2_tf));
         this.m_modalFrame.addWidget(new FarmAnimatedTextButton(m_element.productionSlotModal_mc.finishNow_bt,ZLocUtils.t("Crafting","CraftingMain_FinishNow"),this.onFinishNow));
         var finishedGoodFrame:ZwFrame = addWidget(new ZwFrame(m_element.finishedGood_mc)) as ZwFrame;
         finishedGoodFrame.addWidget(new FarmAnimatedTextButton(m_element.finishedGood_mc.finishIt_bt,ZLocUtils.t("Crafting","CraftingMain_FinishIt"),this.onFinishIt));
         this.m_meterFrame = new ZwFrame(m_element.meterProduction_mc);
         addWidget(this.m_meterFrame);
         this.m_meterFrame.addWidget(new ZwTextField(m_element.meterProduction_mc.generic_tf));
         this.m_meterFrame.addWidget(new ZwWidget(m_element.meterProduction_mc.bar_mc));
         addWidget(new FarmIcon(m_element.recipeIcon_mc));
         (getWidget(m_element.recipeIcon_mc) as FarmIcon).setIconSize(50,50);
         addWidget(new FarmIcon(m_element.productionSlotIcon_mc,CraftingUI.getRecipeSlotIcon(this.m_craftingMainWindow.cottage.craftType)));
         (getWidget(m_element.productionSlotIcon_mc) as FarmIcon).setIconSize(35,35);
         (getWidget(m_element.productionSlotIcon_mc) as FarmIcon).x = (getWidget(m_element.productionSlotIcon_mc) as FarmIcon).x - 10;
         (getWidget(m_element.productionSlotIcon_mc) as FarmIcon).y = (getWidget(m_element.productionSlotIcon_mc) as FarmIcon).y - 10;
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Crafting","CraftingMain_SlotName",{
            "cottageSlotName":ZLocUtils.tk("Items",this.m_craftingMainWindow.cottage.craftType + "Slot_friendlyName"),
            "number":(int(name.slice(5,6)) + 1).toString()
         })));
         this.m_finishedGoodTooltip = new FarmTextTooltip();
         finishedGoodFrame.attachTooltip(this.m_finishedGoodTooltip);
         registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         if(m_element.finishedGood_mc.sheen_mc != null)
         {
            this.m_sheenTotalFrames = m_element.finishedGood_mc.sheen_mc.totalFrames;
         }
         else
         {
            this.m_sheenTotalFrames = 1;
         }
      }
      
      override public function populate(recipeItemIn:Object) : void
      {
         super.populate(recipeItemIn);
         this.m_recipeItem = recipeItemIn as RecipeItem;
         if(this.m_recipeItem)
         {
            (getWidget(m_element.productionSlotIcon_mc) as FarmIcon).visible = true;
            (this.m_modalFrame.getWidget(m_element.productionSlotModal_mc.generic_tf) as ZwTextField).text = ZLocUtils.tk_pk_asTitle(this.m_recipeItem.friendlyName);
            this.m_finishedGoodTooltip.setText(ZLocUtils.tk_pk_asTitle(this.m_recipeItem.friendlyName));
            if(this.m_recipeItem.id != "")
            {
               (getWidget(m_element.recipeIcon_mc) as FarmIcon).loadIcon(this.m_recipeItem.image);
               (getWidget(m_element.recipeIcon_mc) as FarmIcon).visible = true;
               this.updateMeter();
            }
            else
            {
               (getWidget(this.m_emptyFrame) as ZwFrame).visible = true;
               (this.m_emptyFrame.getWidget(m_element.productionSlotEmpty_mc.generic_tf) as ZwTextField).visible = true;
               (getWidget(m_element.generic_tf) as ZwTextField).visible = true;
            }
         }
         else
         {
            (getWidget(this.m_lockedFrame) as ZwFrame).visible = true;
            (this.m_lockedFrame.getWidget(m_element.productionSlotLocked_mc.generic_tf) as ZwTextField).visible = true;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_recipeItem = null;
         this.m_meterFrame = null;
         this.m_emptyFrame = null;
         this.m_lockedFrame = null;
         this.m_lockedTooltip = null;
         this.m_modalFrame = null;
         this.m_craftingMainWindow = null;
         this.m_buyDialog = null;
         this.m_impulseBuyDialog = null;
      }
      
      private function updateMeter() : void
      {
         var timeLeft:String = null;
         var timeLeft2:String = null;
         var finishedGoodFrame:ZwFrame = null;
         var timeRemaining:Number = this.m_recipeItem.timeRemaining;
         if(timeRemaining > 0)
         {
            if(timeRemaining > 3600)
            {
               timeLeft = ZLocUtils.t("Crafting","CraftingMain_ReadyInHours",{"hourNum":int(0.5 + timeRemaining / 3600)});
               timeLeft2 = ZLocUtils.t("Crafting","CraftingMain_ReadyInHoursMins",{
                  "hourNum":int(timeRemaining / 3600),
                  "minuteNum":int(timeRemaining / 60 % 60)
               });
            }
            else if(timeRemaining > 60)
            {
               timeLeft = ZLocUtils.t("Crafting","CraftingMain_ReadyInMins",{"minuteNum":int(timeRemaining / 60)});
               timeLeft2 = ZLocUtils.t("Crafting","CraftingMain_ReadyInMinsSecs",{
                  "minuteNum":int(timeRemaining / 60),
                  "secondNum":timeRemaining % 60
               });
            }
            else
            {
               timeLeft = timeLeft2 = ZLocUtils.t("Crafting","CraftingMain_ReadyInSecs",{"secondNum":int(timeRemaining)});
            }
            m_element.meterProduction_mc.generic_tf.text = timeLeft;
            m_element.meterProduction_mc.bar_mc.width = (1 - timeRemaining / this.m_recipeItem.secondsToCook) / m_element.meterProduction_mc.scaleX * m_element.meterProduction_mc.width;
            if(!this.m_meterFrame.visible)
            {
               this.m_meterFrame.visible = true;
            }
            (this.m_modalFrame.getWidget(m_element.productionSlotModal_mc.generic2_tf) as ZwTextField).text = timeLeft2;
         }
         else
         {
            finishedGoodFrame = getWidget(m_element.finishedGood_mc) as ZwFrame;
            if(!finishedGoodFrame.visible)
            {
               finishedGoodFrame.visible = true;
               (finishedGoodFrame.getWidget(m_element.finishedGood_mc.finishIt_bt) as FarmAnimatedTextButton).visible = true;
            }
            if(this.m_meterFrame.visible)
            {
               this.m_meterFrame.visible = false;
            }
         }
      }
      
      public function enterFrame(deltaTime:Number) : void
      {
         if(Boolean(this.m_recipeItem) && this.m_recipeItem.id != "")
         {
            this.updateMeter();
            if(m_element.finishedGood_mc.visible)
            {
               this.m_sheenCurrentFrame = (this.m_sheenCurrentFrame + deltaTime) % this.m_sheenTotalFrames;
               m_element.finishedGood_mc.sheen_mc.gotoAndStop(int(this.m_sheenCurrentFrame));
            }
         }
      }
      
      private function onMouseOver(evt:MouseEvent) : void
      {
         if(Boolean(this.m_recipeItem && this.m_recipeItem.id != "") && Boolean(this.m_recipeItem.timeRemaining != 0) && !this.m_modalFrame.visible)
         {
            this.m_modalFrame.visible = true;
         }
      }
      
      private function onMouseOut(evt:MouseEvent) : void
      {
         if(this.m_modalFrame.visible)
         {
            this.m_modalFrame.visible = false;
         }
      }
      
      private function onFinishIt(evt:MouseEvent) : void
      {
         this.finishRecipe();
         this.m_craftingMainWindow.closeTutorialWindow();
      }
      
      private function onFinishNow(evt:MouseEvent) : void
      {
         var popUpMessage:String = null;
         FarmStatsManager.count("crafting_cottage","insta_finish","click_button");
         this.m_craftingMainWindow.tintWindow();
         this.m_craftingMainWindow.enableInput = false;
         if(Global.player.cash >= this.m_recipeItem.rushCostCash)
         {
            popUpMessage = ZLocUtils.t("Crafting","Progress_FinishInstantlyMessage",{"quantity":this.m_recipeItem.rushCostCash});
            this.m_buyDialog = new GenericIconPopup(popUpMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyClose,Global.getAssetURL(this.m_recipeItem.image));
            UI.displayPopupWithOffset(this.m_buyDialog,new Point(CraftingManager.CRAFTING_COTTAGE_POPUP_OFFSET_X,CraftingManager.CRAFTING_COTTAGE_POPUP_OFFSET_Y),false);
         }
         else
         {
            FarmStatsManager.count("crafting_cottage","insta_finish","not_enough_cash");
            this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_recipeItem.rushCostCash,this.m_recipeItem.name);
            if(this.m_impulseBuyDialog != null)
            {
               this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            }
            else
            {
               this.onImpulseBuyCancel(null);
            }
         }
      }
      
      private function onBuyClose(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT)
         {
            CraftingManager.getInstance().beginBuyRecipeRush(this.m_recipeItem,false,this.onEndRecipeRush);
         }
         else
         {
            this.m_craftingMainWindow.untintWindow();
            this.m_craftingMainWindow.enableInput = true;
         }
      }
      
      private function onEndRecipeRush(result:Object) : void
      {
         this.finishRecipe();
      }
      
      private function onImpulseBuyCancel(event:ImpulseBuyEvent) : void
      {
         this.m_craftingMainWindow.untintWindow();
         this.m_craftingMainWindow.enableInput = true;
         if(this.m_impulseBuyDialog)
         {
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
      }
      
      private function finishRecipe() : void
      {
         this.m_craftingMainWindow.enableInput = false;
         CraftingManager.getInstance().beginClaimFinishedRecipes(this.onEndClaimFinishedRecipes,this.m_recipeItem.id,this.onEndClaimFinishedFeed,this.m_recipeItem.ovenSlot);
      }
      
      private function onEndClaimFinishedRecipes(result:Object) : void
      {
         this.m_craftingMainWindow.untintWindow();
         this.m_craftingMainWindow.enableInput = true;
         this.m_craftingMainWindow.updateUpgradeFrame();
         this.m_craftingMainWindow.updateRecipeSlotFrame();
         this.m_craftingMainWindow.updateProductionSlotFrame();
      }
      
      private function onEndClaimFinishedFeed() : void
      {
         if(Boolean(this.m_craftingMainWindow) && this.m_craftingMainWindow.isInTutorial())
         {
            this.m_craftingMainWindow.displayTutorialMessage(CraftingMainWindow.TUTORIAL_GET_BUSHELS);
         }
      }
   }
}

