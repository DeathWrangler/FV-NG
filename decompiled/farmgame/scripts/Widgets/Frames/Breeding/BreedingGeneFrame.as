package Widgets.Frames.Breeding
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Breeding.BreedingWindow;
   import flash.display.DisplayObject;
   
   public class BreedingGeneFrame extends ZwFrame
   {
      
      private var m_parentWindow:BreedingWindow = null;
      
      public function BreedingGeneFrame(element:DisplayObject, parentWindow:BreedingWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         var featureName:String = parentWindow.getFeatureName();
         this.addWidget(new ZwTextField(m_element.header_tf,ZLocUtils.t("Dialogs",featureName + "_FamilyTree_Title")));
         this.addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs",featureName + "_FamilyTree_Desc")));
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

