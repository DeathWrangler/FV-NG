package com.troyer.widget.parser
{
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.CellController;
   import com.troyer.widget.controller.CheckBoxController;
   import com.troyer.widget.controller.CloseButtonController;
   import com.troyer.widget.controller.DialogFrameController;
   import com.troyer.widget.controller.DragController;
   import com.troyer.widget.controller.DropDownController;
   import com.troyer.widget.controller.FrameController;
   import com.troyer.widget.controller.GridController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.controller.ListController;
   import com.troyer.widget.controller.MaskController;
   import com.troyer.widget.controller.PageController;
   import com.troyer.widget.controller.PositionController;
   import com.troyer.widget.controller.ProgressBarController;
   import com.troyer.widget.controller.ResizeController;
   import com.troyer.widget.controller.ScrollController;
   import com.troyer.widget.controller.SliderController;
   import com.troyer.widget.controller.SpacerController;
   import com.troyer.widget.controller.TooltipController;
   import com.troyer.widget.controller.TransitionController;
   import com.troyer.widget.controller.TreeListController;
   import com.troyer.widget.view.CircleView;
   import com.troyer.widget.view.GradientRectangleView;
   import com.troyer.widget.view.RectangleView;
   import com.troyer.widget.view.TextFieldView;
   import com.troyer.widget.view.TriangleView;
   import com.troyer.widget.view.XView;
   
   public class DynamicClasses
   {
      
      private var m_list:Array = [TextFieldView,RectangleView,GradientRectangleView,CircleView,TriangleView,XView,ButtonController,CloseButtonController,DragController,ImageController,PositionController,ResizeController,ScrollController,PageController,ListController,DropDownController,TreeListController,CellController,GridController,ProgressBarController,CheckBoxController,MaskController,TooltipController,TransitionController,SpacerController,FrameController,DialogFrameController,SliderController];
      
      public function DynamicClasses()
      {
         super();
      }
   }
}

