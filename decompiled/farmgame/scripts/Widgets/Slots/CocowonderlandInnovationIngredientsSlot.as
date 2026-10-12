package Widgets.Slots
{
   import Classes.util.FarmGameUtil;
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.CocowonderlandInnovationMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class CocowonderlandInnovationIngredientsSlot extends ZwSlotFrame
   {
      
      private static const NAME_TF:String = "name_tf";
      
      private static const COUNT_TF:String = "count_tf";
      
      private static const HOVERSTATES_MC:String = "hover_ing_mc";
      
      private static const ADD_BT:String = "add_ing_bt";
      
      private static const GET_BT:String = "get_ing_bt";
      
      private static const ICON_MC:String = "icon_main_ing_mc";
      
      private static const BACKGROUND_MC:String = "ing_bg_mc";
      
      private static const MOUSEHOVER_MC:String = "hover_on_me_mc";
      
      private var m_name_tf:ZwTextField;
      
      private var m_count_tf:ZwTextField;
      
      private var m_hover_mc:MovieClip;
      
      private var m_hover_frame:ZwFrame;
      
      private var m_add_bt:FarmAnimatedTextButton;
      
      private var m_get_bt:FarmAnimatedTextButton;
      
      private var m_icon:FarmIcon;
      
      private var m_bg_mc:MovieClip;
      
      private var m_currentElement_mc:MovieClip;
      
      private var m_featureName:String;
      
      private var m_slotnumber:int = -1;
      
      private var m_ingredientQty:int = 0;
      
      private var m_ingredientItem:XML;
      
      private var m_ingredient:XML;
      
      private var m_coupons:int = 0;
      
      private var m_owner:CocowonderlandInnovationMainWindow;
      
      public function CocowonderlandInnovationIngredientsSlot(featureName:String, element:DisplayObject, window:CocowonderlandInnovationMainWindow)
      {
         this.m_featureName = featureName;
         this.m_owner = window;
         super(element);
         this.m_currentElement_mc = element as MovieClip;
         if(this.m_currentElement_mc)
         {
            addWidget(this.m_hover_frame = new ZwFrame(this.m_currentElement_mc),true);
            this.m_hover_frame.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.m_hover_frame.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
         if(m_element.hasOwnProperty(ADD_BT))
         {
            addWidget(this.m_add_bt = new FarmAnimatedTextButton(m_element[ADD_BT],"ADD",this.onAdd));
            this.m_add_bt.visible = false;
         }
         if(m_element.hasOwnProperty(GET_BT))
         {
            addWidget(this.m_get_bt = new FarmAnimatedTextButton(m_element[GET_BT],"GET",this.onGet));
            this.m_get_bt.visible = false;
            this.m_get_bt.enabled = true;
         }
         if(m_element.hasOwnProperty(HOVERSTATES_MC))
         {
            this.m_hover_mc = m_element[HOVERSTATES_MC] as MovieClip;
            if(this.m_hover_mc.hasOwnProperty(NAME_TF))
            {
               addWidget(this.m_name_tf = new ZwTextField(this.m_hover_mc[NAME_TF]));
               this.m_name_tf.visible = true;
            }
            if(this.m_hover_mc.hasOwnProperty(COUNT_TF))
            {
               addWidget(this.m_count_tf = new ZwTextField(this.m_hover_mc[COUNT_TF]));
               this.m_count_tf.visible = true;
            }
            if(this.m_hover_mc.hasOwnProperty(ICON_MC))
            {
               addWidget(this.m_icon = new FarmIcon(this.m_hover_mc[ICON_MC] as MovieClip));
               this.m_icon.visible = true;
            }
            if(this.m_hover_mc.hasOwnProperty(BACKGROUND_MC))
            {
               this.m_bg_mc = this.m_hover_mc[BACKGROUND_MC];
               this.m_bg_mc.visible = false;
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         if(data)
         {
            if(data.hasOwnProperty("questIngredientSlotNumber"))
            {
               this.m_slotnumber = data["questIngredientSlotNumber"];
            }
            if(data.hasOwnProperty("ingredient"))
            {
               this.m_ingredient = data["ingredient"] as XML;
               if(this.m_ingredient.hasOwnProperty("@name"))
               {
                  this.m_name_tf.text = this.m_ingredient["@name"];
                  this.m_name_tf.visible = true;
               }
               if(this.m_ingredient.hasOwnProperty("@iconurl"))
               {
                  this.m_icon.loadIcon(this.m_ingredient["@iconurl"]);
                  this.m_icon.setIconSize(70,70);
                  this.m_icon.visible = true;
               }
               if(this.m_ingredient.hasOwnProperty("@coupons"))
               {
                  this.m_coupons = parseInt(this.m_ingredient["@coupons"].toString());
                  if(this.m_coupons == 0)
                  {
                     this.m_get_bt.text = "Free";
                  }
                  else
                  {
                     this.m_get_bt.text = this.m_coupons.toString();
                  }
               }
               if(this.m_ingredient.hasOwnProperty("@qty"))
               {
                  this.m_ingredientQty = parseInt(this.m_ingredient["@qty"].toString());
                  this.m_count_tf.text = "x" + this.m_ingredient["@qty"];
                  this.m_count_tf.visible = true;
               }
               this.m_ingredientItem = this.m_ingredient;
               delete this.m_ingredientItem.@qty[0];
            }
            this.m_hover_mc.visible = true;
            this.m_hover_frame.visible = true;
            this.m_currentElement_mc.gotoAndStop(1);
         }
      }
      
      public function disableBuyButton() : void
      {
         this.m_get_bt.callback = null;
         this.m_get_bt.enabled = false;
         FarmGameUtil.disableButtonAndShowTooltip(this.m_get_bt,"You don\'t have enough coupons!");
      }
      
      public function disableAddButton() : void
      {
         this.m_add_bt.callback = null;
         this.m_add_bt.enabled = false;
         FarmGameUtil.disableButtonAndShowTooltip(this.m_add_bt,"Serve the coooked orders!");
      }
      
      private function onMouseOver(evt:MouseEvent) : void
      {
         this.m_add_bt.visible = true;
         this.m_get_bt.visible = true;
         this.m_bg_mc.visible = true;
         this.m_get_bt.enabled = this.manager.getOrderboardProgress() >= this.m_coupons;
         if(!this.m_get_bt.enabled)
         {
            this.m_get_bt.callback = null;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_get_bt,"You don\'t have enough coupons!");
         }
         else
         {
            this.m_get_bt.detachTooltip();
            this.m_get_bt.callback = this.onGet;
         }
         this.m_add_bt.enabled = this.m_ingredientQty > 0 && this.manager.areStationsFree();
         if(!this.m_add_bt.enabled)
         {
            this.m_add_bt.callback = null;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_add_bt,"");
         }
         else
         {
            this.m_add_bt.detachTooltip();
            this.m_add_bt.callback = this.onAdd;
         }
         this.m_currentElement_mc.gotoAndStop(2);
      }
      
      private function onMouseOut(evt:MouseEvent) : void
      {
         this.m_add_bt.visible = false;
         this.m_add_bt.detachTooltip();
         this.m_get_bt.visible = false;
         this.m_bg_mc.visible = false;
         this.m_currentElement_mc.gotoAndStop(1);
      }
      
      private function onGet(event:Event) : void
      {
         this.manager.buyIngredient(this.m_ingredientItem,this.m_slotnumber);
      }
      
      private function onAdd(event:Event) : void
      {
         if(this.manager.isStationAvailable())
         {
            if(this.manager.checkAndAddToStation(this.m_ingredientItem))
            {
               --this.m_ingredientQty;
               this.m_count_tf.text = "x" + this.m_ingredientQty.toString();
               if(this.m_ingredientQty == 0)
               {
                  this.m_add_bt.enabled = false;
               }
            }
         }
      }
      
      public function removeAllToolTips() : void
      {
         this.m_get_bt.detachTooltip();
         this.m_add_bt.detachTooltip();
      }
      
      public function getIngredient() : XML
      {
         return this.m_ingredient;
      }
      
      public function onBuyDone(result:Boolean) : void
      {
         if(result)
         {
            ++this.m_ingredientQty;
         }
         this.m_count_tf.text = "x" + this.m_ingredientQty.toString();
      }
      
      private function get manager() : CocowonderlandInnovationManager
      {
         return CocowonderlandInnovationManager.getInstance(this.m_featureName);
      }
   }
}

