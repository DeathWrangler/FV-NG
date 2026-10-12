package Widgets.Windows.Breeding
{
   import Classes.FeatureBuilding;
   import Widgets.Frames.Breeding.RandomPlacementContentsSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.Breeding.BuyRemoveAnimalSlot;
   import flash.display.DisplayObject;
   
   public class RandomPlacementContentsWindow extends AnimalBreedingContentsWindow
   {
      
      private var m_sortBy:Array = null;
      
      public function RandomPlacementContentsWindow(building:FeatureBuilding)
      {
         super(building);
      }
      
      override protected function sortItems(result:Array) : void
      {
         var featureXml:XML = Global.farmGameSettingsManager.getFeatureXML(building.featureName);
         this.setSortedArray(featureXml);
         result.sort(this.resultSortCompare);
      }
      
      private function setSortedArray(featureXml:XML) : void
      {
         var code:String = null;
         var item:Object = null;
         var sortedItemCodesLength:int = 0;
         var index:uint = 0;
         var element:XML = null;
         var elements:XMLList = null;
         var itemCode:String = null;
         this.m_sortBy = new Array();
         var sortBy:Array = this.m_sortBy;
         var sortedItemCodes:Array = new Array();
         var specifiedCode:Object = new Object();
         if(featureXml != null)
         {
            elements = featureXml.descendants("sortOrder");
            for each(element in elements)
            {
               itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(element.toString());
               if(itemCode != null && itemCode.length > 0)
               {
                  sortedItemCodes.push(itemCode);
                  specifiedCode[itemCode] = true;
               }
            }
         }
         var storageItems:Array = m_storageItems;
         for each(item in storageItems)
         {
            code = item.code as String;
            if(!(code in specifiedCode))
            {
               sortedItemCodes.push(code);
            }
         }
         sortedItemCodesLength = int(sortedItemCodes.length);
         for(index = 0; index < sortedItemCodesLength; index++)
         {
            code = sortedItemCodes[index];
            sortBy[code] = index;
         }
      }
      
      private function resultSortCompare(a:Object, b:Object) : Number
      {
         return this.m_sortBy[a.code] - this.m_sortBy[b.code];
      }
      
      override public function refreshWindow() : void
      {
         updateCurrent();
         m_contents = loadContents();
         if(m_content_mc is RandomPlacementContentsSlotFrame)
         {
            (m_content_mc as RandomPlacementContentsSlotFrame).updateAnimals(m_contents);
         }
         m_content_mc.refresh();
      }
      
      override protected function getFarmSlotContainerFrame() : FarmSlotContainerFrame
      {
         return new RandomPlacementContentsSlotFrame(m_window.animals_mc,m_contents,this);
      }
      
      override protected function initFeatureWidgets() : void
      {
         super.initFeatureWidgets();
         addWidget(new GenericSlotContainerFrame(m_window.animals2_mc as DisplayObject,BuyRemoveAnimalSlot,m_contents,this),true);
      }
      
      override protected function release() : void
      {
         this.m_sortBy = null;
         super.release();
      }
   }
}

