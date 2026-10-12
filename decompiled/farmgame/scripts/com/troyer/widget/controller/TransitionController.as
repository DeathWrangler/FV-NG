package com.troyer.widget.controller
{
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   
   public class TransitionController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_EVENT:String = "event";
      
      public static const ATTRIBUTE_TRIGGERS:String = "triggers";
      
      public static const ATTRIBUTE_TARGETS:String = "targets";
      
      public static const EVENT_PRESSED:String = "pressed";
      
      private var m_eventType:String = "pressed";
      
      private var m_triggers:Array;
      
      private var m_targets:Array;
      
      public function TransitionController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_EVENT,ATTRIBUTE_TARGETS,ATTRIBUTE_TRIGGERS);
         return _loc1_;
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         if(param1 == ATTRIBUTE_EVENT && param2 is String)
         {
            this.m_eventType = param2;
         }
         else if(param1 == ATTRIBUTE_TRIGGERS && param2 is String)
         {
            this.m_triggers = String(param2).split(",");
            this.updateTransition();
         }
         else if(param1 == ATTRIBUTE_TARGETS && param2 is String)
         {
            this.m_targets = String(param2).split(",");
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_EVENT)
         {
            _loc2_ = this.m_eventType;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      private function updateTransition() : void
      {
         var _loc1_:BaseWidgetController = null;
         var _loc2_:int = 0;
         var _loc3_:String = null;
         if(Boolean(this.m_targets) && Boolean(this.m_triggers))
         {
            _loc1_ = null;
            _loc2_ = 0;
            _loc2_ = 0;
            while(_loc2_ < this.m_triggers.length)
            {
               _loc3_ = this.m_triggers[_loc2_];
               _loc1_ = findChildControllerByName(_loc3_);
               if(_loc1_)
               {
                  _loc1_.index = _loc2_;
                  if(this.m_eventType == EVENT_PRESSED)
                  {
                     _loc1_.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onTriggerPressed);
                  }
               }
               _loc2_++;
            }
         }
      }
      
      private function onTriggerPressed(param1:WidgetControllerEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:BaseWidgetController = null;
         var _loc2_:BaseWidgetController = param1.getController();
         if(_loc2_)
         {
            _loc3_ = _loc2_.index;
            if(Boolean(this.m_targets) && _loc3_ < this.m_targets.length)
            {
               _loc4_ = 0;
               while(_loc4_ < this.m_targets.length)
               {
                  _loc5_ = this.m_targets[_loc4_];
                  _loc6_ = findChildControllerByName(_loc5_);
                  if(_loc6_)
                  {
                     if(_loc3_ == _loc4_)
                     {
                        _loc6_.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,true);
                        _loc6_.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,true);
                     }
                     else
                     {
                        _loc6_.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
                        _loc6_.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
                     }
                  }
                  _loc4_++;
               }
            }
         }
      }
   }
}

