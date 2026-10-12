package Widgets.Slots.CraftingBasket
{
   import Classes.CraftingBasket;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class CraftingBasketCraftSlot extends ZwFrame
   {
      
      private var m_basketName:String;
      
      private var m_data:Object;
      
      private var m_callbacks:Object;
      
      private var m_countTextField:ZwTextField;
      
      private var m_makeButton:FarmAnimatedTextButton;
      
      public function CraftingBasketCraftSlot(element:DisplayObject, basketName:String, data:Object, callbacks:Object)
      {
         super(element);
         this.m_data = data;
         this.m_basketName = basketName;
         this.m_callbacks = callbacks;
         var recipe:RecipeItem = Global.craftConfigSettings.getRecipeById(this.m_data.id);
         if(m_element.count_tf)
         {
            addWidget(this.m_countTextField = new ZwTextField(m_element.count_tf,"x" + recipe.onFinishQuantity.toString()));
         }
         if(m_element.glowbg_mc)
         {
            m_element.glowbg_mc.visible = true;
         }
         addWidget(this.m_makeButton = new FarmAnimatedTextButton(m_element.make_bt,ZLocUtils.t("Dialogs",this.m_basketName + "_makeCurrency"),this.onMakeCurrency));
         var infoTooltip:FarmTextTooltip = new FarmTextTooltip(ZLocUtils.t("Items","Generic_craftRecipeTooltip",{"recipe":recipe.friendlyTitle}));
         this.m_makeButton.attachTooltip(infoTooltip);
      }
      
      override public function release() : void
      {
         this.m_countTextField = null;
         this.m_makeButton = null;
         super.release();
      }
      
      private function onMakeCurrency(event:Event) : void
      {
         var callback:Function = this.m_callbacks[CraftingBasket.CRAFT_CURRENCY];
         callback(this.m_data.id);
      }
   }
}

