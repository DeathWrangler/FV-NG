package com.troyer.widget.controller
{
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.events.MouseEvent;
   
   public class TooltipController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_DISPLAY_VIEW:String = "viewToDisplay";
      
      public static const ATTRIBUTE_OFFSET_X:String = "offsetX";
      
      public static const ATTRIBUTE_OFFSET_Y:String = "offsetY";
      
      private var m_tooltipDisplay:BaseWidgetController = null;
      
      private var m_offsetX:Number = 0;
      
      private var m_offsetY:Number = 0;
      
      public function TooltipController(param1:BaseWidgetView)
      {
         super(param1);
         this.addGlobalListener(WidgetControllerEvent.ADD_CHILD_VIEW);
         this.addGlobalListener(WidgetControllerEvent.REMOVE_CHILD_VIEW);
         this.addGlobalListener(WidgetControllerEvent.MOVE_CHILD_VIEW);
         this.addViewListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         this.addViewListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.addViewListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_DISPLAY_VIEW)
         {
            _loc2_ = this.m_tooltipDisplay;
         }
         else if(param1 == ATTRIBUTE_OFFSET_X)
         {
            _loc2_ = this.m_offsetX;
         }
         else if(param1 == ATTRIBUTE_OFFSET_Y)
         {
            _loc2_ = this.m_offsetY;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         if(param1 == ATTRIBUTE_DISPLAY_VIEW && param2 is BaseWidgetView)
         {
            this.m_tooltipDisplay = (param2 as BaseWidgetView).getController();
            this.m_tooltipDisplay.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
         }
         else if(param1 == ATTRIBUTE_OFFSET_X)
         {
            if(param2 is String)
            {
               this.m_offsetX = parseInt(param2);
            }
            else if(param2 is Number)
            {
               this.m_offsetX = param2;
            }
         }
         else if(param1 == ATTRIBUTE_OFFSET_Y)
         {
            if(param2 is String)
            {
               this.m_offsetY = parseInt(param2);
            }
            else if(param2 is Number)
            {
               this.m_offsetY = param2;
            }
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      protected function onMouseOver(param1:MouseEvent) : void
      {
         this.positionTooltip(param1.stageX,param1.stageY);
         dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.ADD_CHILD_VIEW,this.m_tooltipDisplay));
         MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.ADD_CHILD_VIEW,this.m_tooltipDisplay));
      }
      
      protected function onMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:BaseWidgetController = param1.target as BaseWidgetController;
         if(_loc2_ == null || _loc2_ != this.m_tooltipDisplay)
         {
            dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.REMOVE_CHILD_VIEW,this.m_tooltipDisplay));
            MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.ADD_CHILD_VIEW,this.m_tooltipDisplay));
         }
         else
         {
            this.onMouseMove(param1);
         }
      }
      
      protected function onMouseMove(param1:MouseEvent) : void
      {
         this.positionTooltip(param1.stageX,param1.stageY);
         dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.MOVE_CHILD_VIEW,this.m_tooltipDisplay));
         MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.MOVE_CHILD_VIEW,this.m_tooltipDisplay));
      }
      
      protected function positionTooltip(param1:int, param2:int) : void
      {
         var _loc3_:int = this.getView().stage.stageHeight;
         var _loc4_:int = this.getView().stage.stageWidth;
         var _loc5_:int = this.m_tooltipDisplay.getView().getAttribute(BaseWidgetView.ATTRIBUTE_WIDTH);
         var _loc6_:int = this.m_tooltipDisplay.getView().getAttribute(BaseWidgetView.ATTRIBUTE_HEIGHT);
         var _loc7_:int = _loc5_ + param1 + this.m_offsetX;
         var _loc8_:int = _loc6_ + param2 + this.m_offsetY;
         if(_loc8_ > _loc3_)
         {
            param2 = _loc3_ - _loc6_;
         }
         else if(_loc8_ < 0)
         {
            param2 = 0;
         }
         if(_loc7_ > _loc4_)
         {
            param1 = _loc4_ - _loc5_;
         }
         else if(_loc7_ < 0)
         {
            param1 = 0;
         }
         this.m_tooltipDisplay.getView().x = param1 + this.m_offsetX;
         this.m_tooltipDisplay.getView().y = param2 + this.m_offsetY;
      }
   }
}

