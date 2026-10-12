package Widgets.Slots
{
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CocowonderlandInnovationStationIngredientsFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.CocowonderlandInnovationMainWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class CocowonderlandInnovationStationIngredientSlot extends ZwSlotFrame
   {
      
      private static const INGREDIENT_MC:String = "order_ing_mc";
      
      private static const INGREDIENT_NAME_TF:String = "station_ing_tf";
      
      private static const REMOVE_BT:String = "remove_ing_mc";
      
      private var m_window:CocowonderlandInnovationMainWindow;
      
      private var m_frame:CocowonderlandInnovationStationIngredientsFrame;
      
      private const FEATURE_NAME:String = "CocowonderlandInnovation";
      
      private var m_ingredientIcon:FarmIcon;
      
      private var m_ingredientName_tf:ZwTextField;
      
      private var m_remove_bt:FarmButton;
      
      private var m_ingredient:XML;
      
      private var m_slotNumber:Number;
      
      public function CocowonderlandInnovationStationIngredientSlot(element:DisplayObject, window:CocowonderlandInnovationMainWindow, frame:CocowonderlandInnovationStationIngredientsFrame)
      {
         super(element);
         this.m_window = window;
         this.m_frame = frame;
         this.visible = true;
         if(m_element.hasOwnProperty(INGREDIENT_MC))
         {
            addWidget(this.m_ingredientIcon = new FarmIcon(m_element[INGREDIENT_MC]));
            this.m_ingredientIcon.visible = true;
         }
         if(m_element.hasOwnProperty(INGREDIENT_NAME_TF))
         {
            addWidget(this.m_ingredientName_tf = new ZwTextField(m_element[INGREDIENT_NAME_TF],""));
            this.m_ingredientName_tf.visible = true;
         }
         if(m_element.hasOwnProperty(REMOVE_BT))
         {
            addWidget(this.m_remove_bt = new FarmAnimatedButton(m_element[REMOVE_BT]));
            this.m_remove_bt.visible = false;
         }
      }
      
      public function onMouseOver() : Function
      {
         return function(evt:MouseEvent):void
         {
         };
      }
      
      public function onMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
         };
      }
      
      override public function populate(data:Object) : void
      {
         if(data)
         {
            if(data.hasOwnProperty("questIngredientSlotNumber"))
            {
               this.m_slotNumber = data["questIngredientSlotNumber"];
            }
            if(data.hasOwnProperty("ingredient"))
            {
               this.m_ingredient = data["ingredient"];
               if(this.m_ingredient.hasOwnProperty("@name"))
               {
                  this.m_ingredientName_tf.text = this.m_ingredient["@name"];
                  this.m_ingredientName_tf.visible = true;
               }
               if(this.m_ingredient.hasOwnProperty("@iconurl"))
               {
                  this.m_ingredientIcon.loadIcon(this.m_ingredient["@iconurl"]);
                  this.m_ingredientIcon.setIconSize(25,25);
                  this.m_ingredientIcon.visible = true;
               }
               this.m_remove_bt.visible = !this.m_frame.isCookingStarted();
               this.m_remove_bt.enabled = true;
               this.m_remove_bt.callback = this.onRemove;
            }
            else
            {
               this.m_ingredientName_tf.text = "";
               this.m_ingredientName_tf.visible = false;
               this.m_ingredientIcon.visible = false;
               this.m_remove_bt.visible = false;
            }
         }
      }
      
      private function onRemove(event:Event) : void
      {
         if(!this.m_frame.isCookingStarted())
         {
            this.m_remove_bt.visible = false;
            this.m_frame.removeIngredient(this.m_ingredient);
         }
      }
      
      public function onStartCooking() : void
      {
         this.m_remove_bt.visible = false;
      }
      
      private function get manager() : CocowonderlandInnovationManager
      {
         return CocowonderlandInnovationManager.getInstance(this.FEATURE_NAME);
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

