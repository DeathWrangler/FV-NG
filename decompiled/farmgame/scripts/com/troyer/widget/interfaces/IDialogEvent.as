package com.troyer.widget.interfaces
{
   import com.troyer.widget.controller.ButtonController;
   
   public interface IDialogEvent
   {
      
      function onDialogCreate() : void;
      
      function onDialogDestroy() : void;
      
      function onDialogButtonPressed(param1:ButtonController) : void;
   }
}

