package Widgets.Slots.Collections
{
   import Classes.Collections.Collection;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Collections.CollectionsWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class CollectionThumbSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_collection:Collection;
      
      private var m_parentWindow:CollectionsWindow;
      
      private var m_thumbTitle:ZwTextField;
      
      private var m_thumbIcon:FarmIcon;
      
      private var m_thumbStatus:ZwTextField;
      
      private var m_selectableBckgrnd:FarmAnimatedButton;
      
      private var m_bckgrnd:ZwBaseWidget;
      
      private var m_collectionTooltip:FarmTextTooltip;
      
      public function CollectionThumbSlot(element:DisplayObject, parentWindow:CollectionsWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         var frame:ZwFrame = addWidget(new ZwFrame(m_element as DisplayObject)) as ZwFrame;
         this.m_thumbTitle = addWidget(new ZwTextField(m_element.thumbTitle_tf)) as ZwTextField;
         this.m_thumbTitle.enabled = false;
         this.m_thumbStatus = addWidget(new ZwTextField(m_element.complete_tf)) as ZwTextField;
         this.m_thumbStatus.enabled = false;
         this.m_selectableBckgrnd = addWidget(new FarmAnimatedButton(m_element.category_bt,this.onCollectionThumbClick)) as FarmAnimatedButton;
         this.m_bckgrnd = addWidget(new ZwBaseWidget(m_element.select_mc)) as ZwBaseWidget;
         this.m_thumbIcon = new FarmIcon(m_element.icon_mc);
         this.m_collectionTooltip = new FarmTextTooltip();
         frame.attachTooltip(this.m_collectionTooltip);
         this.m_thumbTitle.visible = true;
         this.m_thumbStatus.visible = true;
         this.m_selectableBckgrnd.visible = true;
         this.m_bckgrnd.visible = false;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.refresh(data);
      }
      
      public function refresh(data:Object) : void
      {
         this.m_collection = data as Collection;
         this.m_thumbTitle.text = ZLocUtils.t("Collections",this.m_collection.name + "_shortName");
         this.m_thumbIcon.loadIcon(this.m_collection.icon);
         this.m_thumbIcon.enabled = false;
         this.m_thumbIcon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_collectionTooltip.setText(ZLocUtils.t("Collections",this.m_collection.name + "_tooltip"));
         if(this.m_collection.isCollectionComplete())
         {
            this.m_thumbStatus.text = ZLocUtils.t("Collections","Complete");
            this.m_thumbStatus.visible = true;
         }
         this.m_thumbTitle.visible = true;
         this.m_thumbIcon.visible = true;
         this.m_selectableBckgrnd.visible = true;
      }
      
      public function highlightBackground() : void
      {
         this.m_bckgrnd.visible = true;
      }
      
      public function get collection() : Collection
      {
         return this.m_collection;
      }
      
      private function onCollectionThumbClick(event:Event) : void
      {
         this.m_parentWindow.updateCollectionFrame(this.m_collection);
         this.m_bckgrnd.visible = true;
      }
   }
}

