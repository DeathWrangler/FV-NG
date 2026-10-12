package com.troyer.widget.interfaces
{
   import com.troyer.widget.controller.BaseWidgetController;
   
   public interface ICellController
   {
      
      function onCellCreate(param1:String, param2:int, param3:BaseWidgetController) : BaseWidgetController;
   }
}

