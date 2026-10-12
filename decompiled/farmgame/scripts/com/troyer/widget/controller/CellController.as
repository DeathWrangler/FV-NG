package com.troyer.widget.controller
{
   import com.troyer.widget.event.WidgetViewEvent;
   import com.troyer.widget.interfaces.ICellController;
   import com.troyer.widget.view.BaseWidgetView;
   
   public class CellController extends BaseWidgetController
   {
      
      public static var ATTRIBUTE_VIEW_CELL:String = "viewCell";
      
      public static var ATTRIBUTE_CONTAINER:String = "container";
      
      public static var ATTRIBUTE_CELL_COUNT:String = "cellCount";
      
      public static var ATTRIBUTE_CREATE:String = "create";
      
      private var m_cell:BaseWidgetController;
      
      private var m_container:BaseWidgetController;
      
      private var m_count:int = 0;
      
      private var m_callbackObject:ICellController;
      
      public function CellController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_VIEW_CELL,ATTRIBUTE_CONTAINER,ATTRIBUTE_CREATE,ATTRIBUTE_CELL_COUNT);
         return _loc1_;
      }
      
      override protected function onChildViewResized(param1:WidgetViewEvent) : void
      {
         super.onChildViewResized(param1);
         if(!m_view.hasFixedWidth() && !m_view.hasFixedHeight())
         {
            m_view.setSize(param1.getView().getSize());
         }
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         if(param1 == ATTRIBUTE_VIEW_CELL && param2 is BaseWidgetView)
         {
            this.m_cell = BaseWidgetView(param2).getController();
         }
         else if(param1 == ATTRIBUTE_CONTAINER && param2 is String)
         {
            this.m_container = getChildController(param2);
         }
         else if(param1 == ATTRIBUTE_CELL_COUNT)
         {
            if(param2 is String)
            {
               this.m_count = parseInt(param2);
               this.create();
            }
            else if(param2 is Number)
            {
               this.m_count = param2;
               this.create();
            }
            else
            {
               addError("Attribute " + param1 + " passed in CellController is not valid for view: \'" + m_name + "\'");
            }
         }
         else if(param1 == ATTRIBUTE_CREATE && param2 is ICellController)
         {
            this.m_callbackObject = param2;
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_CELL_COUNT)
         {
            _loc2_ = this.m_count;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      private function create() : void
      {
         var _loc1_:BaseWidgetController = null;
         var _loc2_:int = 0;
         if(this.m_container)
         {
            this.m_container.removeChildControllers();
            if(Boolean(this.m_cell) && this.m_count > 0)
            {
               _loc2_ = 0;
               while(_loc2_ < this.m_count)
               {
                  _loc1_ = this.m_cell.clone();
                  if(this.m_callbackObject)
                  {
                     _loc1_ = this.m_callbackObject.onCellCreate(this.getName(),_loc2_,_loc1_);
                  }
                  if(!_loc1_)
                  {
                     break;
                  }
                  this.m_container.addChildController(_loc1_);
                  _loc2_++;
               }
            }
         }
      }
   }
}

