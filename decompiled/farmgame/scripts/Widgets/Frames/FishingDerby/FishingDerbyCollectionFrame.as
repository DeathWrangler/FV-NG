package Widgets.Frames.FishingDerby
{
   import Classes.Collections.FishingCollection;
   import Classes.util.ZLocUtils;
   import Managers.FeatureOptionsManager;
   import Managers.FishingDerbyManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FishingDerby.FishingDerbyCollectionSlot;
   import flash.display.DisplayObject;
   
   public class FishingDerbyCollectionFrame extends FarmSlotContainerFrame
   {
      
      private var m_collectionTitle:ZwTextField;
      
      private var m_collectionMasteryData:Object;
      
      private var m_collection:FishingCollection;
      
      public function FishingDerbyCollectionFrame(element:DisplayObject)
      {
         super(element);
         addWidget(this.m_collectionTitle = new ZwTextField(m_element.surface_tf));
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FishingDerbyCollectionSlot(slotElement,this);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function get masteryData() : Object
      {
         return this.m_collectionMasteryData;
      }
      
      public function get collection() : FishingCollection
      {
         return this.m_collection;
      }
      
      public function set collection(collection:FishingCollection) : void
      {
         m_slotData = collection.collectibles;
         this.m_collection = collection;
         this.m_collectionMasteryData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FISHING_DERBY,FishingDerbyManager.FEATURE_MASTERY);
         this.m_collectionMasteryData = this.m_collectionMasteryData != null ? this.m_collectionMasteryData : {};
         this.m_collectionTitle.text = ZLocUtils.t_pk("Collections",collection.name + "_friendlyName");
         refresh();
      }
   }
}

