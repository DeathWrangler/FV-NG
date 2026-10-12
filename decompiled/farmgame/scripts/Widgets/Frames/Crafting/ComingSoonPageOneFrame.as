package Widgets.Frames.Crafting
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Crafting.CraftingWorkshopWindow;
   import flash.display.DisplayObject;
   
   public class ComingSoonPageOneFrame extends ZwFrame
   {
      
      public function ComingSoonPageOneFrame(element:DisplayObject, window:CraftingWorkshopWindow)
      {
         super(element);
         addWidget(new ZwTextField(this.element.title_tf,ZLocUtils.t("Crafting","ComingSoon_Page1_Title")));
         addWidget(new ZwTextField(this.element.subTitle_tf,ZLocUtils.t("Crafting","ComingSoon_Page1_SubTitle")));
         addWidget(new FarmAnimatedTextButton(this.element.generic1_bt,ZLocUtils.t("Crafting","ComingSoon_Page1_Button"),window.pressOkay));
      }
   }
}

