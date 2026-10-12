package Widgets.Slots
{
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.CocowonderlandInnovationMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class CocowonderlandInnovationCustomerOrderSlot extends ZwSlotFrame
   {
      
      private static const NAME_TF:String = "name_tf";
      
      private static const ORDERICON_MC:String = "icon_order_mc";
      
      private static const INGREDIENTS_MC:String = "all_order_ing_mc";
      
      private static const INGREDIENT_MC:String = "order_ing";
      
      private static const DIMES_COUNT_TF:String = "coin_count_tf";
      
      private static const HOVER_ORDER_MC:String = "hover_order_mc";
      
      private static const MOVIECLIPSUFFIX:String = "_mc";
      
      private static const ANIMATION_MC:String = "animation_mc";
      
      private var m_featureName:String;
      
      private var m_owner:CocowonderlandInnovationMainWindow;
      
      private var m_name_tf:ZwTextField;
      
      private var m_dimes_tf:ZwTextField;
      
      private var m_orderIcon:FarmIcon;
      
      private var m_ingredients_mc:MovieClip;
      
      private var m_hover_order_frame:ZwFrame;
      
      private var m_ingredientIconsMC:Array;
      
      private var m_ingredientCirclesMC:Array;
      
      private var m_animation_mc:MovieClip;
      
      private var m_slotnumber:int = -1;
      
      private var m_toolTipText:String = "";
      
      public function CocowonderlandInnovationCustomerOrderSlot(featureName:String, element:DisplayObject, window:CocowonderlandInnovationMainWindow)
      {
         var counter:int = 0;
         var counter2:int = 0;
         this.m_ingredientIconsMC = [];
         this.m_ingredientCirclesMC = [];
         this.m_featureName = featureName;
         this.m_owner = window;
         super(element);
         if(m_element.hasOwnProperty(NAME_TF))
         {
            addWidget(this.m_name_tf = new ZwTextField(m_element[NAME_TF],""));
            this.m_name_tf.visible = true;
         }
         if(m_element.hasOwnProperty(ORDERICON_MC))
         {
            addWidget(this.m_orderIcon = new FarmIcon(m_element[ORDERICON_MC]));
            this.m_orderIcon.visible = true;
         }
         if(m_element.hasOwnProperty(DIMES_COUNT_TF))
         {
            addWidget(this.m_dimes_tf = new ZwTextField(m_element[DIMES_COUNT_TF]));
            this.m_dimes_tf.visible = false;
         }
         if(m_element.hasOwnProperty(HOVER_ORDER_MC))
         {
            addWidget(this.m_hover_order_frame = new ZwFrame(m_element[HOVER_ORDER_MC] as MovieClip));
            this.m_hover_order_frame.visible = true;
         }
         if(m_element.hasOwnProperty(ANIMATION_MC))
         {
            this.m_animation_mc = m_element[ANIMATION_MC] as MovieClip;
            this.m_animation_mc.visible = false;
         }
         if(m_element.hasOwnProperty(INGREDIENTS_MC))
         {
            this.m_ingredients_mc = m_element[INGREDIENTS_MC] as MovieClip;
            this.m_ingredients_mc.visible = true;
            counter = 0;
            while(this.m_ingredients_mc.hasOwnProperty(INGREDIENT_MC + counter.toString() + MOVIECLIPSUFFIX))
            {
               addWidget(this.m_ingredientIconsMC[counter] = new FarmIcon(this.m_ingredients_mc[INGREDIENT_MC + counter.toString() + MOVIECLIPSUFFIX]));
               this.m_ingredientIconsMC[counter].visible = false;
               counter++;
            }
            counter2 = 0;
            while(this.m_ingredients_mc.hasOwnProperty("order_circle" + counter2.toString() + MOVIECLIPSUFFIX))
            {
               this.m_ingredientCirclesMC[counter2] = this.m_ingredients_mc["order_circle" + counter2.toString() + MOVIECLIPSUFFIX] as MovieClip;
               this.m_ingredientCirclesMC[counter2].visible = false;
               counter2++;
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         var index:int = 0;
         var order:XML = null;
         var ingredient:XML = null;
         this.m_toolTipText = "";
         super.populate(data);
         if(data)
         {
            for(index = 0; index < 4; index++)
            {
               (this.m_ingredientCirclesMC[index] as MovieClip).visible = false;
            }
            if(data.hasOwnProperty("questOrderSlotNumber"))
            {
               this.m_slotnumber = data.questOrderSlotNumber;
            }
            if(data.hasOwnProperty("orderXML"))
            {
               order = data["orderXML"];
               if(order.hasOwnProperty("@name"))
               {
                  this.m_name_tf.text = order["@name"];
                  this.m_name_tf.visible = true;
               }
               if(order.hasOwnProperty("@dimes"))
               {
                  this.m_dimes_tf.text = order["@dimes"];
                  this.m_dimes_tf.visible = true;
               }
               if(order.hasOwnProperty("@iconurl"))
               {
                  this.m_orderIcon.loadIcon(order["@iconurl"]);
                  this.m_orderIcon.setIconSize(65,65);
                  this.m_orderIcon.visible = true;
               }
               if(order.hasOwnProperty("ingredients"))
               {
                  index = 0;
                  for each(ingredient in order["ingredients"]["ingredient"])
                  {
                     this.m_toolTipText = this.m_toolTipText + "x1 " + ingredient["@name"] + "\n";
                     (this.m_ingredientCirclesMC[index] as MovieClip).visible = true;
                     (this.m_ingredientIconsMC[index] as FarmIcon).loadIcon(ingredient["@iconurl"]);
                     (this.m_ingredientIconsMC[index] as FarmIcon).setIconSize(25,25);
                     (this.m_ingredientIconsMC[index] as FarmIcon).visible = true;
                     index++;
                  }
               }
               if(this.m_hover_order_frame)
               {
                  this.m_hover_order_frame.visible = true;
                  this.m_hover_order_frame.detachTooltip();
                  this.m_hover_order_frame.attachTooltip(new FarmTextTooltip(this.m_toolTipText));
               }
            }
         }
      }
      
      private function get manager() : CocowonderlandInnovationManager
      {
         return CocowonderlandInnovationManager.getInstance(this.m_featureName);
      }
      
      public function playAnimation(cookedOrder:String) : Boolean
      {
         if(this.m_name_tf.text == cookedOrder)
         {
            this.m_animation_mc.visible = true;
            this.m_animation_mc.play();
            return true;
         }
         return false;
      }
      
      public function stopAnimation() : void
      {
         this.m_animation_mc.stop();
         this.m_hover_order_frame.visible = false;
         this.m_hover_order_frame.detachTooltip();
         this.m_animation_mc.visible = false;
      }
   }
}

