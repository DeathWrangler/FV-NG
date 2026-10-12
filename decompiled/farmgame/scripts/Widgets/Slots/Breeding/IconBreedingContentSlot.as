package Widgets.Slots.Breeding
{
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Breeding.BaseContentsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   
   public class IconBreedingContentSlot extends AnimalBreedingContentsSlot
   {
      
      protected var m_farmIcon:FarmIcon = null;
      
      public function IconBreedingContentSlot(element:DisplayObject, parentWindow:BaseContentsWindow, labBuildingConfig:XML = null)
      {
         super(element,parentWindow,labBuildingConfig);
         addWidget(this.m_farmIcon = new FarmIcon(m_element.icon_mc));
      }
      
      override protected function loadIconMC(data:Object, metadata:String) : void
      {
         this.m_farmIcon.loadIcon(m_farmItem.icon);
         this.m_farmIcon.visible = true;
         (this.m_farmIcon.element as MovieClip).filters = [];
      }
      
      override protected function makeTransparent(previewFrame:ObjectPreviewFrame) : void
      {
         var alphaFilter:ColorMatrixFilter = new ColorMatrixFilter([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0.6,0]);
         (this.m_farmIcon.element as MovieClip).filters = [alphaFilter];
      }
   }
}

