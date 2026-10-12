package Widgets.Slots.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingInventoryPart;
   import Managers.Crafting.CraftingManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingExpansionSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingStorageWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingExpansionSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      protected var m_data:FeatureCraftingInventoryPart;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_countTextField:ZwTextField;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_craftButton:FarmAnimatedTextButton;
      
      private var m_completeWidget:ZwWidget;
      
      private var m_location:String = "";
      
      public function FeatureCraftingExpansionSlot(element:DisplayObject, location:String = "")
      {
         super(element);
         this.m_location = location;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.itemTitle_tf," ")) as ZwTextField;
         this.m_countTextField = addWidget(new ZwTextField(m_element.alive_tf," ")) as ZwTextField;
         if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
         {
            TemplateUIUtility.applyExpansionSubTextColor(m_element.alive_tf);
         }
         this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy2_bt,"Buy","00",this.onBuyButtonClick)) as FarmAnimatedCashButton;
         if(m_element.hasOwnProperty("craft_bt"))
         {
            this.m_craftButton = addWidget(new FarmAnimatedTextButton(m_element.craft_bt,"Craft",this.onCraftButtonClick)) as FarmAnimatedTextButton;
         }
         this.m_completeWidget = addWidget(new ZwWidget(m_element.completeIcon_mc)) as ZwWidget;
      }
      
      override public function release() : void
      {
         this.m_nameTextField = null;
         this.m_icon = null;
         this.m_countTextField = null;
         this.m_completeWidget = null;
         this.m_craftButton = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as FeatureCraftingInventoryPart;
         if(this.m_data)
         {
            this.m_icon.loadIcon(Global.getAssetURL(this.m_data.iconUrl));
            this.m_icon.visible = true;
            this.m_nameTextField.text = this.m_data.friendlyTitle;
            this.m_nameTextField.visible = true;
            this.m_buyButton.setAmountText(String(this.m_data.cost));
            this.refresh();
         }
      }
      
      public function refresh() : void
      {
         if(this.m_data)
         {
            this.m_countTextField.text = this.m_data.count + " of " + this.m_data.required;
            this.m_countTextField.visible = true;
            if(this.m_craftButton)
            {
               this.m_craftButton.visible = true;
            }
            if(this.hasEnough)
            {
               this.m_completeWidget.visible = true;
               this.m_buyButton.visible = false;
            }
            else
            {
               this.m_buyButton.visible = true;
               this.m_completeWidget.visible = false;
            }
         }
      }
      
      public function get hasEnough() : Boolean
      {
         return !this.m_data.canBuy();
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         if(this.m_buyButton.enabled)
         {
            if(this.m_data)
            {
               this.m_data.buy();
               this.refresh();
               (m_parent as FeatureCraftingExpansionSlotContainerFrame).refresh();
            }
         }
      }
      
      private function onCraftButtonClick(event:MouseEvent) : void
      {
         var craftShop:String = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
         if(craftShop)
         {
            CraftingManager.getInstance().openCraftingUiForRecipe(this.m_data.name,craftShop);
            if(this.m_data.system.currentContentsWindow)
            {
               this.m_data.system.currentContentsWindow.close();
               if(m_parent.parent is FeatureCraftingStorageWindow)
               {
                  (m_parent.parent as FeatureCraftingStorageWindow).close();
               }
            }
         }
      }
   }
}

