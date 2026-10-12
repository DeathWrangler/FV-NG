package Widgets.Frames.Crafting
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Crafting.RecipeMasteryWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class RecipeMasteryOnBoardFrame extends ZwFrame
   {
      
      protected var m_window:RecipeMasteryWindow;
      
      public function RecipeMasteryOnBoardFrame(element:DisplayObject, parent:RecipeMasteryWindow, hasSigns:Boolean)
      {
         super(element);
         this.m_window = parent;
         if(hasSigns)
         {
            addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Crafting","Mastery_onBoardGiftbox")));
            addWidget(new FarmAnimatedButton(m_element.visit_bt,this.onVisit));
         }
         else
         {
            addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Crafting","Mastery_onBoardGiftboxNone")));
            addWidget(new FarmAnimatedButton(m_element.visit_bt,this.onVisit));
         }
      }
      
      protected function onVisit(e:MouseEvent) : void
      {
         this.m_window.close();
         UI.displayGiftBoxWindow(false);
      }
   }
}

