package Widgets.Frames.Crafting
{
   import Classes.Player;
   import Classes.util.DisplayObjectUtils;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class CraftingRecipeIngredientBaseFrame extends ZwFrame
   {
      
      public static const DEFAULT_BUSHEL_PRICE:String = "1";
      
      public static const BUY:String = "Buy";
      
      protected var m_icon:FarmIcon;
      
      protected var m_info:ZwTextField;
      
      protected var m_toolTip:FarmTextTooltip;
      
      public var m_getBushel:FarmAnimatedCashButton;
      
      public function CraftingRecipeIngredientBaseFrame(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(this.element.icon_mc,Player.NO_PROFILE_PIC_URL),false) as FarmIcon;
         this.m_info = addWidget(new ZwTextField(this.element.generic_tf,""),false) as ZwTextField;
         this.m_toolTip = new FarmTextTooltip();
         this.m_icon.attachTooltip(this.m_toolTip);
         if(this.element.hasOwnProperty("Buy_mc"))
         {
            this.m_getBushel = addWidget(new FarmAnimatedCashButton(this.element.Buy_mc,BUY,DEFAULT_BUSHEL_PRICE)) as FarmAnimatedCashButton;
         }
      }
      
      public function set applyGrayOut(onOff:Boolean) : void
      {
         var element:Sprite = m_element as Sprite;
         if(element)
         {
            DisplayObjectUtils.grayOut(element,onOff);
         }
      }
   }
}

