package Widgets.Slots.FishingDerby
{
   import Classes.Collections.FishingCollection;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Windows.FishingDerby.FishingDerbyCollectionWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FishingDerbyTabsSlot extends ZwSlotFrame
   {
      
      private var m_collectionButton:FarmAnimatedTextButton;
      
      private var m_parentWindow:FishingDerbyCollectionWindow;
      
      private var m_fishingCollection:FishingCollection;
      
      public function FishingDerbyTabsSlot(element:DisplayObject, parentWindow:FishingDerbyCollectionWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         addWidget(this.m_collectionButton = new FarmAnimatedTextButton(m_element as MovieClip,"",this.setActiveCollection));
      }
      
      override public function populate(data:Object) : void
      {
         this.m_fishingCollection = data as FishingCollection;
         if(this.m_fishingCollection != null)
         {
            this.m_collectionButton.text = ZLocUtils.t_pk("Collections",this.m_fishingCollection.name + "_friendlyName");
            this.m_collectionButton.visible = true;
         }
      }
      
      private function setActiveCollection(event:Event) : void
      {
         this.m_parentWindow.setActiveCollection(this.m_fishingCollection);
      }
   }
}

