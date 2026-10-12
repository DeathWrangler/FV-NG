package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.events.MouseEvent;
   
   public class DragonBreedingCraftWindow extends FarmWindow
   {
      
      private var m_featureName:String = null;
      
      private var m_craftBtn:FarmAnimatedTextButton;
      
      private var m_buyBtn:FarmAnimatedTextButton;
      
      private var m_askBtn:FarmAnimatedTextButton;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_craftItem:String = "herbsoflove";
      
      private var m_shouldOpenMainUI:Boolean = true;
      
      public function DragonBreedingCraftWindow(dialogPath:String, featureName:String, craftItem:String)
      {
         this.m_featureName = featureName;
         this.m_craftItem = craftItem;
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("craft_bt"))
         {
            addWidget(this.m_craftBtn = new FarmAnimatedTextButton(m_window.craft_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_selected_" + DragonBreedingManager.HERB_ITEM_NAME + "_CraftButtonText"),this.onCraftClick),true);
         }
         if(m_window.hasOwnProperty("gift_bt"))
         {
            addWidget(this.m_buyBtn = new FarmAnimatedTextButton(m_window.gift_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_selected_" + DragonBreedingManager.HERB_ITEM_NAME + "_BuyButtonText"),this.onBuyClick),true);
         }
         if(m_window.hasOwnProperty("ask_bt"))
         {
            addWidget(this.m_askBtn = new FarmAnimatedTextButton(m_window.ask_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_selected_" + DragonBreedingManager.HERB_ITEM_NAME + "_AskButtonText"),this.onAskClick),true);
            this.checkAskButtonEnabled();
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_selected_" + this.m_craftItem + "_CraftWindow_title")),true);
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_selected_" + this.m_craftItem + "_CraftWindow_body")),true);
         }
      }
      
      private function onCraftClick(event:MouseEvent) : void
      {
         this.m_shouldOpenMainUI = false;
         if(DragonBreedingManager.getInstance(this.m_featureName).showCraftingWindowWithItem(this.m_craftItem))
         {
            this.close();
         }
      }
      
      private function onBuyClick(event:MouseEvent) : void
      {
         this.m_shouldOpenMainUI = false;
         var m_sunshineBuyWindow:DragonBreedingBuyCraftWindow = new DragonBreedingBuyCraftWindow(DragonBreedingManager.getInstance(this.m_featureName).getCraftBuyDialogURL(),this.m_featureName,this.m_craftItem);
         UI.displayPopup(m_sunshineBuyWindow,false,"",true);
         this.close();
      }
      
      public function checkAskButtonEnabled() : void
      {
         var timeRemaining:Array = null;
         var enabled:Boolean = false;
         var itemCode:String = "";
         if(this.m_craftItem == DragonBreedingManager.FIRE_ITEM_NAME)
         {
            enabled = DragonBreedingManager.getInstance(this.m_featureName).canAskForFire();
            itemCode = DragonBreedingManager.FIRE_ITEM_CODE;
         }
         else
         {
            enabled = DragonBreedingManager.getInstance(this.m_featureName).canAskForLovePotions();
            itemCode = DragonBreedingManager.LOVE_POTION_ITEM_CODE;
         }
         if(itemCode != "")
         {
            if(enabled)
            {
               this.m_askBtn.enabled = true;
            }
            else
            {
               this.m_askBtn.enabled = false;
               this.m_askBtn.element.mouseEnabled = this.m_askBtn.element.mouseChildren = true;
               timeRemaining = DragonBreedingManager.getInstance(this.m_featureName).getTimeUntilPostFeedEnabled(itemCode);
               this.m_askBtn.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                  "hrs":timeRemaining[1],
                  "min":timeRemaining[2]
               })));
            }
         }
      }
      
      private function onAskClick(event:MouseEvent) : void
      {
         if(this.m_askBtn.enabled)
         {
            if(this.m_craftItem == DragonBreedingManager.FIRE_ITEM_NAME)
            {
               DragonBreedingManager.getInstance(this.m_featureName).askForFire();
            }
            else
            {
               DragonBreedingManager.getInstance(this.m_featureName).askForLovePotions();
            }
         }
         this.close();
      }
      
      override protected function release() : void
      {
         this.m_titleTf = null;
         this.m_bodyTf = null;
         super.release();
      }
      
      override public function close() : void
      {
         if(this.m_shouldOpenMainUI)
         {
         }
         super.close();
      }
   }
}

