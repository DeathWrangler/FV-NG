package com.troyer.widget.controller
{
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.utils.Dictionary;
   
   public class PageController extends PositionController
   {
      
      public static const ATTRIBUTE_SCROLL_VIEW:String = "scrollView";
      
      public static const ATTRIBUTE_SPEED:String = "speed";
      
      public static const ATTRIBUTE_DISTANCE:String = "distance";
      
      public static const ATTRIBUTE_BUTTON_LEFT:String = BUTTON + LEFT;
      
      public static const ATTRIBUTE_BUTTON_RIGHT:String = BUTTON + RIGHT;
      
      public static const ATTRIBUTE_BUTTON_UP:String = BUTTON + UP;
      
      public static const ATTRIBUTE_BUTTON_DOWN:String = BUTTON + DOWN;
      
      public static const BUTTON:String = "button";
      
      public static const LEFT:String = "Left";
      
      public static const RIGHT:String = "Right";
      
      public static const UP:String = "Up";
      
      public static const DOWN:String = "Down";
      
      private var m_scrollController:ScrollController;
      
      private var m_speed:Number = 500;
      
      private var m_distance:Number = 0;
      
      private var m_buttons:Dictionary;
      
      public function PageController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         var _loc3_:ButtonController = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1 == ATTRIBUTE_SCROLL_VIEW)
         {
            this.m_scrollController = getChildController(param2) as ScrollController;
            if(!this.m_scrollController)
            {
               addError("Attribute " + param1 + " in controller \'" + m_name + "\' doesn\'t reference a valid ScrollController");
            }
         }
         else if(param1 == ATTRIBUTE_SPEED)
         {
            this.m_speed = parseInt(param2);
         }
         else if(param1 == ATTRIBUTE_DISTANCE)
         {
            this.m_distance = parseInt(param2);
         }
         else if(param1 == ATTRIBUTE_BUTTON_LEFT || param1 == ATTRIBUTE_BUTTON_RIGHT || param1 == ATTRIBUTE_BUTTON_UP || param1 == ATTRIBUTE_BUTTON_DOWN)
         {
            _loc3_ = getChildController(param2) as ButtonController;
            _loc4_ = param1.substr(BUTTON.length);
            if(_loc3_)
            {
               _loc5_ = 0;
               _loc6_ = 0;
               switch(_loc4_)
               {
                  case LEFT:
                     _loc5_ = -1;
                     break;
                  case RIGHT:
                     _loc5_ = 1;
                     break;
                  case UP:
                     _loc6_ = -1;
                     break;
                  case DOWN:
                     _loc6_ = 1;
               }
               this.addDirectionButton(_loc3_,_loc5_,_loc6_);
            }
            else
            {
               addError("Attribute " + param1 + " in controller \'" + m_name + "\' doesn\'t reference a valid ButtonController");
            }
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      private function addDirectionButton(param1:ButtonController, param2:int, param3:int) : void
      {
         if(!this.m_buttons)
         {
            this.m_buttons = new Dictionary();
         }
         var _loc4_:Object = {
            "horiz":param2,
            "vert":param3
         };
         this.m_buttons[param1.getName()] = _loc4_;
         param1.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onButtonPressed);
      }
      
      private function onButtonPressed(param1:WidgetControllerEvent) : void
      {
         var _loc2_:BaseWidgetController = param1.getController();
         var _loc3_:Object = this.m_buttons[_loc2_.getName()];
         var _loc4_:Number = _loc3_.horiz * this.m_distance;
         var _loc5_:Number = _loc3_.vert * this.m_distance;
         var _loc6_:Number = _loc3_.horiz * this.m_speed;
         var _loc7_:Number = _loc3_.vert * this.m_speed;
         var _loc8_:Dictionary = new Dictionary();
         if(this.m_scrollController)
         {
            if(_loc4_ != 0)
            {
               _loc8_[ScrollController.SCROLL_DATA_DISTANCE] = _loc4_;
               _loc8_[ScrollController.SCROLL_DATA_SPEED] = _loc6_;
               this.m_scrollController.setAttribute(ScrollController.ATTRIBUTE_SCROLL_X,_loc8_);
            }
            if(_loc5_ != 0)
            {
               _loc8_[ScrollController.SCROLL_DATA_DISTANCE] = _loc5_;
               _loc8_[ScrollController.SCROLL_DATA_SPEED] = _loc7_;
               this.m_scrollController.setAttribute(ScrollController.ATTRIBUTE_SCROLL_Y,_loc8_);
            }
         }
         else
         {
            addError("PageController \'" + m_name + "\' Button pressed but no " + ATTRIBUTE_SCROLL_VIEW + " attribute set.");
         }
      }
   }
}

